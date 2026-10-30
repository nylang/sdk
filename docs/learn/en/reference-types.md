# Types: structs, methods, factories, properties, interfaces and drop

[中文](../reference-types.md) · [Course index](README.md) · [Dictionary](reference-keywords.md)

Each complete program independently replaces `main.ny`; check and run it using
Lesson 00. Success returns 0; a nonzero return identifies a failed check.
Complete programs contain no placeholder implementations.

## 1. Definition locations and call forms

| Purpose | Definition form | Use | `self`? |
|---|---|---|---|
| Data | `struct Counter { current: int32; }` | `Counter{ current: 0 }` | No body |
| Instance behavior | `method(Counter) Add(n: int32) -> void` | `counter.Add(2)` | Yes |
| Type-level operation | `static method(Counter) Zero() -> Counter` | `Counter.Zero()` | No |
| Owned construction | `factory(Counter) Make(n: int32) -> unique<Counter>` | `Counter.Make(42)` | No |
| Read property | `method(Counter) get value -> int32` | `counter.value` | Yes |
| Write property | `method(Counter) set value(next: int32)` | `counter.value = 42` | Yes |
| Automatic cleanup | `method(Ticket) operator drop() -> void` | Compiler-inserted | Yes; not manually callable |

Define methods, factories and properties outside the struct. Interface member
signatures are written inside the interface. For cross-module public use, mark
both the relevant type and its offered operations `pub`; these single-module
programs omit that modifier.

## 2. Complete program: methods, static methods, factories, get/set and interfaces

```nyra
interface CounterView {
  Read() -> int32;
  get value -> int32;
  set value(next: int32) -> void;
}

struct Counter implements CounterView {
  current: int32;
}

method(Counter) Read() -> int32 {
  return self.current;
}

method(Counter) Add(amount: int32) -> void {
  self.current = self.current + amount;
}

method(Counter) get value -> int32 {
  return self.current;
}

method(Counter) set value(next: int32) {
  // Keep the property's invariant in one place.
  if next < 0 {
    self.current = 0;
    return;
  }

  self.current = next;
}

static method(Counter) Zero() -> Counter {
  return Counter{ current: 0 };
}

factory(Counter) Make(initial: int32) -> unique<Counter> {
  var result: unique<Counter> = new unique<Counter>{ current: 0 };
  result.value = initial;

  return move(result);
}

func read_counter(counter: CounterView) -> int32 {
  return counter.Read();
}

func main() -> int32 {
  var counter: Counter = Counter.Zero();
  counter.value = 40;
  counter.Add(2);

  if counter.value != 42 {
    return 1;
  }

  if read_counter(counter) != 42 {
    return 2;
  }

  let owned_counter: unique<Counter> = Counter.Make(42);
  if owned_counter.Read() != 42 {
    return 3;
  }

  return 0;
}
```

Read the checks as follows:

- `Counter` defines storage. `current` is the backing field; `value` is a property with logic. Different names avoid recursively invoking the accessor itself.
- `Add` changes an existing object; `self` is the `counter` on the left of the call. A caller changing a value uses `var`.
- `Counter.Zero()` is a static method returning an ordinary value. It cannot access a nonexistent `self`.
- `Counter.Make()` is a named factory returning `unique<Counter>`: allocate, establish the invariant through the setter, then transfer the result.
- Factories return `unique`, `rc` or `arc` owners. A convenience operation returning an ordinary value uses `static method`; do not write `static factory`.
- A getter has no parameter parentheses; a setter takes one value. Read `counter.value`, not `counter.value()`. Assign the property instead of calling `set` manually.
- `CounterView` gives full method, getter and setter signatures. `implements` declares the contract; `read_counter` calls through that contract.

A setter does not automatically prevent code with visible layout from writing
`current` directly. Libraries hiding layout should design `.ni` public declarations
and private implementations: see [modules](reference-modules.md).

## 3. Duplicate names, overloading and naming

Ordinary method names must be unique for one receiver type: parameter counts,
parameter types and return types do not create overload slots. Do not give static
and instance methods the same ordinary name either. Prefer meaningful alternatives
such as `Add` and `AddWide`. Different types may each define `Read`.
A getter and setter may share one property name: they are distinct accessor slots,
not two overloaded ordinary methods. Give factories distinct named entry points
such as `Make` and `FromBytes`, rather than parameter-based overloads.

Intentionally invalid declaration fragment, separate from the complete program:

```nyra
// Intentionally invalid: parameter types do not create overload slots.
method(Counter) Add(amount: int32) -> void {
  self.current = self.current + amount;
}

method(Counter) Add(amount: int64) -> void {
  self.current = self.current + (amount as int32);
}
```

