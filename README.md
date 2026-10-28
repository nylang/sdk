# Nyra SDK

Official binary SDK distributions for the Nyra programming language.

Download **[Nyra SDK 1.0.2](https://github.com/nylang/sdk/releases/tag/v1.0.2)**
for macOS arm64, macOS x86_64, Linux x86_64 or Windows x86_64. Each archive
includes eleven target runtime profiles. See [INSTALL.md](INSTALL.md) for host requirements and scope.
Release assets include SHA256SUMS, per-host metadata and the full acceptance
scope. Version 1.0.2 fixes ARC owner lifetimes and variant-arm ownership checks,
adds implicit SDK runtime dependency resolution, and aligns compiler/analyzer
versions. All four host configurations passed clean-source three-generation
bootstrap, G2/G3 fixed-point, regression and unit gates. The macOS x86_64 tools
were executed through Rosetta; this release does not claim native Intel Mac
execution. macOS tools target macOS 14.0 or newer; execution on macOS 14
has not been accepted.
macOS binaries are ad-hoc signed, without Developer ID signing or notarization.

## Contents

- `nyrac`: the Nyra compiler, with LLVM statically linked.
- `nyra-analyzer`: the analyzer and language server.
- The pinned LLVM developer tools, headers and static libraries.
- Precompiled kernel, ntest and standard library packages.
- Public interfaces and generic/inline recipes required by SDK consumers.
- File inventories, package locks, component licenses and acceptance summaries.

Compiler, frontend and analyzer implementation sources are proprietary and are
not distributed in this repository. This repository contains public SDK
documentation, release metadata and binary packaging automation; SDK archives
are release assets. The packaging workflow reconstructs hash-checked binary
deltas from published artifacts and does not contain or compile the Nyra
compiler implementation.

## Install and use

See [INSTALL.md](INSTALL.md) for the directory layout, prerequisites, checksum
verification and a first program. Each release manifest is authoritative for
its exact host and target support. Do not infer support from an archive filename
or from historical development receipts.

## License

The SDK is free for personal and commercial use. Complete, unmodified official
SDKs may be redistributed. Applications created with the SDK may remain closed
source. See [LICENSE.txt](LICENSE.txt) and the component notices inside each
SDK archive. Independently licensed libraries and LLVM keep their own terms.

## Issues

Use this repository's [issue tracker](https://github.com/nylang/sdk/issues) for
SDK installation and compiler/analyzer defects. Include the SDK version, host,
target, exact command, diagnostics and a small reproducer. Do not attach private
source, credentials or signing keys.

## Compatibility policy

Language and compiler-pipeline capabilities are frozen for the 1.0–1.2
stabilization period. Fixes preserve the existing language contracts; libraries
may evolve under their own versions. Kernel, ntest and stdlib remain 1.0.0 in SDK 1.0.2.
JSON and YAML evolve independently at [nylang/json](https://github.com/nylang/json)
and [nylang/yaml](https://github.com/nylang/yaml); they are not SDK packages.
Their licenses remain in the SDK because the tools embed them. Compiler and
analyzer versions are 1.0.2 on all four hosts. Use the SDK manifest and package
lock for exact component versions.
