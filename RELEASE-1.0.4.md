# Nyra SDK 1.0.4

Published from prequalified artifacts; no tool rebuild or complete-suite rerun is part of publication.

## Changes

- Native nyra new/init and VS Code entry points create applications/libraries safely.
- Portable Git dependencies, workspace pointers and locks work across moved/offline checkouts.
- Compiler fixes cover borrowed string indexing, generic method definitions and nested private layouts.
- Compiler/support modules have explicit ownership and operation boundaries.
- Ntest now borrows message bytes through a runner output provider, without a temporary message allocation or direct puts call.
- CPU/ABI freestanding bundles and OS/CPU hosted runtime bundles are separately downloadable.
- Bootstrap selection uses pinned archive URLs and hashes; default adoption follows publication.

## Scope

Native tool downloads: macOS arm64/x86_64, Linux x86_64 and Windows x86_64.
Ten separate runtime bundles cover eighteen profiles. Physical machines were used where
available, then simulators/emulators, then compilation-only evidence. The complete
compiler suites are reused; publication does not rebuild or rerun accepted tools.
The newly compiled host source worksets do not imply downloadable host executables.
See ACCEPTANCE-1.0.4.json for the exact execution level of each runtime target.

## Integrity

Release assets include SHA256SUMS, ACCEPTANCE.json, RELEASE-INDEX.json and per-host metadata.
Verify the archive before extraction. macOS tools retain ad-hoc signatures; Developer ID
signing/notarization and actual macOS 14 execution are not claimed.