Methods/factories use `UpperCamelCase`; fields, parameters, locals and properties
use `snake_case`. Operators retain their language spelling: `operator drop` is
not an alternative spelling for an ordinary `Drop` method.

## 4. Struct `extends`: layout extension

Complete program:

```nyra
struct Position {
  x: int32;
  y: int32;
}

struct ColoredPosition extends Position {
  color: int32;
}

method(ColoredPosition) Sum() -> int32 {
  return self.x + self.y;
}

func main() -> int32 {
  let point: ColoredPosition = ColoredPosition{ x: 20, y: 22, color: 7 };
  if point.Sum() != 42 {
    return 1;
  }

  return 0;
}
```

The derived layout includes `x` and `y` and adds `color`. A struct has at most one
struct base. This is not a C++/Java virtual-class model: do not infer virtual
methods, constructor chains or arbitrary subtype conversions. Use interfaces for
runtime behavior contracts; use composition when a field expresses the relationship.

Omitted literal fields receive zero/nil initialization. A literal does not
implicitly invoke a factory: `Counter{}` calls neither `Counter.Make()` nor a
method named `Init`.

## 5. Interfaces and interface extension

Complete program:

```nyra
interface Scored {
  Score() -> int32;
}

interface Ranked extends Scored {
  Rank() -> int32;
}

struct ResultCard implements Ranked {
  points: int32;
}

method(ResultCard) Score() -> int32 {
  return self.points;
}

method(ResultCard) Rank() -> int32 {
  return 1;
}

func total(card: Ranked) -> int32 {
  return card.Score() + card.Rank();
}

func main() -> int32 {
  let card: ResultCard = ResultCard{ points: 41 };
  if total(card) != 42 {
    return 1;
  }

  return 0;
}
```

`Ranked extends Scored` includes the base requirements. `ResultCard implements Ranked`
must provide both operations. Interface bodies contain signatures, not implementations
or stored fields. Section 2 demonstrates fully typed property requirements.
This example uses one parent interface and does not promise a multiple-parent or
diamond-interface model.

## 6. Delegate: explicitly forward a field's behavior

Complete program:

```nyra
interface Scored {
  Score() -> int32;
}

struct ScoreCard implements Scored {
  points: int32;
}

method(ScoreCard) Score() -> int32 {
  return self.points;
}

struct ScorePanel {
  card: ScoreCard;
  delegate card : Scored;
}

func read_score(value: Scored) -> int32 {
  return value.Score();
}

func main() -> int32 {
  let panel: ScorePanel = ScorePanel{ card: ScoreCard{ points: 42 } };
  if read_score(panel) != 42 {
    return 1;
  }

  return 0;
}
```

`ScorePanel` forwards `Scored` to `card`; it does not inherit every `ScoreCard` API.
The field must exist and satisfy the interface. Explicit wrapper methods take
precedence over forwarded methods. Resolve ambiguities if multiple fields forward
the same operation; delegation is not unconstrained textual inclusion.

<a id="drop"></a>
## 7. Drop: language-triggered cleanup

Complete program:

```nyra
static gDropCount: int32 = 0;

struct Ticket {
  id: int32;
}

method(Ticket) operator drop() -> void {
  // Observe cleanup without introducing a manual heap API.
  gDropCount = gDropCount + 1;
}

func use_ticket() -> void {
  let ticket: Ticket = Ticket{ id: 42 };
  assert(ticket.id == 42);
}

func main() -> int32 {
  use_ticket();
  if gDropCount != 1 {
    return 1;
  }

  return 0;
}
```

After `use_ticket` returns, compiler-inserted cleanup has incremented the count to 1.
The single-threaded counter observes cleanup; it is not a recommendation to use
shared mutable globals in application design.

Drop runs at cleanup points such as the end of an owning value's lifetime. After
`move`, the source is no longer cleaned up as the old owner. After user drop returns,
fields still undergo reverse-order language cleanup: do not free an owning field
a second time. Ordinary strings, containers and `unique`/`rc`/`arc` owners rely on
language cleanup, without an additional caller `Free` protocol.
Do not call `operator drop` manually. `delete` is not a manual release statement.

A resource type also needs a deliberate copy/move policy. Declaration fragment
that disables copying:

```nyra
method(Ticket) operator copy() -> Ticket = delete;
```

This disables copying, not cleanup. Do not define copy/move operators without
understanding the ownership-transfer protocol.

## Exercise

Add `Counter.Reset()` using `self.value = 0` to reuse the setter. Check that
`Counter.Make(-1)` reads as 0. Explain why `Zero()` and `Make()` are both called on
the type but have different return contracts. Then move the interface into its own
module and mark its public declarations `pub`.
