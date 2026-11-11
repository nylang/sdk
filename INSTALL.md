# Install Nyra SDK

Download the archive matching your host from the [release](https://github.com/nylang/sdk/releases/tag/v1.1.2). Check its SHA-256 against SHA256SUMS, extract it, and add hosts/<host>/bin to PATH. Keep the full directory together so tools can resolve LLVM and packages.

The 1.0.5 release provides the separate runtime archives listed in [README.md](README.md#runtime-packages-from-105). Their package roots are packages/kernel/package.yaml, packages/ntest/package.yaml and, for hosted targets, packages/stdlib/package.yaml. Preserve the archive layout when moving it. amd64 is x86_64; aarch64 is arm64.

macOS tools require macOS 14 or newer; Intel execution currently uses Rosetta qualification. Binaries are not Developer ID signed/notarized. Compile-only target evidence does not prove execution. Windows ARM64 consumer linking needs the matching MSVC static CRT.
