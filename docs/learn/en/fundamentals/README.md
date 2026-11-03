# Foundations: from statements to type design

[中文](../../fundamentals/README.md) · [Course index](../README.md)

Complete [platform setup](../00-start.md) first, then follow this route. “C-level foundations” means learning statements, data and functions first, not substituting C spelling for Nyra.
The first eight lessons build foundations; the remainder introduce data modeling and behavior contracts. No prior generics, allocators or async background is needed.

## How to use each lesson

1. Read its goals and syntax, then predict the first program’s output.
2. Replace the exercise package’s entire main.ny with one complete program. Keep the package.yaml and environment from lesson 00.
3. Check and run using these commands. Repair failed compilation before running an old executable.
4. Compare expected output and read the explanation. Change one input at a time.
5. Try the exercise, then expand its complete answer. Answers compile independently without missing declarations.

```sh
"$NYRAC" check "$NYRA_WORK/playground/main.ny"
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/fundamentals"
```

Windows PowerShell:

```powershell
& $env:NYRAC check "$env:NYRA_WORK/playground/main.ny"
& $env:NYRAC run "$env:NYRA_WORK/playground/main.ny" --out-dir "$env:NYRA_WORK/out/fundamentals"
```

Each example also provides main.ny, package.yaml and expected.txt through its source link. For an independent run, place those files in one directory and run its main.ny. Do not combine these examples as module parts.

Use the complete released SDK 1.0.5 for this route’s foundational forms and does not require development init, super, @override, cascade or constexpr-method additions. A version stamp alone does not establish availability. Expected output is a teaching contract, not SDK qualification evidence. Do not import C ownership or Java virtual-method assumptions.

## Stage 1: statements, data and functions

1. [01 · Read a program from its first output](01-program.md)
2. [02 · Variables, types, assignment and scope](02-values.md)
3. [03 · Arithmetic, comparisons and expressions](03-operators.md)
4. [04 · If, else, switch and early returns](04-conditions.md)
5. [05 · Loops, ranges, break and continue](05-loops.md)
6. [06 · Functions, parameters, returns and borrows](06-functions.md)
7. [07 · Local arrays, indexing and strings](07-arrays.md)
8. [08 · Borrows, addresses and unsafe boundaries](08-addresses.md)

## Stage 2: structs, methods and layout extension

9. [09 · Structs: fields, literals, nesting and values](09-struct-data.md)
10. [10 · Instance methods: behavior belongs to its type](10-methods.md)
11. [11 · Static methods, values and named factories](11-creation.md)
12. [12 · Get/set: fields and controlled properties](12-properties.md)
13. [13 · Struct extends: layout extension and base methods](13-extends.md)

## Stage 3: interfaces and composition

14. [14 · Interfaces: define a capability, then implement it](14-interfaces.md)
15. [15 · Interface extension, delegation and composition](15-interface-design.md)

## After foundations

Continue with [ownership](../04-ownership.md), [dynamic containers](../05-collections.md), [errors](../06-errors.md), [modules/packages](../07-packages.md), and [generics/callbacks](../08-generics.md). Consult the [dictionary](../reference-keywords.md) and [type reference](../reference-types.md) for lookup alongside, rather than instead of, the sequential lessons.

Continue in order with [lessons 16–23: generics through Flow](../intermediate/README.md). Review Result/error alternatives before the async lessons.
