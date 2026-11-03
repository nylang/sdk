# Nyra help manuals

Use the [tutorials](../learn/README.md) to learn in order; use these manuals
to answer a specific language or API question. The public baseline is the complete
**SDK 1.0.5**. Development proposals and future package moves are not silently
applied to that version.

- [Language manual](language/README.md): feature-oriented syntax and behavior lookup.
- [Kernel manual](kernel/README.md): freestanding capabilities and ownership boundaries.
- [Stdlib manual](stdlib/README.md): hosted runtime capabilities and OS-facing APIs.
- [API lookup](api-lookup.md): search installed public metadata and locate exact declarations.
- [API page format](api-page-format.md): required contract information for each member.
- [Known limitations](known-limitations.md): reference/tool restrictions affecting examples.

A useful API answer explains the owner/import, exact callable shape, input and
result contracts, ownership, failure and platform restrictions. A matching name
or a raw face record alone is insufficient. Category entries below are navigation,
not a claim that every API already has a complete individual contract page.

Language keywords, runtime APIs and tool commands are separate concepts. For
example, `async*` is syntax, `Flow<T>` is a protocol, `AsyncFlow<T>.Collect` is a
hosted operation, and the metadata lookup script is documentation tooling.

The [manual development plan](roadmap.md) defines the
remaining language, per-member contract and shared search/help work. These
category entries do not imply full API contract coverage.
