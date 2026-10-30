# Language dictionary: keywords, types and contextual words

[中文](../reference-keywords.md) · [Course index](README.md)

Look up a word by its job. Keywords are case-sensitive and lowercase.
`Console`, `Array`, `Result` and `AssertTrue` are library names, not keywords.
Reserved words, contextual spellings and built-in operations are distinguished below:
a recognized spelling is not valid in every position. Future designs and arbitrary
`@names` are not presented as available SDK features.

## Modules and visibility

| Word | Purpose / minimal form | Lesson |
|---|---|---|
| `module` | `module Prices;` names one TU, not a package | [Modules](reference-modules.md) |
| `part`, `of` | Main: `part "private/math.ny";`; child: `part of Prices;`, in the same TU | [Modules](reference-modules.md) |
| `import` | `import "prices.ny";` uses another module's public surface | [Lesson 07](07-packages.md) |
| `export` | `export "prices.ny";` re-exports another module's public surface | [Modules](reference-modules.md) |
| `pub` | `pub struct Price`, `pub method(Price) Total()` permit cross-module use | [Types](reference-types.md) |
| `as` | Import alias: `import "prices.ny" as prices;`; conversion: `value as int64` | [Modules](reference-modules.md) |
| `show`, `hide` | Include/exclude public names on an import/export edge; cannot mix on one directive | [Modules](reference-modules.md) |
| `namespace` | Organizes names; creates neither a TU nor a package | [Modules](reference-modules.md) |

## Declarations, types and behavior

| Word | Purpose / form | Important detail |
|---|---|---|
| `let`, `var` | Non-reassignable / reassignable local binding | `let n: int32 = 1;`; not ownership kinds |
| `const` | Generic constant parameter such as `const N: uintptr` | Not a replacement for a local value declaration |
| `static` | Global storage, or a type-level `static method(T)` | Static methods have no `self` |
| `readonly` | Readonly fields; `readonly static` global storage | Does not deeply freeze pointer targets |
| `func` | Function definition: `func main() -> int32` | Use `method` for receiver behavior |
| `method` | `method(Counter) Add(n: int32) -> void` | Defined outside the struct; no parameter-based overloads on one receiver |
| `factory` | `factory(Counter) Make(...) -> unique<Counter>` | Called as `Counter.Make(...)`; no `self` or `static factory` |
| `operator` | Operator method, e.g. `method(T) operator drop() -> void` | Neither a free function nor a static operator |
| `get`, `set` | `method(T) get value -> int32` / `set value(v: int32)` | Use `obj.value` / `obj.value = 42`, without call parentheses |
| `struct` | Named field layout and value type | Define methods and factories separately |
| `extends` | One base layout for a struct; interface extension for an interface | Not virtual class inheritance |
| `interface` | Contract of method/property signatures | Signatures end in `;`, without implementation bodies |
| `implements` | Explicit interface implementation on a struct | Matching names alone do not declare the interface contract |
| `delegate` | `delegate field : Iface;` forwards interface operations to a field | Resolve ambiguities explicitly |
| `enum` | Named constant alternatives | Distinct from payload-carrying `variant` |
| `union` | C-style overlapping storage | Does not track an active alternative as `variant` does |
| `variant` | Sum type carrying different data types | Use operations such as `holds<T>()`, `get_if<T>()` and `visit` |
| `typedef` | Alias: `typedef Count = int32;` | Does not create an independent new type |
| `tuple` | Temporary grouped values: `tuple<int32, int32>` | Destructure with `let (a, b) = pair;` |
| `lambda` | Callback: `lambda [copy x] (...) -> R { ... }` | Spell capture modes; do not assume arbitrary borrow captures work |
| `concept` | Named generic constraint | [Lesson 08](08-generics.md) |
| `enable` | Constrained parameter channel, including formatting variadics | Not a Boolean switch or conditional-compilation directive |

See [complete programs for types, methods, factories, interfaces and drop](reference-types.md).

## Control flow and expressions

