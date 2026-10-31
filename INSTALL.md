# Install Nyra SDK 1.0.5

Download the archive matching your host from the release. Check its SHA-256 against SHA256SUMS, extract it, and add hosts/<host>/bin to PATH. Keep the full directory together so tools can resolve LLVM and packages.

Additional targets use the separate runtime archives listed in README.md. Their package roots are packages/kernel/package.yaml, packages/ntest/package.yaml and, for hosted targets, packages/stdlib/package.yaml. Preserve the archive layout when moving it. amd64 is x86_64; aarch64 is arm64.

macOS tools require macOS 14 or newer; Intel execution currently uses Rosetta qualification. Binaries are not Developer ID signed/notarized. Compile-only target evidence does not prove execution. Windows ARM64 consumer linking needs the matching MSVC static CRT.
