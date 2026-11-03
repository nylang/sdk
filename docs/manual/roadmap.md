# Public documentation and help manuals

## Scope and ownership

This plan extends the public-documentation responsibility of the public release documentation workstream.
It does not change language contracts, release cadence or SDK acceptance gates.
Compiler/tool implementation stays private. Public documentation may use shipped
runtime declarations, public SDK metadata and deliberately authored examples.

Maintain three different reading modes:

- Tutorials teach one dependency-ordered concept at a time, with complete programs,
  predicted output, explanation, mistakes, an exercise and an independent answer.
- The language manual defines syntax, meaning, admissibility, ownership and
  diagnostics by feature; it links to tutorial prerequisites without repeating
  every lesson or replacing the binding design documents.
- Kernel/stdlib manuals organize public capabilities by user task, then describe
  each type/member contract. A symbol search result is not an API contract page.

The [manual entry](../manual/README.md) defines the information architecture.
The [API lookup guide](../manual/api-lookup.md) distinguishes source declarations
from serialized barrel metadata. Runtime package maintainers own semantic accuracy;
tutorial maintainers own pedagogical progression; documentation tooling owns
stable identities, search, links and version selection. One glossary and one
canonical contract page per symbol avoid divergent copied specifications.

## D0 — Navigation and baseline

Provide tutorial, language, kernel, stdlib, task and symbol entry points. Bind
examples and API descriptions to an explicit published SDK version/profile.
Distinguish kernel ownership from stdlib re-exports. Development syntax must have
its own availability notice; planned relocation does not rewrite older SDKs.

Exit requirements: every entry resolves locally and in public Markdown; examples
state their environment, and unsupported/defective forms are visibly labelled.
Keep run records outside docs. Do not attach this work to a new SDK release.

## D1 — Complete the teaching sequence

Continue foundations with generic functions/types/constraints, function values,
lambda captures, defined enable variadics, iterator state, sync generators,
async/await, Promise/Future errors and async generators/Flow. Each lesson separates
syntax, caller/callee roles, state, ownership and failure. Teach range loops,
Iterable, one Future and Flow as distinct contracts.

Next coverage passes include enums/aliases, variants and exhaustive handling,
optional/error propagation, consuming parameters, operator/copy/move/drop rules,
module visibility and binary faces, allocator scopes, C ABI boundaries and
feature-qualified conveniences. Reuse existing lessons where complete; split
conflated topics instead of duplicating a second course.

Exit requirements: downloadable programs match both translations and their exact
expected output; negative examples state why they are invalid. A compiler defect
keeps a positive regression and a visible limitation, never an invented workaround.

## D2 — Language manual

For each feature provide: grammar with explained placeholders; context and typing;
name resolution; evaluation order; ownership/lifetimes; failure/diagnostics;
minimal and combined examples; legal/illegal contrasts; version/mode restrictions;
related concepts. Cover declarations, values, expressions, control flow, calls,
structs, interfaces, generics, packs, closures, ownership, generators, async,
modules/packages, metadata and C interop. Link binding design rather than silently
redefining it. Keep implementation internals out of beginner task flows.

## D3 — Kernel and stdlib API contracts

Inventory each selected SDK public barrel and exported declaration/source graph.
Do not scan every private provider face and call all discovered symbols public.
Include interface members and open-generic operations that may be absent from a
barrel's serialized name map. Record gaps in retained data, not generated reports
inside the human manual.

Author the high-use families first: scalar/checked arithmetic, alignment/ranges,
bytes/text/borrows, allocators, iteration/results, atomics/async protocols; then
hosted strings/encoding, collections, console, files/paths, process/system,
time/threads/synchronization, Future/Flow and profiling.

Every member page follows the [contract format](../manual/api-page-format.md).
A page must include exact declaration, owner/import, parameters/defaults,
ownership/mutation, returned-view lifetime, failure behavior, thread/platform
requirements, complexity/allocation, examples and related operations. Preserve
raw-memory hazard spellings; ordinary ownership is language-managed cleanup.

Exit requirements: a reader can choose the correct operation, use it safely and
recognize failure without reading private source. Searchable signatures alone do
not satisfy this gate. Complete coverage is a later documentation task, not a
claim made by adding category indexes.

## D4 — API search and help delivery

Start with offline public-barrel metadata lookup in a user-selected SDK/profile,
plus source navigation for exact declarations. Print its limitations explicitly:
interface members, variadic/default flags and documentation may require the
shipped public sources. Never synthesize a source signature from lossy metadata.

Then build a versioned canonical symbol model using the supported native
frontend/export graph and documentation comments. Preserve generic owner,
member kind, getter/setter/operator identity, parameter modes, defaults,
constraints, origin/re-export, availability and documentation tags. Reject
ambiguous or missing identities instead of silently inventing rows.

From that shared model produce alphabetical/category search, member pages,
version/mode filters and downloadable offline help. Online UI, IDE hover/help and
CLI help should use the same identities; do not maintain independent invented
API databases. Search infrastructure changes need focused schema, visibility,
re-export, overload/accessor, link and accessibility tests.

## D5 — Publication and maintenance

Publish documentation without compiler sources or private face inventories.
Keep tutorials bilingual; maintain English canonical API reference and add
translations with linked identities rather than divergent contracts. Declare the
reference SDK and distinguish source-development features from published ones.

Documentation gates include Markdown links/anchors, source-example identity,
focused execution, platform/ownership review and API lookup controls. A native
example run does not attest other hosts, devices, freestanding startup or SDK
qualification. Reuse unchanged acceptance; no new bootstrap generations or full
SDK suite is authorized by documentation work.
