# Install Nyra SDK 1.0.4

Download the matching host archive, SHA256SUMS and per-host release metadata
from [the official release](https://github.com/nylang/sdk/releases/tag/v1.0.4).
Verify SHA256 before extraction and keep the complete directory together.

## Requirements and scope

Supported desktop hosts are macOS arm64, macOS x86_64, Linux x86_64 and Windows
x86_64. Each SDK includes its own native runtime target. SDK 1.0.2 retains the
historical eleven-profile catalog; 1.0.4 does not deliver that foreign catalog.

macOS needs Xcode Command Line Tools and a system SDK for native links; its
minimum deployment target is 14.0. Current execution uses arm64 and Rosetta
x86_64, without macOS 14 runtime acceptance. Linux needs the native development
libraries required by the packaged LLVM tools. Windows final native links need
Visual Studio C++ Build Tools and a Windows SDK. Source builds of the embedded
Git provider additionally need CMake and Ninja on PATH. No signing/notarization
is attested.

## Layout and first application

The directory containing `manifest.json` is the SDK root. Add
`hosts/<host>/bin` and `hosts/<host>/llvm/bin` to PATH. Runtime package indexes
are under `packages/{kernel,ntest,stdlib}/package.yaml`, with native targets
below their `targets/<host>` directories. Configure VS Code's `nyra.sdkPath`
to the SDK root.

```text
nyra version
nyrac version
nyra-analyzer version
nyra new hello
cd hello
nyrac check main.ny
nyrac build main.ny -O2 --link -o hello
nyrac test main.ny
```

Use `hello.exe` as the output on Windows. `nyra new mylib --kind lib` creates a
library; `nyra init ./existing --name existing` retains existing source. Preview
with `--dry-run --json`. VS Code Create/Initialize Package uses the same manager.
SDK kernel/stdlib/ntest imports need no explicit dependency paths.

## Dependencies and relocation

Use public Git origins with immutable pins for shared source packages; use
`workspace.yaml` for private local pointers. `nyra lock` and `nyra fetch`
explicitly acquire content; compiler/analyzer reads do not fetch. Prepared local
and global stores support `nyra fetch --frozen --offline`. Public JSON and HTTP/TLS
Git consumers pass with the corrected 1.0.4 tools. The 1.0.3 SDK-internal
runtime-lock issue is fixed in 1.0.4.

Keep the SDK structure intact when moving it, and rebuild dependencies coherently
for platform ABI 10. System Git and Python are not needed for native package
creation/acquisition. SSH acquisition, registry/version-range solving and SDK
self-update remain outside this release.

## Separate runtime bundles in 1.0.4

Extract the required OS/CPU or CPU/ABI bundle outside the project. Point package.yaml
dependencies at packages/<name>/package.yaml, keeping all runtime packages from the
same bundle together. Native SDK imports continue to use implicit runtime lookup.
Cross consumers explicitly select the runtime bundle; a host SDK does not silently
substitute its native libraries for another target.

Freestanding RV64IMAC/LP64 uses --package-profile rv64imac-lp64 plus matching
CPU/features/ABI options. RV64GC/LP64D uses its separate rv64gc-lp64d profile.
The bundle version is 1.0.4; individual package versions remain independently versioned.