| Word | Purpose / form |
|---|---|
| `if`, `else` | Conditional branches: `if condition { ... } else { ... }` |
| `switch`, `case`, `default` | Value selection, without automatic fallthrough |
| `while` | Conditional loop |
| `for`, `in` | Iteration: `for item in items { ... }` |
| `break`, `continue` | Exit a loop / start its next iteration |
| `return` | Return from a function, method or factory |
| `scope` | `scope (region) { ... }` invokes a scope protocol; not an alias for a bare block |
| `unsafe` | Marks raw-pointer and other hazardous operations; does not make them safe |
| `assert` | Runtime hard assertion, controlled by assertion flags |
| `static_assert` | Compile-time assertion |
| `sizeof`, `alignof` | Query a type's size and alignment |
| `typeof` | Obtain an expression's type for a type position |
| `true`, `false` | Boolean literals |
| `nil` | Empty optional `T?`, not a universal integer or pointer zero |
| `async`, `await` | Async functions and waiting |
| `sync`, `yield` | `sync*` generators and yielded elements; `async*` is an async generator |
| `drive` | Drive an async call from a synchronous entry using a concrete executor |

See [control flow](02-control-functions.md), [concurrency](12-concurrency.md) and
[systems programming](13-systems.md).

## Ownership and borrowing

| Word | Purpose | Typical form |
|---|---|---|
| `owned` | Language ownership type constructor | Does not mean manual Free |
| `unique` | Unique owner | `new unique<Box>{ value: 42 }` |
| `rc`, `arc` | Reference-counted / atomic reference-counted owners | `rc<T>` / `arc<T>` |
| `weak` | Non-owning weak reference | Upgrade may fail |
| `ac` | Arena cell, with arena-managed lifetime | `ac<T>` |
| `ref` | Immutable borrow | `value: ref T` |
| `mut` | Mutable permission | `ref mut T`, `*mut T`, `&mut value` |
| `copy` | Explicit copy | `copy(value)`; may dispatch a copy operator |
| `move` | Explicit ownership transfer | `move(value)`; do not reuse the old owner |
| `new` | Create an object using ownership and allocator rules | `new unique<T>{ ... }`, or an explicit allocator form |

`ref^ T` combines existing `ref` and `^` tokens for a consuming parameter; it is
not a new pointer type. See [Lesson 04](04-ownership.md) and [drop](reference-types.md#drop).

## Built-in types

| Type word | Meaning |
|---|---|
| `int8`, `int16`, `int32`, `int64` | Fixed-width signed integers |
| `uint8`, `uint16`, `uint32`, `uint64` | Fixed-width unsigned integers; `uint8` is also a byte |
| `intptr`, `uintptr` | Target-dependent pointer-width integers |
| `float32`, `float64` | Floating-point numbers |
| `bool` | Boolean |
| `string` | String value, not a manually freed C string pointer |
| `symbol` | Symbol identity, e.g. `'ready`, distinct from a string |
| `void` | No result value |

Unsuffixed integers default to `int32`, floating-point literals to `float64`.
Compact suffixes include `42u64` and `1.5f`. `num` and `real` are constraint/inference
spellings, not field storage types.

## Contextual spellings and common confusions

| Spelling | Meaning |
|---|---|
| `self` | Current instance receiver; unavailable in static methods and factories |
| `drop` | Operator name in `operator drop`, not an ordinary standalone keyword call |
| `delete` | Suffix in `method(T) operator copy() -> T = delete;`; not a manual object-deletion statement |
| `constexpr` | Compile-time branch in `if constexpr`, also scalar compile-time value declarations; no arbitrary address-taking |
| `oneof`, `copyable`, `movable` | Generic constraint words, valid in their constraint positions |
| `holds`, `get_if`, `visit` | Member operations on types such as `variant`, not universal statements |
| `once` | Appears in older vocabulary designs; this course does not teach it as an available standalone statement |
| `@test`, `@inline`, etc. | Compiler metadata: see the [metadata dictionary](reference-metadata.md) |
| `@brief`, `@param`, `@returns` | Documentation tags inside `/** ... */`, not compiler attributes |
| `$` | Reserved for internal ABI joining, not a source identifier character or interpolation syntax |

Do not copy grammar placeholders such as `...` into complete programs.
A planned feature is not automatically available in a released SDK.
