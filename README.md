# Nyra SDK

Official binary distributions of the Nyra programming language.

Download [Nyra SDK 1.1.2](https://github.com/nylang/sdk/releases/tag/v1.1.2).
Each native SDK includes nyrac, nyra-analyzer, nyra, pinned LLVM and its native runtime.

## Learn Nyra

Start with the [English foundations course](docs/learn/en/fundamentals/README.md)
or [中文基础课程](docs/learn/fundamentals/README.md): 23 sequential lessons and
92 complete mainline example/answer packages, plus two labelled SDK-limited
protocol references, from basic statements through structs, methods,
factories, properties, extends, interfaces, generics, lambdas, variadics, iterators
and async/Flow. See the [help manuals](docs/manual/README.md) for language, kernel,
stdlib and offline API lookup. The [full course](docs/learn/en/README.md)
also covers ownership, containers, packages, tests and integration topics.


## Desktop SDKs

- [darwin-arm64](https://github.com/nylang/sdk/releases/download/v1.1.2/nyra-sdk-1.1.2-darwin-arm64.tar.gz)
- [darwin-x86_64](https://github.com/nylang/sdk/releases/download/v1.1.2/nyra-sdk-1.1.2-darwin-x86_64.tar.gz)
- [linux-x86_64 candidate](https://github.com/nylang/sdk/releases/download/v1.1.2/nyra-sdk-1.1.2-linux-x86_64-candidate.tar.gz). Cross-compiled on macOS and validated on AlmaLinux 10. [Linux x86_64 1.0.5](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-sdk-1.0.5-linux-x86_64.tar.gz) has native G1/G2 qualification.
- [windows-x86_64](https://github.com/nylang/sdk/releases/download/v1.1.2/nyra-sdk-1.1.2-windows-x86_64.zip)

## Runtime packages from 1.1.2

- [RISC-V RV64IMAC/LP64 kernel](https://github.com/nylang/sdk/releases/download/v1.1.2/nyra-runtime-1.1.2-kernel-rv64imac-lp64.tar.gz)
- [RISC-V RV64GC/LP64D kernel](https://github.com/nylang/sdk/releases/download/v1.1.2/nyra-runtime-1.1.2-kernel-rv64gc-lp64d.tar.gz)
- [Linux RISC-V RV64GC/LP64D](https://github.com/nylang/sdk/releases/download/v1.1.2/nyra-runtime-1.1.2-stdlib-linux-riscv64.tar.gz)
- [Android arm64 and x86_64](https://github.com/nylang/sdk/releases/download/v1.1.2/nyra-runtime-1.1.2-stdlib-android.tar.gz)
- [iOS device and simulator](https://github.com/nylang/sdk/releases/download/v1.1.2/nyra-runtime-1.1.2-stdlib-ios.tar.gz)

[Runtime checksums](https://github.com/nylang/sdk/releases/download/v1.1.2/SHA256SUMS-runtimes)

## Runtime packages from 1.0.5

- [kernel-ntest-rv64imac-lp64](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-runtime-1.0.5-kernel-ntest-rv64imac-lp64.tar.gz): rv64imac-lp64
- [kernel-ntest-rv64gc-lp64d](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-runtime-1.0.5-kernel-ntest-rv64gc-lp64d.tar.gz): rv64gc-lp64d
- [kernel-ntest-arm64](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-runtime-1.0.5-kernel-ntest-arm64.tar.gz): none-arm64
- [kernel-ntest-x86_64](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-runtime-1.0.5-kernel-ntest-x86_64.tar.gz): none-x86_64
- [stdlib-macos](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-runtime-1.0.5-stdlib-macos.tar.gz): darwin-arm64, darwin-x86_64
- [stdlib-windows](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-runtime-1.0.5-stdlib-windows.tar.gz): windows-x86_64, windows-arm64
- [stdlib-linux-glibc](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-runtime-1.0.5-stdlib-linux-glibc.tar.gz): linux-x86_64, linux-arm64, linux-riscv64
- [stdlib-linux-musl](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-runtime-1.0.5-stdlib-linux-musl.tar.gz): linux-musl-x86_64, linux-musl-arm64
- [stdlib-android](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-runtime-1.0.5-stdlib-android.tar.gz): android-arm64, android-x86_64
- [stdlib-ios](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-runtime-1.0.5-stdlib-ios.tar.gz): ios-arm64, ios-simulator-arm64, ios-simulator-x86_64

Declare runtime dependencies through packages/<name>/package.yaml; manifests select target leaves. CPU/ISA, ABI and object format must match. Freestanding kernel/ntest require consumer-owned providers.

Native qualification covers G1/G2 identity and the complete G2 suites once, plus bootstrap-built tool units once. Publication preserves accepted bytes. Runtime execution/compile-only levels are recorded per target. macOS x86_64 currently uses Rosetta. Compile-only does not establish runtime execution or a linked host SDK.

[Installation](INSTALL.md), [1.1.2 release notes](https://github.com/nylang/sdk/releases/tag/v1.1.2), [1.0.5 acceptance](ACCEPTANCE-1.0.5.json), [license](LICENSE.txt).
