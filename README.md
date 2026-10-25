# Nyra SDK

Official binary SDK distributions for the Nyra programming language.

The first stable **1.0.0** release is being prepared and is not published yet.
A version tag is published only after its native build and SDK acceptance gates
pass. Downloadable SDKs will appear on the [Releases](https://github.com/nylang/sdk/releases) page.

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
