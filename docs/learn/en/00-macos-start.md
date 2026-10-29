# 00: Your first program on macOS

[中文](../00-macos-start.md) · [Course index](README.md) · [Choose a platform](00-start.md) · [Next](01-values.md)

The goal is to print a greeting. Follow the steps first; later lessons explain
the language in more detail.

## 1. Prepare a terminal and editor

Use a UTF-8-capable editor. Follow [INSTALL.md](../../../INSTALL.md) to download,
verify and extract the complete SDK: darwin-arm64 for Apple silicon or
darwin-x86_64 for Intel. No compiler source checkout is needed.

```sh
uname -m
python3 --version
xcrun --show-sdk-path
```

If `xcrun` cannot find developer tools, run `xcode-select --install` and finish
the system installer before continuing.

## 2. Select one coherent SDK

Replace the SDK path with the directory containing your manifest. Intel users
must select the Intel archive and change `NYRA_HOST` to `darwin-x86_64`.

```sh
export NYRA_SDK="$HOME/Downloads/nyra-sdk-1.0.3-darwin-arm64"
export NYRA_SDK_ROOT="$NYRA_SDK"
export NYRA_HOST="darwin-arm64"
export NYRAC="$NYRA_SDK/hosts/$NYRA_HOST/bin/nyrac"
export NYRA_ANALYZER="$NYRA_SDK/hosts/$NYRA_HOST/bin/nyra-analyzer"
export NYRA_WORK="$HOME/nyra-learning"
export PATH="$NYRA_SDK/hosts/$NYRA_HOST/bin:$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin:$PATH"
export SDKROOT="$(xcrun --show-sdk-path)"
export CC="$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin/clang"
export AR="$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin/llvm-ar"

"$NYRAC" version
"$NYRA_ANALYZER" version
```

These variables last only for this terminal session. Set them again after
opening a new terminal. Keep compiler, LLVM tools and runtime packages together.

## 3. Create a practice package

```sh
mkdir -p "$NYRA_WORK/playground"
cd "$NYRA_WORK/playground"

python3 - <<'PYTHON'
from pathlib import Path
Path("package.yaml").write_text("name: nyra_lessons\n", encoding="utf-8")
PYTHON
```

SDK 1.0.3 locates kernel, stdlib and ntest implicitly. Ecosystem packages are
configured in later lessons; source code still needs its `import` statements.

## 4. Save and run the complete program

Create `main.ny` in the practice directory:

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("你好，Nyra！");
  return 0;
}
```

Save as UTF-8, with the actual filename `main.ny`, not `main.ny.txt`. Check it:

```sh
"$NYRAC" check "$NYRA_WORK/playground/main.ny"
```

Then run it:

```sh
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/hello"
```

Expected output:

```text
你好，Nyra！
```

## 5. Read the program

`import` selects a library surface. `main` is the entry point; `int32` is its
return type. `Console.Println` writes a line, and `return 0` reports success.
You may change the greeting, but API names and their capitalization matter.

## 6. Produce an executable

```sh
"$NYRAC" build "$NYRA_WORK/playground/main.ny" --link \
  --out-dir "$NYRA_WORK/out/hello-build" \
  -o "$NYRA_WORK/out/hello-build/hello"

"$NYRA_WORK/out/hello-build/hello"
```

`check` checks source, `build --link` produces an executable, and `run` builds
and executes it. Object compilation alone is not executable linking.

## Troubleshooting

Check the saved file and `NYRAC` path first. For missing stdlib, check the complete
SDK and package location. For native link errors inspect `xcrun`, `SDKROOT` and
`CC`. Confirm host/target architecture, then fix the first reported source
diagnostic. Do not solve version mismatches by mixing SDK packages.

## Exercise

Print your name and a learning goal on separate lines. Reference solution:

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("我叫小明");
  Console.Println("今天要学会运行 Nyra 程序");
  return 0;
}
```
