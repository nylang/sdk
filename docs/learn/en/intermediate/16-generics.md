# 16 · Generics: type parameters, inference and constraints

[中文](../../intermediate/16-generics.md) · [Previous](../fundamentals/15-interface-design.md) · [Stage index](README.md) · [Next](17-lambda.md)

## Goals

Generics reuse a definition at concrete types, rather than erasing values into arbitrary data. Start with numeric functions, then generic structs, then interface constraints.

## Syntax and contracts

T is a type parameter; T: num permits numeric operations, not runtime num storage. Box<int32> and Box<string> are different concrete types. Arguments may infer type parameters; constraints must support the body’s operations. A visible generic body does not admit arbitrary types.

## Example 1: explicit and inferred types

[Source](../../examples/intermediate/generic-numbers/main.ny) · [package.yaml](../../examples/intermediate/generic-numbers/package.yaml) · [expected.txt](../../examples/intermediate/generic-numbers/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func larger<T: num>(left: T, right: T) -> T {
  if left > right {
    return left;
  }

  return right;
}

func main() -> int32 {
  let first: int32 = larger<int32>(20, 42);
  let second: int32 = larger(30, 12);

  Console.Println("first={0}, second={1}", first, second);

  return 0;
}
```

Expected output:

```text
first=42, second=30
```

Both calls specialize at int32. Angle brackets supply types; parentheses supply values.

## Example 2: a method on a generic type

[Source](../../examples/intermediate/generic-box/main.ny) · [package.yaml](../../examples/intermediate/generic-box/package.yaml) · [expected.txt](../../examples/intermediate/generic-box/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Box<T> {
  value: T;
}

method(Box<T>) Get() -> T {
  return self.value;
}

func main() -> int32 {
  let number: Box<int32> = Box<int32>{ value: 42 };
  let word: Box<string> = Box<string>{ value: "Nyra" };

  Console.Println("{0}={1}", word.Get(), number.Get());

  return 0;
}
```

Expected output:

```text
Nyra=42
```

The receiver retains T. Get returns that concrete T; it does not cast every payload to string. Field ownership rules still apply.

## Example 3: an interface constraint justifies calls

[Source](../../examples/intermediate/generic-contract/main.ny) · [package.yaml](../../examples/intermediate/generic-contract/package.yaml) · [expected.txt](../../examples/intermediate/generic-contract/expected.txt)

```nyra
import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct Card implements Scored {
  points: int32;
}

method(Card) Score() -> int32 {
  return self.points;
}

func read_score<T: Scored>(value: T) -> int32 {
  return value.Score();
}

func main() -> int32 {
  let card: Card = Card{ points: 42 };
  Console.Println("score={0}", read_score(card));

  return 0;
}
```

Expected output:

```text
score=42
```

The generic caller knows concrete T while requiring Scored. Do not assume every constrained generic call must use interface-table dispatch.

## Common mistakes and boundaries

An unconstrained T does not justify arbitrary arithmetic/member calls. Num/real are not storage types. Do not cast around failed constraints or teach future type packs as current generics.

## Exercise

Write smaller<T: num> and call with 20 and 42; expect 20.

<details>
<summary>Complete answer</summary>

[Source](../../examples/intermediate/generic-answer/main.ny) · [package.yaml](../../examples/intermediate/generic-answer/package.yaml) · [expected.txt](../../examples/intermediate/generic-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func smaller<T: num>(left: T, right: T) -> T {
  if left < right {
    return left;
  }

  return right;
}

func main() -> int32 {
  Console.Println("smaller={0}", smaller<int32>(20, 42));

  return 0;
}
```

Expected output:

```text
smaller=20
```

Only the comparison changes; the num constraint remains.

</details>

[Previous](../fundamentals/15-interface-design.md) · [Stage index](README.md) · [Next](17-lambda.md)
