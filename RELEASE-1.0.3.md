# Nyra SDK 1.0.3

Native desktop SDKs for macOS arm64, macOS x86_64, Linux x86_64 and Windows x86_64. Each archive contains only its corresponding desktop runtime target. SDK 1.0.2 remains available with its original eleven-profile cross-target catalog.

Includes nyra (native package manager), nyrac, nyra-analyzer, the LLVM developer toolkit, and kernel/ntest/stdlib 1.0.0. Workspace resolution, portable v2 locks, embedded Git acquisition, isolated caches and package distribution tools are included.

Known issue: the frozen compiler can reject portable Git-lock consumers by requiring an application pin for an SDK-internal kernel edge. The fix belongs to 1.0.4. Published HTTP/TLS Git consumers require corrected 1.0.4 tools.

Existing four-host qualification is reused for the exact accepted binaries and runtime archives. Publication does not rebuild or rerun acceptance. Native Intel Mac execution is accepted; actual macOS 14 execution is not claimed. No mobile/RISC-V execution or distribution-signing/notarization attestation is supplied.
