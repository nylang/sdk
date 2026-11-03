# 00: Choose your platform

[中文](../00-start.md) · [Course index](README.md) · [Next](fundamentals/01-program.md)

Pick one setup route; you do not need to install tools for all three hosts.

## 1. Select a route

- [macOS](00-macos-start.md), using the SDK matching Apple silicon or Intel.
- [Windows x86_64](00-windows-start.md), using PowerShell.
- [Linux x86_64](00-linux-start.md), using Bash.

After printing the greeting, continue to [lesson 01](fundamentals/01-program.md). Other
architectures require actual matching SDK artifacts, not renamed directories.

## 2. Host and target are different concepts

The host runs the compiler. The target runs the resulting program or library.
Learn native desktop development first. Later, a Mac can participate in iOS or
Android cross-builds, while Windows/Linux use the appropriate Android NDK.
iOS final linking and Xcode integration in this course happen on a Mac.
The phone uses compiled logic; it does not need the compiler installed.

## 3. Install a complete SDK

Download [SDK 1.0.5](https://github.com/nylang/sdk/releases/tag/v1.0.5), verify
SHA256SUMS using [INSTALL.md](../../../INSTALL.md), and extract the whole tree.
Its important directories are:

```text
sdk-root/
  manifest.json
  package-lock.json
  hosts/<host>/bin/
    nyra or nyra.exe
    nyrac or nyrac.exe
    nyra-analyzer or nyra-analyzer.exe
  hosts/<host>/llvm/
  packages/kernel/package.yaml
  packages/ntest/package.yaml
  packages/stdlib/package.yaml
  packages/<package>/targets/<host>/
```

`hosts` contains development-machine tools; `packages` contains SDK libraries
and their target artifacts. JSON/YAML are independent ecosystem packages.
Use the native SDK for this course. Select matching separate runtime bundles for other targets as described in the installation guide.

## 4. Use your host's shell syntax

Save the same `.ny` code on each host. Most commands use Bash; Windows readers
can use the [PowerShell conversion guide](00-windows-start.md#translate-later-commands-to-powershell).

macOS/Linux:

```sh
"$NYRAC" run "$NYRA_WORK/playground/main.ny" --out-dir "$NYRA_WORK/out/current"
```

PowerShell:

```powershell
& $env:NYRAC run "$env:NYRA_WORK/playground/main.ny" --out-dir "$env:NYRA_WORK/out/current"
```

PowerShell's `&` invokes the executable named by the following expression.
Keep path quotes so spaces remain part of the path.

## 5. C and mobile topics

Finish the basic lessons before [C interop](15-c-interop.md), [iOS](16-ios.md)
or [Android](17-android.md). These use small logic libraries; they do not require
you to rewrite a native UI in Nyra. Read the mobile tooling availability notes.

## 6. Optional package creation

The complete SDK 1.0.5 includes `nyra new hello`, `nyra new mylib --kind lib`
and `nyra init ./existing --name existing`. Inspect a plan with `--dry-run --json`.
The setup lessons retain manual creation of two files to explain the package root
and entry without requiring an IDE workflow.

## After setup

Continue with [foundations lesson 01: reading a program](fundamentals/01-program.md), then follow each lesson’s Next link. The older lessons 01–03 remain overviews; you do not need structs, generics or interfaces before beginning.
