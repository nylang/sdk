# 15 · Nyra 与 C 相互调用

[English](en/15-c-interop.md)

[上一课](14-compiler-tools.md) · [教程目录](README.md) · [下一课：iOS](16-ios.md)

这一课分别做两件事：Nyra 调用一个 C 函数，C 调用一个 Nyra 函数。
手机开发也会用到这层接口，先在电脑上理解它更容易。

## 1. 先分清声明、实现和链接

- 声明：告诉编译器函数叫什么、收什么参数、返回什么。
- 实现：真正执行计算的代码。
- 链接：把调用和实现连接起来。

只写 `@extern("C")` 不会自动生成外部库，也不会自动寻找你电脑上的某个头文件。

先创建单独的练习目录。macOS/Linux：

```sh
mkdir -p "$NYRA_WORK/ffi"
cd "$NYRA_WORK/ffi"
```

Windows PowerShell：

```powershell
New-Item -ItemType Directory -Force "$env:NYRA_WORK/ffi" | Out-Null
Set-Location "$env:NYRA_WORK/ffi"
```

新建 `package.yaml`：

```yaml
name: ffi_lesson
```

前半课只处理整数和调用关系，不使用标准库，所以不需要配置依赖。

## 2. Nyra 调用你写的 C 函数

新建 `c_math.c`：

```c
#include <stdint.h>

int32_t c_add(int32_t left, int32_t right) {
    return left + right;
}
```

新建 `call_c.ny`：

```nyra
@extern("C") func c_add(left: int32, right: int32) -> int32;

func main() -> int32 {
  let result: int32 = c_add(20, 22);
  if result != 42 { return 1; }
  return 0;
}
```

先编译 C 文件，再把它加入 Nyra 程序的最终链接。

macOS/Linux：

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

PowerShell：

```powershell
New-Item -ItemType Directory -Force "$env:NYRA_WORK/out/ffi-call" | Out-Null
& $env:CC -c "$env:NYRA_WORK/ffi/c_math.c" -o "$env:NYRA_WORK/out/ffi-call/c_math.o"
& $env:NYRAC build "$env:NYRA_WORK/ffi/call_c.ny" --link --out-dir "$env:NYRA_WORK/out/ffi-call/nyra" --link-arg "$env:NYRA_WORK/out/ffi-call/c_math.o" -o "$env:NYRA_WORK/out/ffi-call/program.exe"
& "$env:NYRA_WORK/out/ffi-call/program.exe"
$LASTEXITCODE
```

本例没有显示文字。最后的状态码应为 0，表示 C 的加法结果符合预期。

如果只运行 `check`，可能检查成功，却在真正链接时出现 `c_add` 未定义。
这说明声明存在，但实现还没有加入链接。

## 3. C 调用 Nyra：先导出接口

新建 `logic.ny`，完整内容：

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

这里没有 `main`，因为它是给别的程序使用的库。
`@extern("C", api)` 保留 C 链接名称，并把接口纳入生成的 C 头文件。

第二个函数演示一种清楚的边界：C 提供可写缓冲区，Nyra 填入内容。
`capacity` 必须是实际可写容量。成功时写入 4 个字母和末尾零字节，返回文字长度 4；容量不足时返回 -1。

## 4. 生成头文件和目标文件

macOS/Linux：

```sh
mkdir -p "$NYRA_WORK/out/ffi-lib/include"
"$NYRAC" build "$NYRA_WORK/ffi/logic.ny" \
  --out-dir "$NYRA_WORK/out/ffi-lib/objects" \
  --object-manifest "$NYRA_WORK/out/ffi-lib/objects.list" \
  --c-header "$NYRA_WORK/out/ffi-lib/include/nyra_logic.h"
```

PowerShell：

```powershell
New-Item -ItemType Directory -Force "$env:NYRA_WORK/out/ffi-lib/include" | Out-Null
& $env:NYRAC build "$env:NYRA_WORK/ffi/logic.ny" --out-dir "$env:NYRA_WORK/out/ffi-lib/objects" --object-manifest "$env:NYRA_WORK/out/ffi-lib/objects.list" --c-header "$env:NYRA_WORK/out/ffi-lib/include/nyra_logic.h"
```

打开生成的 `nyra_logic.h`，可以看到类似的声明：

```c
int32_t nyra_add(int32_t arg0, int32_t arg1);
int32_t nyra_greeting(uint8_t *arg0, int32_t arg1);
```

以实际生成文件为准，不需要手工维护另一份可能不同步的声明。
`objects.list` 列出这次构建实际产生和使用的目标文件，接下来按它打包，不用通配符收集可能过期的 `.o`。

## 5. 把目标文件装进静态库

把下面代码保存成 `ffi/pack_library.py`：

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

macOS/Linux 运行：

```sh
python3 "$NYRA_WORK/ffi/pack_library.py"
```

PowerShell 运行：

```powershell
python "$env:NYRA_WORK/ffi/pack_library.py"
```

