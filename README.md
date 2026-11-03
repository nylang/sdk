# Nyra SDK

Official binary distributions of the Nyra programming language.

Download [Nyra SDK 1.0.5](https://github.com/nylang/sdk/releases/tag/v1.0.5).
Each native SDK includes nyrac, nyra-analyzer, nyra, pinned LLVM and its native runtime.

## Learn Nyra

Start with the [English foundations course](docs/learn/en/fundamentals/README.md)
or [中文基础课程](docs/learn/fundamentals/README.md): 15 sequential lessons and
60 complete examples/answers, from basic statements through structs, methods,
factories, properties, extends and interfaces. The [full course](docs/learn/en/README.md)
also covers ownership, containers, packages, tests and integration topics.


## Native SDKs

- [darwin-arm64](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-sdk-1.0.5-darwin-arm64.tar.gz)
- [darwin-x86_64](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-sdk-1.0.5-darwin-x86_64.tar.gz)
- [linux-x86_64](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-sdk-1.0.5-linux-x86_64.tar.gz)
- [windows-x86_64](https://github.com/nylang/sdk/releases/download/v1.0.5/nyra-sdk-1.0.5-windows-x86_64.zip)

## Runtime packages

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

[Installation](INSTALL.md), [release notes](RELEASE-1.0.5.md), [acceptance](ACCEPTANCE-1.0.5.json), [license](LICENSE.txt).
