# Language manual: feature lookup

This entry organizes language questions independently of course order. Start
with the named lesson for examples; use the binding design in a source checkout
for formal details. Public readers need no compiler-source access.

## Values and execution

- Program entry, declaration/body/statement boundaries: foundations 01.
- Scalar types, literals, let/var, assignment and lexical scope: foundations 02.
- Arithmetic, conversions, comparisons, short-circuit logic and bit operations: foundations 03.
- Conditions, switch cases and early returns: foundations 04.
- While, half-open ranges, break/continue and nested loops: foundations 05.
- Positional/named parameters, return contracts and mutable borrows: foundations 06.
- Local arrays, bounds, strings and raw addresses: foundations 07–08.

## Types and abstraction

- Struct fields, aggregate initialization and composition: foundations 09.
- Instance receiver/self, mutation and method naming: foundations 10.
- Static methods, ordinary values, ownership-returning factories: foundations 11.
- Getter/setter signatures and invariants: foundations 12.
- Struct layout extension and static method resolution: foundations 13.
- Explicit interface conformance, properties and dispatch: foundations 14–15.
- Generic parameters, inference and numeric/interface constraints: continuation 16.
- Function values, lambda signatures and explicit capture: continuation 17.
- Defined enable channels, pack access/forwarding and C-varargs separation: continuation 18.

## Sequences and async

- Iterable/Iterator, fresh cursors and Current preconditions: continuation 19.
- Sync generators, yield/yield*, element result types: continuation 20.
- Async results, await, drive and concrete executor binding: continuation 21.
- Promise completion, pending versus failed results and propagation: continuation 22.
- Async generators, Flow collection and bounded-memory restrictions: continuation 23.

The [complete course index](../../learn/README.md) links these lessons.
The [keyword dictionary](../../learn/reference-keywords.md),
[type reference](../../learn/reference-types.md),
[module reference](../../learn/reference-modules.md) and
[metadata dictionary](../../learn/reference-metadata.md) provide direct lookup.

## Further language chapters

Consult the existing course chapters on ownership, errors, modules, tests and C
interop. Full manual entries should separately document aliases/enums/variants,
operators and deleted copy/move, consuming parameters, optional expressions,
allocator scopes, generic face/export rules and compile-time evaluation. Keep
version-specific development conveniences distinct from SDK 1.0.5 examples.
Do not infer arbitrary generic packs, borrowed lambda captures, struct virtual
methods, ambient event loops or await-for from familiar syntax in another language.
