# 20 · Sync generators: iterables with yield

[中文](../../intermediate/20-sync-generators.md) · [Previous](19-iterators.md) · [Stage index](README.md) · [Next](21-async-await.md)

## Goals

Having written a cursor, let sync* preserve suspension position and locals. Consume elements, pause/resume, then forward a subsequence with yield*.

## Syntax and contracts

The declared result int32 is the element type, not a final sum or an Iterable spelling. Calls produce an iterable using Enum/MoveNext/Current. Yield emits one element; yield* forwards a matching Iterable. Sync generators need no executor and cannot await.

## Example 1: consume with for

[Source](../../examples/intermediate/sync-for/main.ny) · [package.yaml](../../examples/intermediate/sync-for/package.yaml) · [expected.txt](../../examples/intermediate/sync-for/expected.txt)

```nyra
import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  for value in count_to(3) {
    Console.Println("{0}", value);
  }

  return 0;
}
```

Expected output:

```text
1
2
3
```

Each advance resumes after the previous yield rather than restarting the function.

## Example 2: zero elements still form a valid sequence

[Source](../../examples/intermediate/sync-empty/main.ny) · [package.yaml](../../examples/intermediate/sync-empty/package.yaml) · [expected.txt](../../examples/intermediate/sync-empty/expected.txt)

```nyra
import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  var count: int32 = 0;
  for value in count_to(0) {
    count = count + 1;
  }

  Console.Println("count={0}", count);

  return 0;
}
```

Expected output:

```text
count=0
```

The first MoveNext is false. The loop body never runs; do not invent a Current item for an empty sequence.

## Protocol reference: explicit pause/resume (SDK limitation)

**SDK 1.0.5 limitation:** this legal protocol example can fail lowering with a missing ArrayCursor.MoveNext implementation. It is not a directly runnable 1.0.5 example. Keep the source for protocol explanation and compiler repair verification. Use example 1’s for for the current exercise path; ordinary Array cursors in lesson 19 exercise a different path.

[Source](../../examples/intermediate/sync-resume/main.ny) · [package.yaml](../../examples/intermediate/sync-resume/package.yaml) · [expected.txt](../../examples/intermediate/sync-resume/expected.txt)

```nyra
import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  let sequence: Iterable<int32> = count_to(3);
  var cursor: Iterator<int32> = sequence.Enum();
  if !cursor.MoveNext() {
    return 1;
  }

  Console.Println("first={0}", cursor.Current());
  Console.Println("between");
  if !cursor.MoveNext() {
    return 2;
  }

  Console.Println("second={0}", cursor.Current());

  return 0;
}
```

Expected output:

```text
first=1
between
second=2
```

The caller can do synchronous work between pulls. No thread or async wait is introduced. Do not assume side effects of unconsumed elements already happened.

## Example 3: emit one value or forward several

[Source](../../examples/intermediate/sync-forward/main.ny) · [package.yaml](../../examples/intermediate/sync-forward/package.yaml) · [expected.txt](../../examples/intermediate/sync-forward/expected.txt)

```nyra
import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

sync* func with_tail(limit: int32) -> int32 {
  yield* count_to(limit);
  yield 42;
}

func main() -> int32 {
  for value in with_tail(2) {
    Console.Println("{0}", value);
  }

  return 0;
}
```

Expected output:

```text
1
2
42
```

Yield* forwards ordered elements, not the Iterable object itself. An empty subsequence contributes none and execution continues afterward.

## Common mistakes and boundaries

Yield needs a generator context; await needs async. Declaring an Array result does not request collection. Consumer exit does not require producing the remaining elements.

## Exercise

Sum count_to(0) and count_to(3), observing the empty sequence.

<details>
<summary>Complete answer</summary>

[Source](../../examples/intermediate/sync-answer/main.ny) · [package.yaml](../../examples/intermediate/sync-answer/package.yaml) · [expected.txt](../../examples/intermediate/sync-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  var total: int32 = 0;
  for value in count_to(0) {
    total = total + value;
  }

  Console.Println("empty={0}", total);
  for value in count_to(3) {
    total = total + value;
  }

  Console.Println("total={0}", total);

  return 0;
}
```

Expected output:

```text
empty=0
total=6
```

An empty sequence follows the same protocol without inventing a Current default.

</details>

[Previous](19-iterators.md) · [Stage index](README.md) · [Next](21-async-await.md)
