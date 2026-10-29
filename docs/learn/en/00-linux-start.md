# 00: Your first program on Linux

[中文](../00-linux-start.md) · [Course index](README.md) · [Choose a platform](00-start.md) · [Next](01-values.md)

Use Linux x86_64, Bash and a matching complete SDK. The 1.0.3 public acceptance
record uses Ubuntu 24.04.5/glibc 2.39; other distributions need a compatibility
check. Download and verify the SDK using [INSTALL.md](../../../INSTALL.md).

## 1. Prepare native development tools

You need Python 3.12 or a compatible newer version and native C development
headers/startup files. SDK Clang does not replace the system development files.

```sh
uname -m
python3 --version
cc --version
```

The expected architecture is `x86_64`. Ubuntu/Debian example:

```sh
sudo apt update
sudo apt install python3 build-essential zlib1g-dev libxml2-dev
```

AlmaLinux/Fedora example:

```sh
sudo dnf install python3 gcc gcc-c++ glibc-devel zlib-devel libxml2-devel
```

Check Python's version after installation. Distribution setup examples are not
acceptance claims for every distribution. If you see a missing GLIBC version,
select a compatible SDK; do not overwrite the system libc.

## 2. Select the SDK

Replace the SDK directory below. A compiler source checkout is unnecessary.

```sh
export NYRA_SDK="$HOME/Downloads/nyra-sdk-1.0.3-linux-x86_64"
export NYRA_SDK_ROOT="$NYRA_SDK"
export NYRA_HOST="linux-x86_64"
export NYRAC="$NYRA_SDK/hosts/$NYRA_HOST/bin/nyrac"
export NYRA_ANALYZER="$NYRA_SDK/hosts/$NYRA_HOST/bin/nyra-analyzer"
export NYRA_WORK="$HOME/nyra-learning"
export PATH="$NYRA_SDK/hosts/$NYRA_HOST/bin:$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin:$PATH"
export CC="$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin/clang"
export AR="$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin/llvm-ar"

"$NYRAC" version
"$NYRA_ANALYZER" version
```

WSL uses the Linux SDK, not Windows executables combined with Linux libraries.

## 3. Create the practice package

```sh
mkdir -p "$NYRA_WORK/playground"
cd "$NYRA_WORK/playground"

python3 - <<'PYTHON'
from pathlib import Path
Path("package.yaml").write_text("name: nyra_lessons\n", encoding="utf-8")
PYTHON
```

SDK runtime dependencies are implicit; no private source paths are needed.

## 4. Save and run a complete program

Create `playground/main.ny`:

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("你好，Nyra！");
  return 0;
}
```

Check and run:

```sh
"$NYRAC" check "$NYRA_WORK/playground/main.ny"
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/hello"
```

The expected output is the same Chinese greeting used in the macOS lesson.
To create an executable:

```sh
"$NYRAC" build "$NYRA_WORK/playground/main.ny" --link \
  --out-dir "$NYRA_WORK/out/hello-build" \
  -o "$NYRA_WORK/out/hello-build/hello"
"$NYRA_WORK/out/hello-build/hello"
```

## 5. Continue with later lessons

Keep these environment variables. Skip Apple-only `xcrun` commands on Linux.
Linux shared libraries commonly use `.so`, rather than `.dylib`. Android needs
the Linux NDK; the iOS final integration described here still needs a Mac.

## Troubleshooting

Preserve executable permissions when extracting the SDK. An existing executable
that cannot run may have the wrong architecture or a missing loader/library.
Missing `crt1.o`, `crti.o` or libc usually points to native development setup.
Check that the SDK path directly contains `manifest.json` and `hosts/linux-x86_64`.
Fix source diagnostics with `check` before rebuilding.
