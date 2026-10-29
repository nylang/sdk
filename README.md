# Nyra SDK

Official binary distributions of the Nyra programming language.

Download [Nyra SDK 1.0.4](https://github.com/nylang/sdk/releases/tag/v1.0.4).
The native SDK includes nyrac, nyra-analyzer, nyra, pinned LLVM and the matching native runtime.

## Native SDK downloads

- [darwin-arm64](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-sdk-1.0.4-darwin-arm64.tar.gz)
- [darwin-x86_64](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-sdk-1.0.4-darwin-x86_64.tar.gz)
- [linux-x86_64](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-sdk-1.0.4-linux-x86_64.tar.gz)
- [windows-x86_64](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-sdk-1.0.4-windows-x86_64.zip)

## Runtime package downloads

- [nyra-runtime-1.0.4-kernel-ntest-rv64imac-lp64.tar.gz](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-runtime-1.0.4-kernel-ntest-rv64imac-lp64.tar.gz) — rv64imac-lp64
- [nyra-runtime-1.0.4-kernel-ntest-rv64gc-lp64d.tar.gz](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-runtime-1.0.4-kernel-ntest-rv64gc-lp64d.tar.gz) — rv64gc-lp64d
- [nyra-runtime-1.0.4-kernel-ntest-arm64.tar.gz](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-runtime-1.0.4-kernel-ntest-arm64.tar.gz) — none-arm64
- [nyra-runtime-1.0.4-kernel-ntest-x86_64.tar.gz](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-runtime-1.0.4-kernel-ntest-x86_64.tar.gz) — none-x86_64
- [nyra-runtime-1.0.4-stdlib-macos.tar.gz](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-runtime-1.0.4-stdlib-macos.tar.gz) — darwin-arm64, darwin-x86_64
- [nyra-runtime-1.0.4-stdlib-windows.tar.gz](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-runtime-1.0.4-stdlib-windows.tar.gz) — windows-x86_64, windows-arm64
- [nyra-runtime-1.0.4-stdlib-linux-glibc.tar.gz](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-runtime-1.0.4-stdlib-linux-glibc.tar.gz) — linux-x86_64, linux-arm64, linux-riscv64
- [nyra-runtime-1.0.4-stdlib-linux-musl.tar.gz](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-runtime-1.0.4-stdlib-linux-musl.tar.gz) — linux-musl-x86_64, linux-musl-arm64
- [nyra-runtime-1.0.4-stdlib-android.tar.gz](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-runtime-1.0.4-stdlib-android.tar.gz) — android-arm64, android-x86_64
- [nyra-runtime-1.0.4-stdlib-ios.tar.gz](https://github.com/nylang/sdk/releases/download/v1.0.4/nyra-runtime-1.0.4-stdlib-ios.tar.gz) — ios-arm64, ios-simulator-arm64, ios-simulator-x86_64

Each runtime bundle exposes packages/kernel/package.yaml and packages/ntest/package.yaml;
hosted bundles also expose packages/stdlib/package.yaml and its platform archive.
Dependencies point to these roots; manifests select target leaves. amd64 means x86_64,
and aarch64 means arm64. ARM32 and other deferred architectures are not included.

Kernel and ntest are OS-independent. Their native object artifacts still require matching
CPU/ISA, ABI and object format. NyraOS uses RV64IMAC/LP64, distinct from RV64GC/LP64D.
Ntest output and failure counters are supplied by the runner; freestanding startup,
memory and compiler helper requirements are explicit in provider-requirements.json.

## Acceptance

Four native tool SDKs retain their accepted compiler/tool bytes. Each compiler passed
G1/G2 identity, 503 regressions and 1,033 dependency/compiler units; analyzer/manager
passed 18/13 tool units. macOS x86_64 execution used Rosetta. Publication does not repeat these suites.

The 18 runtime rows comprise 12 executed rows (including Rosetta) and six compile-only rows.
Compile-only: Android arm64/x86_64, iOS device arm64/simulator x86_64, Windows arm64
and freestanding x86_64. Windows arm64 consumer linking requires its MSVC ARM64 CRT.
Linux arm64/riscv64 and Windows arm64 tool sources compile, but full executable SDKs
for those hosts are not included. See [acceptance](ACCEPTANCE-1.0.4.json),
[installation](INSTALL.md), [release notes](RELEASE-1.0.4.md) and [license](LICENSE.txt).
