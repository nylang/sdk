# Install Nyra SDK 1.0.3

Download the matching host archive, SHA256SUMS and per-host release metadata from [the official release](https://github.com/nylang/sdk/releases/tag/v1.0.3). Verify the archive against SHA256SUMS, then extract and keep the complete directory together.

## Requirements and scope

Four native desktop hosts are accepted: macOS arm64, macOS x86_64, Linux x86_64 and Windows x86_64. Each SDK contains only its own native desktop runtime target. SDK 1.0.2 remains available with its eleven-profile cross-target catalog.

macOS tools target 14.0+ and need Xcode Command Line Tools and a matching Apple SDK for native links. Execution was accepted on macOS 27.0.1 arm64 and macOS 26.5.1 native Intel; macOS 14 execution is not claimed. Linux execution was accepted on Ubuntu 24.04.5 / glibc 2.39; install native C/C++ development tools, zlib and libxml2 dependencies. Windows needs Visual Studio 2022 C++ Build Tools and a Windows SDK for native final links. No mobile/RISC-V execution or signing/notarization is attested.

## Layout

```text
nyra-sdk-1.0.3-<host>/
  manifest.json
  package-lock.json
  LICENSE.txt
  THIRD-PARTY-NOTICES.txt
  hosts/<host>/bin/{nyra,nyrac,nyra-analyzer}[.exe]
  hosts/<host>/llvm/{bin,include,lib,licenses}/
  packages/{kernel,ntest,stdlib}/package.yaml
  packages/{kernel,ntest,stdlib}/targets/<host>/
  share/nyra/
  licenses/
```

Add `hosts/<host>/bin` and `hosts/<host>/llvm/bin` to PATH. Configure editor compiler/analyzer paths to these tools. Run `nyra version`, `nyrac version` and `nyra-analyzer version` to inspect tool versions.

## First program

Create `package.yaml`:

```yaml
name: hello
```

Create `main.ny`:

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("Hello, Nyra!");
  return 0;
}
```

Build with `nyrac build main.ny -O2 --link -o hello` (use `hello.exe` on Windows). SDK runtime imports are implicit; no absolute runtime path or workspace is needed.

## Known package-lock issue

Portable Git acquisition is explicit through `nyra lock` and `nyra fetch`; compilation never fetches. The frozen 1.0.3 compiler can incorrectly request an application origin pin for an SDK-internal kernel dependency when loading portable locks. This fix belongs to 1.0.4. Published HTTP/TLS Git consumers require those corrected tools. See [release notes](RELEASE-1.0.3.md). SSH acquisition, remote registry/version-range solving and SDK self-update are outside this release.
