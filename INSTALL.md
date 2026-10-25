# Install the Nyra SDK

These instructions describe the planned stable archive format. The first 1.0.0
artifacts are not available until the release is published.

## Prerequisites

Use an archive matching your host OS and architecture. macOS requires Xcode
Command Line Tools and its system SDK. Windows native final links require Visual
Studio C++ Build Tools and a Windows SDK. Linux requires a compatible native C/C++
runtime and development files. The packaged LLVM query wrapper requires Python 3.
Refer to the exact release notes for accepted OS versions and external tools.
Android/iOS final links require the appropriate external NDK or Apple SDK.

## Download and verify

Download the host archive, `SHA256SUMS` and `release.json` from the same official
GitHub release. Verify the archive's SHA-256 against its entry in `SHA256SUMS`:

```text
# macOS
shasum -a 256 nyra-sdk-1.0.0-darwin-arm64.tar.gz

# Linux
sha256sum nyra-sdk-1.0.0-linux-x86_64.tar.gz

# Windows PowerShell
Get-FileHash .\nyra-sdk-1.0.0-windows-x86_64.zip -Algorithm SHA256
```

Compare the entire digest before extracting. A checksum verifies consistency
with the published record; check the release's signing statement separately.
Keep the extracted directory structure intact. The directory containing
`manifest.json` is the SDK root.

## Directory layout

```text
nyra-sdk-<version>-<host>/
  README.md
  LICENSE.txt
  THIRD-PARTY-NOTICES.txt
  manifest.json
  package-lock.json
  licenses/
  hosts/<host>/
    bin/nyrac[.exe]
    bin/nyra-analyzer[.exe]
    share/nyra/analyzer/analysis_options.yaml
    llvm/{bin,include,lib,licenses}/
  targets/<target>/{kernel,stdlib,json,yaml}/
  share/nyra/
```

`stdlib/lib/libnyra_platform.a` supplies the platform bridge. Runtime package
`sources/interface` and `sources/public` carry necessary API/generic code.
An SDK includes one host's executable tools; additional target rows are library
catalogs, not executable compilers for those other hosts.

## Configure tools

Add the SDK's `hosts/<host>/bin` and `hosts/<host>/llvm/bin` directories to PATH.
If needed, select the packaged `clang` with the `CC` environment variable.
Configure VS Code with absolute paths in `nyra.compilerPath` and
`nyra.analyzerPath`.

```text
nyrac version
nyra-analyzer version
```

## First program

Create a new directory containing these two files. Replace the package path
with your actual SDK root and an advertised native target, using forward slashes
also for Windows paths such as `E:/SDK/...`.

`package.yaml`:

```yaml
name: hello
dependencies:
  stdlib:
    precompiled: /absolute/sdk/targets/darwin-arm64/stdlib
```

`main.ny`:

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("Hello, Nyra!");
  return 0;
}
```

```text
nyrac build main.ny -O2 --link -o hello
```

Use `-o hello.exe` on Windows. Run the generated executable. Package dependencies
inside the SDK are relative and remain valid when the entire SDK is moved; update
the absolute SDK paths in your own project after moving it.
