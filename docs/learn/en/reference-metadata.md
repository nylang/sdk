# Metadata dictionary: where attributes go and what they do

[中文](../reference-metadata.md) · [Course index](README.md) · [Dictionary](reference-keywords.md)

## 1. Compiler attributes versus documentation tags

`@inline` and `@test(...)` are compiler attributes, valid on specific declarations
or syntax positions. Tags inside `/** @brief ... @param ... @returns ... */` document
an API; they do not change ABI or register tests. Familiar-looking annotations do
not become supported automatically, and attributes do not accept arbitrary keys.
The tables describe native syntax/contracts; distinguish released SDK capabilities
from newer source work. Complete examples are practice material; advanced protocol
entries require the corresponding lesson, not just copying one annotation.

## 2. Common attributes

| Form | Target | Purpose and restrictions |
|---|---|---|
| `@inline` | Function/method | Inline marker; does not change ownership/results. Generic bodies already follow inline instantiation rules; ordinary `.ni` bodies need inline |
| `@build_type("dev|test")` | Declaration or statement block | Keep when matching compiler --build-type; pipe separates build names, not a runtime condition |
| `@test` | Test function | Registers a unit test; stripped from ordinary builds; run with nyrac test |
| `@test(tag = "math")` | Test function | One string tag, filtered by --tag math; not a tag array |
| `@test(ignore = true)` | Test function | Skip unless --include-ignored is supplied |
| `@test(should_abort = true)` | Test function | Expect the test subprocess to abort; not permission for arbitrary failure |
| `@test(should_abort = true, abort_contains = "text")` | Test function | Also require an abort-message substring; abort_contains alone is invalid |
| `@profile(cpu, memory, tag = "work")` | Supported synchronous function/method | CPU/memory observation sites with --profile; not an automatic whole-program report; do not extend synchronous promises to async/generator bodies; [complete profiling example](14-compiler-tools.md#6-measure-a-synchronous-user-function) |
| `@extern("C")` | ABI function | C convention on a declaration or definition; does not acquire/link an external library |
| `@extern("C", api)` | Public C API | Header/import/export handling; distinct from export directives |
| `@extern("default")` | ABI function | Select default ABI, not C ABI |

## 3. Complete program: inline and build_type

```nyra
struct MathValue {
  value: int32;
}

@inline
method(MathValue) Double() -> int32 {
  return self.value + self.value;
}

func main() -> int32 {
  var expected: int32 = 42;
  @build_type("release") {
    expected = 42;
  }

  let value: MathValue = MathValue{ value: 21 };
  if value.Double() != expected {
    return 1;
  }

  return 0;
}
```

Default check/run returns 0. You can also add `--build-type release` to the Lesson 00
commands. Both configurations expect 42: the attribute controls whether a block
exists, rather than selecting a build type at runtime.

## 4. Complete test file

In a separate test exercise directory, use `name: metadata_tests` in `package.yaml`
and this `main.ny`:

```nyra
import "ntest:ntest.ny";

struct MathValue {
  value: int32;
}

method(MathValue) Double() -> int32 {
  return self.value + self.value;
}

@test(tag = "math")
func test_double() {
  let value: MathValue = MathValue{ value: 21 };
  AssertEqI32(value.Double(), 42);
}

@test(ignore = true)
func test_pending_example() {
  AssertTrue(true);
}

@test(should_abort = true)
func test_invalid_precondition() {
  assert(false);
}
```

Run:

```sh
"$NYRAC" test "$NYRA_WORK/metadata-tests/main.ny"
"$NYRAC" test "$NYRA_WORK/metadata-tests/main.ny" --tag math
```

The first command runs the ordinary and expected-abort tests, skipping the ignored
one. The second selects math. `AssertEqI32` is an ntest function; `assert` is a hard
language assertion. Do not disable assertions for the expected-abort example.
See [Lesson 10](10-tests-analyzer.md) for the broader workflow.

## 5. Static storage and embedded resources

| Form | Target | Purpose and boundary |
|---|---|---|
| `@singleton` | Static declaration | Singleton storage/access protocol; reads as ref T |
| `@lazy_singleton` | Static declaration | Lazy singleton, not a synonym for mutable static |
| `@thread_local_singleton` | Static declaration | One singleton per thread, not shared process-wide |
| `@thread_local` | Ordinary static declaration | Per-thread storage, constant initialization; cannot combine with singleton family |
| `@embed("payload.bin")` | Byte-array static | Embed at compile time, without an ordinary initializer |
| `@embed_text("message.txt")` | String static | Embed text at compile time, not runtime file I/O |
| `@embed_len(kBlob)` | Length expression | Embedded byte count, not an attribute on another declaration |

Complete two-file example: `message.txt` contains exactly the five ASCII bytes
`hello`, **without a final newline**. Put this `main.ny` beside it:

```nyra
@embed_text("message.txt")
static kMessage: string;

func main() -> int32 {
  if kMessage.length != 5 {
    return 1;
  }

  return 0;
}
```

Paths resolve relative to the declaring source file. Recompile to update embedded
content. An editor-added newline makes the length 6; do not confuse byte length
with a general character count.
Byte-embedding declaration fragment, requiring a real adjacent file:

```nyra
@embed("payload.bin")
static kBlob: <uint8>[];
```

## 6. Scope and allocator protocols

| Form | Target | Purpose and prerequisites |
|---|---|---|
| `@scoped` | Struct/interface | Enter/Exit protocol for scope(value), not a marker for an ordinary block |
| `@stack_scope` | Corresponding interface | Stack allocator Mark/Reset protocol; cannot combine with scoped |
| `@heap`, `@stack`, `@arena` | Allocator struct | Classify the allocator, not arbitrary business-object storage |
| `@global_heap(malloc: "alloc", realloc: "resize", free: "release")` | Dedicated hosted top-level declaration | Maps process heap entry points; requires matching ABI implementations; not an ordinary static modifier, not for .nk |

Complete scoped program:

```nyra
@scoped
struct Gate {
  depth: int32;
}

method(Gate) Enter() -> void {
  self.depth = self.depth + 1;
}

method(Gate) Exit() -> void {
  self.depth = self.depth - 1;
}

func main() -> int32 {
  var gate: Gate = Gate{ depth: 0 };
  scope (gate) {
    if gate.depth != 1 {
      return 1;
    }
  }

  if gate.depth != 0 {
    return 2;
  }

  return 0;
}
```

Depth is 1 inside and 0 afterward. Scope Enter/Exit and final object drop are distinct
protocols; executing Exit does not justify releasing an owning field twice.
See [Lesson 13](13-systems.md) for allocators.

## 7. Advanced/system attribute index

| Form | Target | Purpose and restrictions |
|---|---|---|
| `@driven(ExecutorType)` | Synchronous entry using drive | Pins a concrete executor type matching the argument's typeof; requires the full Executor protocol, [Lesson 12](12-concurrency.md) |
| `@builtin` / `@builtin("kind")` | Compiler-defined declaration | Intrinsic hook, not user plugin registration |
| `@exhaustive_specialization` | Corresponding generic function | Requires specialization coverage of oneof members, not a switch default replacement |
| `@extern("declare") Name<int32>;` | .ni specialization face | Exports a concrete generic specialization, not a bodyless open template |
| `@extern("implement") Name<int32>;` | .ny/.nk specialization implementation | This TU provides the matching concrete definition |
| `@irq_safe` | Concrete kernel-related function | Interrupt-effect checking; a foreign declaration alone does not prove its implementation |
| `@interrupt` | Kernel handler | Concrete synchronous function, no arguments or result, checked for interrupt safety; does not generate trap frames, vectors or a scheduler |

Minimal C API definition file, **library source rather than a main program**:

```nyra
@extern("C", api)
pub func NyraAnswer() -> int32 {
  return 42;
}
```

See [Lesson 15](15-c-interop.md) for compilation, generated headers and a linked C
consumer. An ABI annotation alone does not prove linking or target acceptance.

## 8. Older spellings and proposals not to copy

| Name | Treatment in this course |
|---|---|
| `@global_allocator` | Superseded by the complete dedicated @global_heap declaration |
| `@noinline`, `@rodata`, `@memory_trace`, `@no_trace` | Appear in older vocabulary designs, but current native parser paths do not offer general copyable forms; not runnable course attributes. Use readonly static for readonly globals; consult @profile for observation |
| `@packed`, `@align(N)` | Possible design extensions, not layout guarantees supplied by an existing SDK |
| Arbitrary invented `@name` | Not an automatic decorator system; check compiler support first |

Documentation comments may use `@brief`, `@param`, `@returns`, `@note` and `@warning`.
Keep those tags inside comments, rather than pretending they are compiler attributes.
Adding a dictionary row does not enable new language syntax.
