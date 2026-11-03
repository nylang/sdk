# 19 · Iterable and Iterator: the cursor protocol

[中文](../../intermediate/19-iterators.md) · [Previous](18-variadics.md) · [Stage index](README.md) · [Next](20-sync-generators.md)

## Goals

Expand the three operations behind for, verify independent cursors, then implement a countdown cursor. A sequence and its iterator have different responsibilities.

## Syntax and contracts

Iterable<T>.Enum() returns a fresh Iterator<T> before its first element. Read Current only after MoveNext returns true. False means exhaustion; Current is not an optional next operation. Keep the source alive and avoid invalidating storage during traversal.

## Example 1: expand traversal manually

[Source](../../examples/intermediate/iterator-manual/main.ny) · [package.yaml](../../examples/intermediate/iterator-manual/package.yaml) · [expected.txt](../../examples/intermediate/iterator-manual/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func numbers() -> Array<int32> {
  var items: Array<int32> = Array<int32>{};
  items.Push(10);
  items.Push(20);
  items.Push(12);

  return items;
}

func main() -> int32 {
  let items: Array<int32> = numbers();
  var cursor: Iterator<int32> = items.Enum();
  var total: int32 = 0;
  while cursor.MoveNext() {
    total = total + cursor.Current();
  }

  Console.Println("total={0}", total);

  return 0;
}
```

Expected output:

```text
total=42
```

Enum does not pre-consume an item. The first successful advance exposes 10. For-in uses this protocol rather than requiring array indexing.

## Example 2: independent cursor positions

[Source](../../examples/intermediate/iterator-independent/main.ny) · [package.yaml](../../examples/intermediate/iterator-independent/package.yaml) · [expected.txt](../../examples/intermediate/iterator-independent/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func numbers() -> Array<int32> {
  var items: Array<int32> = Array<int32>{};
  items.Push(10);
  items.Push(20);
  items.Push(12);

  return items;
}

func main() -> int32 {
  let items: Array<int32> = numbers();
  var first: Iterator<int32> = items.Enum();
  var second: Iterator<int32> = items.Enum();
  if !first.MoveNext() || !second.MoveNext() {
    return 1;
  }

  Console.Println("first={0}, second={1}", first.Current(), second.Current());
  if !first.MoveNext() {
    return 2;
  }

  Console.Println("next={0}, other={1}", first.Current(), second.Current());

  return 0;
}
```

Expected output:

```text
first=10, second=10
next=20, other=10
```

Each Enum creates a separate position. Advancing first leaves second unchanged; this says nothing about unsynchronized cross-thread sharing.

## Example 3: implement state and validity

[Source](../../examples/intermediate/iterator-custom/main.ny) · [package.yaml](../../examples/intermediate/iterator-custom/package.yaml) · [expected.txt](../../examples/intermediate/iterator-custom/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Countdown implements Iterator<int32> {
  next: int32;
  current: int32;
  valid: bool;
}

method(Countdown) MoveNext() -> bool {
  if self.next <= 0 {
    self.valid = false;
    return false;
  }

  self.current = self.next;
  self.next = self.next - 1;
  self.valid = true;

  return true;
}

method(Countdown) Current() -> int32 {
  assert(self.valid);

  return self.current;
}

func main() -> int32 {
  var cursor: Countdown = Countdown{ next: 3, current: 0, valid: false };
  while cursor.MoveNext() {
    Console.Println("{0}", cursor.Current());
  }

  return 0;
}
```

Expected output:

```text
3
2
1
```

Valid encodes Current’s precondition and resets at exhaustion. The type declares Iterator<int32>. It is one cursor, not an Iterable that creates fresh cursors.

## Common mistakes and boundaries

Do not call Current before advancement or after exhaustion, or rename the protocol to next() and expect for-in to recognize it. Creating and advancing a cursor are separate operations.

## Exercise

Start Countdown at 5 and sum rather than printing each item.

<details>
<summary>Complete answer</summary>

[Source](../../examples/intermediate/iterator-answer/main.ny) · [package.yaml](../../examples/intermediate/iterator-answer/package.yaml) · [expected.txt](../../examples/intermediate/iterator-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Countdown implements Iterator<int32> {
  next: int32;
  current: int32;
  valid: bool;
}

method(Countdown) MoveNext() -> bool {
  if self.next <= 0 {
    self.valid = false;
    return false;
  }

  self.current = self.next;
  self.next = self.next - 1;
  self.valid = true;

  return true;
}

method(Countdown) Current() -> int32 {
  assert(self.valid);

  return self.current;
}

func main() -> int32 {
  var cursor: Countdown = Countdown{ next: 5, current: 0, valid: false };
  var total: int32 = 0;
  while cursor.MoveNext() {
    total = total + cursor.Current();
  }

  Console.Println("total={0}", total);

  return 0;
}
```

Expected output:

```text
total=15
```

The accumulator and cursor position own separate state.

</details>

[Previous](18-variadics.md) · [Stage index](README.md) · [Next](20-sync-generators.md)
