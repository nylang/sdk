# Nyra SDK

Official binary SDK distributions for the Nyra programming language.

Download **[Nyra SDK 1.0.0](https://github.com/nylang/sdk/releases/tag/v1.0.0)**
for macOS arm64, Linux x86_64 or Windows x86_64. Each archive includes ten target
runtime profiles. See [INSTALL.md](INSTALL.md) for host requirements and scope.
Release assets include SHA256SUMS, per-host metadata and the full acceptance
summary. Distribution signing is explicitly recorded as `not-attested`.

## Contents

- `nyrac`: the Nyra compiler, with LLVM statically linked.
- `nyra-analyzer`: the analyzer and language server.
- The pinned LLVM developer tools, headers and static libraries.
- Precompiled kernel, standard library, JSON and YAML packages.
- Public interfaces and generic/inline recipes required by SDK consumers.
- File inventories, package locks, component licenses and acceptance summaries.

Compiler, frontend and analyzer implementation sources are proprietary and are
not distributed in this repository. This repository contains public SDK
documentation and release metadata; SDK archives are release assets.

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
may evolve under their own versions. Kernel and stdlib are 1.0.0 in the initial
SDK; JSON is 0.19.0 and YAML is 0.18.0. Use the SDK manifest and package lock for
the exact accepted combination.