得到 `libnyra_logic.a`。这里的归档后缀不代表所有平台的内容相同：Windows SDK 归档里的对象仍是 Windows COFF，
Linux 是 ELF，macOS 是 Mach-O，不能互相混用。

## 6. 写一个真正的 C 调用者

新建 `ffi/driver.c`：

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

macOS/Linux：

```sh
"$CC" "$NYRA_WORK/ffi/driver.c" \
  -I "$NYRA_WORK/out/ffi-lib/include" \
  "$NYRA_WORK/out/ffi-lib/libnyra_logic.a" \
  -o "$NYRA_WORK/out/ffi-lib/caller"
"$NYRA_WORK/out/ffi-lib/caller"
```

PowerShell：

```powershell
& $env:CC "$env:NYRA_WORK/ffi/driver.c" -I "$env:NYRA_WORK/out/ffi-lib/include" "$env:NYRA_WORK/out/ffi-lib/libnyra_logic.a" -o "$env:NYRA_WORK/out/ffi-lib/caller.exe"
& "$env:NYRA_WORK/out/ffi-lib/caller.exe"
```

预期输出：

```text
sum=42, text=Nyra
```

本例没有使用 Nyra 标准库或动态分配，所以链接简单。
真实库如果引入 stdlib、JSON 或 YAML，还需要把对应的目标依赖和平台库一起加入最终链接。

## 7. 传字符串时，不要传错东西

最容易维护的 C 边界通常采用：

- 数值使用明确宽度，例如 `int32_t` 对应 `int32`。
- 输入文字使用“指针 + 字节长度”，明确使用 UTF-8。
- 输出文字使用“调用者提供的缓冲区 + 容量 + 返回长度”，像上面的例子。
- 长期对象使用不透明句柄和对应销毁函数，而不是把内部对象布局暴露出去。

Nyra 的 `string` 壳不是 C 的普通结构体契约，也不保证任意视图末尾有 `\0`。
`Array`、`rc`、`arc`、`unique` 和接口值也不要直接当作稳定的跨语言对象布局传递。
在边界处转换成简单数据，Nyra 内部仍可使用这些高级类型。

如果 Nyra 分配、C 接收，必须同时约定如何归还给 Nyra。
不要拿 C 的 `free()` 释放 Nyra 拥有对象，也不要把 C 栈上的缓冲区交给 Nyra 当长期拥有内存。

### 传结构体时，也使用同一份生成头文件

可以在 `logic.ny` 中增加以下定义，再重新生成头文件和静态库：

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

生成头文件会带上接口可达的普通结构体定义。
在 C 的 `main` 里可以添加：

```c
NyraPoint point = {20, 22};
printf("point sum=%d\n", (int)nyra_point_sum(&point));
```

本例通过指针借用 C 的局部对象，只在调用期间读取。
不要自己猜字段偏移、另起一份不同的结构体定义，或者让 Nyra 把这个局部对象保存到调用结束以后。
包含拥有对象、接口值等复杂字段的结构体不照搬这种边界。

## 8. C 回调需要 C 函数指针

进阶片段，先看 C 接口的形状：

```c
typedef void (*ValueCallback)(int32_t value, void *context);
void c_emit_values(ValueCallback callback, void *context);
```

Nyra 对应的声明和回调定义可以写成：

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

在 `main` 里使用的局部片段：

```nyra
var total: int32 = 0;
let callback: ValueCallback = on_value as ValueCallback;
c_emit_values(callback, (&mut total) as *mut uint8);
```

要运行这个片段，还需要像第 2 节那样编译并链接 `c_emit_values` 的 C 实现。
例如同步实现：

```c
#include <stdint.h>

typedef void (*ValueCallback)(int32_t value, void *context);

void c_emit_values(ValueCallback callback, void *context) {
    callback(20, context);
    callback(22, context);
}
```

调用结束后 `total` 应为 42。本例只在函数返回前调用回调。
如果 C 保存了回调并在未来调用，`context` 必须保持有效；不能让它指向已经返回的局部变量。

普通 Nyra 函数值可能包含环境指针，不能直接强转成 C 函数指针。
这里使用 `cfn<...>` 和明确的 `@extern("C")` 函数，捕获状态通过 `context` 传入。

## 9. C++ 和动态库的补充

生成头文件带有 C++ 的 `extern "C"` 保护，可以由 C++ 包装层包含。
不要直接把 C++ 类、异常或 STL 容器作为 Nyra 的公开参数；先用 C 包装函数建立清楚的边界。

这一课先使用静态库，减少动态库查找和部署问题。
Windows DLL、Linux `.so`、macOS `.dylib` 还涉及符号导出、加载路径和运行时依赖，不能只改文件后缀。

## 练习

把调用者的缓冲区从 5 字节改成 4 字节。
参考结果：`nyra_greeting` 返回 -1，不应继续把缓冲区当成功字符串输出。

然后添加一个 `nyra_multiply`，重新生成头文件和库，再从 C 调用。
不需要修改生成的头文件，只修改 Nyra 源码并重新构建。
