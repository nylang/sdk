# 15: Calling between Nyra and C

[中文](../15-c-interop.md) · [Course index](README.md) · [Previous](14-compiler-tools.md) · [Next](16-ios.md)

First call a C function from Nyra, then export a Nyra library to C. This boundary
also underlies the mobile chapters.

## 1. Declaration, implementation and linking

A declaration describes name/types; implementation performs work; linking
connects a call to its definition. @extern("C") does not create a foreign library
or discover a header automatically. Create a separate practice package.

macOS/Linux:

```sh
mkdir -p "$NYRA_WORK/ffi"
cd "$NYRA_WORK/ffi"
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:NYRA_WORK/ffi" | Out-Null
Set-Location "$env:NYRA_WORK/ffi"
```

Create package.yaml:

```yaml
name: ffi_lesson
```

The initial examples use integers and no stdlib dependencies.

## 2. Call a C function from Nyra

Create c_math.c:

```c
#include <stdint.h>

int32_t c_add(int32_t left, int32_t right) {
    return left + right;
}
```

Create call_c.ny:

```nyra
@extern("C") func c_add(left: int32, right: int32) -> int32;

func main() -> int32 {
  let result: int32 = c_add(20, 22);
  if result != 42 { return 1; }
  return 0;
}
```

Compile C, then include its object in the Nyra final link. macOS/Linux:

```sh
mkdir -p "$NYRA_WORK/out/ffi-call"
"$CC" -c "$NYRA_WORK/ffi/c_math.c" -o "$NYRA_WORK/out/ffi-call/c_math.o"
"$NYRAC" build "$NYRA_WORK/ffi/call_c.ny" --link \
  --out-dir "$NYRA_WORK/out/ffi-call/nyra" \
  --link-arg "$NYRA_WORK/out/ffi-call/c_math.o" \
  -o "$NYRA_WORK/out/ffi-call/program"
"$NYRA_WORK/out/ffi-call/program"
echo $?
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:NYRA_WORK/out/ffi-call" | Out-Null
& $env:CC -c "$env:NYRA_WORK/ffi/c_math.c" -o "$env:NYRA_WORK/out/ffi-call/c_math.o"
& $env:NYRAC build "$env:NYRA_WORK/ffi/call_c.ny" --link --out-dir "$env:NYRA_WORK/out/ffi-call/nyra" --link-arg "$env:NYRA_WORK/out/ffi-call/c_math.o" -o "$env:NYRA_WORK/out/ffi-call/program.exe"
& "$env:NYRA_WORK/out/ffi-call/program.exe"
$LASTEXITCODE
```

There is no text output; expected exit status is zero. check may succeed while
linking reports undefined c_add: the declaration exists, but its implementation
has not been linked.

## 3. Export Nyra operations to C

Create the complete library file logic.ny:

```nyra
@extern("C", api) func nyra_add(left: int32, right: int32) -> int32 {
  return left + right;
}

@extern("C", api) func nyra_greeting(output: *mut uint8, capacity: int32) -> int32 {
  if capacity < 5 || output == (0 as *mut uint8) { return -1; }
  unsafe {
    output[0] = 'N';
    output[1] = 'y';
    output[2] = 'r';
    output[3] = 'a';
    output[4] = 0u8;
  }
  return 4;
}
```

A library does not require main. @extern("C", api) preserves C linkage names
and includes reachable API declarations in the generated header. The greeting
operation writes into caller storage: capacity must be writable capacity. It
writes four letters plus NUL, returns length four, and returns -1 if too small.

## 4. Generate the header and objects

macOS/Linux:

```sh
mkdir -p "$NYRA_WORK/out/ffi-lib/include"
"$NYRAC" build "$NYRA_WORK/ffi/logic.ny" \
  --out-dir "$NYRA_WORK/out/ffi-lib/objects" \
  --object-manifest "$NYRA_WORK/out/ffi-lib/objects.list" \
  --c-header "$NYRA_WORK/out/ffi-lib/include/nyra_logic.h"
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:NYRA_WORK/out/ffi-lib/include" | Out-Null
& $env:NYRAC build "$env:NYRA_WORK/ffi/logic.ny" --out-dir "$env:NYRA_WORK/out/ffi-lib/objects" --object-manifest "$env:NYRA_WORK/out/ffi-lib/objects.list" --c-header "$env:NYRA_WORK/out/ffi-lib/include/nyra_logic.h"
```

The generated header contains declarations of this shape:

```c
int32_t nyra_add(int32_t arg0, int32_t arg1);
int32_t nyra_greeting(uint8_t *arg0, int32_t arg1);
```

Use the actual generated file, not a second hand-maintained declaration.
objects.list identifies this build's object workset; avoid stale wildcard inputs.

## 5. Archive the object workset

Save this as ffi/pack_library.py:

```python
import os
import subprocess
from pathlib import Path

work = Path(os.environ["NYRA_WORK"]) / "out/ffi-lib"
sdk = Path(os.environ["NYRA_SDK"])
host = os.environ["NYRA_HOST"]
suffix = ".exe" if os.name == "nt" else ""
archiver = sdk / "hosts" / host / "llvm/bin" / ("llvm-ar" + suffix)
objects = [Path(line) for line in (work / "objects.list").read_text(encoding="utf-8").splitlines() if line]
if not objects or any(not path.is_file() or path.suffix != ".o" for path in objects):
    raise SystemExit("本课应只有实际存在的 .o 输入，请检查 objects.list")
library = work / "libnyra_logic.a"
if library.exists():
    library.unlink()
subprocess.run([str(archiver), "rcs", str(library), *map(str, objects)], check=True)
print(library)
```

