# Install the Nyra SDK

Install version 1.0.2 from the [official release](https://github.com/nylang/sdk/releases/tag/v1.0.2).
Use its SHA256SUMS and per-host release records for the exact artifact identities.

## Prerequisites

Use an archive matching your host OS and architecture. macOS arm64 and x86_64
builds target macOS 14.0 or newer and require Xcode Command Line Tools plus the
system SDK. The macOS x86_64 tools passed execution through Rosetta; native
Intel Mac execution and execution on macOS 14 are not claimed for this release.
Windows native final links require Visual Studio C++ Build Tools and a Windows
SDK. Linux was accepted on AlmaLinux 10.0 x86_64. The packaged ELF tools
require at least GLIBC 2.34, GLIBCXX 3.4.30 and CXXABI 1.3.13 symbols, plus
zlib, libxml2 and their system dependencies. Matching native development
files are required for application links; a different distribution is not
covered by the native execution receipt. The packaged LLVM query wrapper requires Python 3.
The macOS native deployment default is 14.0, matching its precompiled packages.
An explicit `--llvm-target` or `MACOSX_DEPLOYMENT_TARGET` override requires
libraries built for the same target triple.
Compiler and analyzer versions are 1.0.2 on all four hosts. Each host
configuration passed clean-source three-generation bootstrap with identical
G2/G3 compilers, 492 regression cases per generation and 1,040 package unit
tests. The x86_64 macOS execution receipt uses Rosetta. Refer to the release
metadata for the exact validation scope.
Android/iOS final links require the appropriate external NDK or Apple SDK.

## Download and verify

Download the host archive, `SHA256SUMS` and `release.json` from the same official
GitHub release. Verify the archive's SHA-256 against its entry in `SHA256SUMS`:

```text
# macOS
shasum -a 256 nyra-sdk-1.0.2-darwin-arm64.tar.gz

# macOS Intel
shasum -a 256 nyra-sdk-1.0.2-darwin-x86_64.tar.gz

# Linux
sha256sum nyra-sdk-1.0.2-linux-x86_64.tar.gz

# Windows PowerShell
Get-FileHash .\nyra-sdk-1.0.2-windows-x86_64.zip -Algorithm SHA256
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
  targets/<target>/{kernel,ntest,stdlib}/
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

## Bundled target libraries

Every host archive includes eleven runtime profiles. Only its own host's compiler
and analyzer are executable tools in that archive.

- Desktop: macOS arm64 and x86_64, Linux x86_64 and Windows x86_64.
- Android: arm64 and x86_64, API 28.
- Apple mobile: iOS arm64 and iOS Simulator arm64, minimum iOS 15.0.
- Linux RISC-V: RV64GC / LP64D.
- Freestanding RISC-V: RV64GC / LP64D (`none-riscv64`) and
  RV64IMAC / LP64 (`nyraos-riscv64`). These two profiles contain kernel and
  provider contracts; they do not include hosted stdlib, JSON, YAML or a platform
  archive. Supply the required provider implementation before linking.

Hosted profiles include precompiled kernel, ntest, stdlib and the platform
archive. JSON and YAML are independent packages and are not bundled runtime
packages. Mobile and foreign runtime profiles have library/ABI/link acceptance;
the release does not claim execution on an Android/iOS device or a RISC-V OS.
The macOS archive also carries `frameworks/NyraRuntime.xcframework` for the two
iOS profiles. Apple final linking and XCFramework assembly require macOS/Xcode.
Other final cross-target links require the target's NDK, SDK, sysroot or CRT.
Those system SDKs are not included in the release.

The manifest and provider requirements remain authoritative for exact triples,
CPU features, ABIs and supported platform operations. For example, iOS does not
provide the hosted process-spawn operations.

## Distribution signing status

SDK 1.0.2 records `signing: not-attested`: no macOS Developer ID /
notarization or Windows Authenticode attestation is supplied. macOS link-time
ad-hoc signatures do not attest a publisher identity. Gatekeeper or SmartScreen
may warn when launching downloaded binaries. Verify the official release origin
and complete SHA-256 digest before deciding to run them.

## Run your package's tests

The SDK compiler includes test discovery and a test harness. Built-in `assert`
works without an additional test-framework package. Add this function to the
example `main.ny` above:

```nyra
@test
func test_answer() {
  var values: Array<int32> = Array<int32>{};
  values.Push(40);
  values.Push(2);
  assert(values.Get(0) + values.Get(1) == 42);
}
```

```text
nyrac test . --out-dir ../test-objects --report ../test-report.json
```

Built-in assertions do not require a test-framework dependency. The optional
`ntest` soft-assertion framework is bundled as a precompiled package for hosted
targets; declare an `ntest` dependency when using its APIs.