macOS/Linux:

```sh
python3 "$NYRA_WORK/ffi/pack_library.py"
```

PowerShell:

```powershell
python "$env:NYRA_WORK/ffi/pack_library.py"
```

The resulting .a contains target objects: COFF on Windows, ELF on Linux and
Mach-O on macOS. A shared suffix does not make the archive cross-platform.

## 6. Write a C caller

Create ffi/driver.c:

```c
#include <stdint.h>
#include <stdio.h>
#include "nyra_logic.h"

int main(void) {
    int32_t sum = nyra_add(20, 22);
    uint8_t text[5];
    int32_t length = nyra_greeting(text, (int32_t)sizeof(text));
    if (sum != 42 || length != 4) {
        return 1;
    }
    printf("sum=%d, text=%s\n", (int)sum, (const char *)text);
    return 0;
}
```

macOS/Linux:

```sh
"$CC" "$NYRA_WORK/ffi/driver.c" \
  -I "$NYRA_WORK/out/ffi-lib/include" \
  "$NYRA_WORK/out/ffi-lib/libnyra_logic.a" \
  -o "$NYRA_WORK/out/ffi-lib/caller"
"$NYRA_WORK/out/ffi-lib/caller"
```

PowerShell:

```powershell
& $env:CC "$env:NYRA_WORK/ffi/driver.c" -I "$env:NYRA_WORK/out/ffi-lib/include" "$env:NYRA_WORK/out/ffi-lib/libnyra_logic.a" -o "$env:NYRA_WORK/out/ffi-lib/caller.exe"
& "$env:NYRA_WORK/out/ffi-lib/caller.exe"
```

Expected output:

```text
sum=42, text=Nyra
```

This dependency-free logic has a simple final link. A real library using stdlib,
JSON or YAML must also supply those exact target dependencies/platform libraries.

## 7. Text and struct boundaries

Prefer fixed-width scalar types, input UTF-8 pointer/byte-length pairs,
caller-provided output buffers with capacities/returned lengths, and opaque
handles with explicit ownership contracts for long-lived foreign resources.

Do not expose Nyra string/Array/rc/arc/unique/interface layouts as ordinary C
objects. A string view need not be NUL-terminated. Convert at the boundary; do
not call C free on Nyra-owned storage or adopt a C stack buffer permanently.

For a plain struct, add this to logic.ny and regenerate both header and library:

```nyra
struct NyraPoint {
  x: int32;
  y: int32;
}

@extern("C", api) func nyra_point_sum(point: *const NyraPoint) -> int32 {
  if point == (0 as *const NyraPoint) { return 0; }
  unsafe { return (*point).x + (*point).y; }
}
```

Add the following fragment inside the C caller's main:

```c
NyraPoint point = {20, 22};
printf("point sum=%d\n", (int)nyra_point_sum(&point));
```

The generated header describes reachable plain struct layouts. This example
borrows a local C object only during the call. Do not guess offsets, introduce
a conflicting definition or retain the local pointer beyond its lifetime.
Complex owning/interface fields require a different boundary contract.

## 8. Callbacks need C function pointers

First inspect the C interface fragment:

```c
typedef void (*ValueCallback)(int32_t value, void *context);
void c_emit_values(ValueCallback callback, void *context);
```

Matching Nyra declarations and callback definition:

```nyra
typedef ValueCallback = cfn<(int32, *mut uint8) -> void>;

@extern("C") func c_emit_values(callback: ValueCallback, context: *mut uint8) -> void;

@extern("C") func on_value(value: int32, context: *mut uint8) -> void {
  unsafe {
    let total: *mut int32 = context as *mut int32;
    *total = *total + value;
  }
}
```

Fragment in main:

```nyra
var total: int32 = 0;
let callback: ValueCallback = on_value as ValueCallback;
c_emit_values(callback, (&mut total) as *mut uint8);
```

Compile and link the C implementation as in section 2. A synchronous example:

```c
#include <stdint.h>

typedef void (*ValueCallback)(int32_t value, void *context);

void c_emit_values(ValueCallback callback, void *context) {
    callback(20, context);
    callback(22, context);
}
```

Expected total: 42. This implementation invokes callbacks before returning.
If a foreign library retains callbacks, their context must stay valid longer
than the call; a returned stack local cannot serve as that context. Ordinary
Nyra function values may include environment data, so do not cast them to C
function pointers. Use cfn, explicit C linkage and a context argument.

## 9. C++ and shared libraries

Generated headers include extern-C guards for C++ callers. Wrap C++ classes,
exceptions and STL containers behind a C API rather than exposing their layouts.
This lesson uses static archives. DLL/.so/.dylib delivery additionally needs
exports, loader paths and runtime dependencies; renaming a file is insufficient.

## Exercises

Shrink the greeting buffer from five bytes to four. Expect -1 and do not print
it as a successful string. Add nyra_multiply, regenerate header/archive and call
it from C. Change Nyra source rather than editing generated declarations.
