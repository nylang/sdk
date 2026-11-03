# 06 · Functions, parameters, returns and borrows

[中文](../../fundamentals/06-functions.md) · [Previous](05-loops.md) · [Foundation index](README.md) · [Next](07-arrays.md)

## Goals

A function names an operation with inputs and results. Begin with integer calculations, distinguish value parameters from mutable borrows, then introduce optional named parameters without generics or interfaces.

## Read the syntax first

A func declaration gives parameter names/types and a result type before its body. Arguments are evaluated before entering the call under their parameter contracts. Void means no result. Private pure helpers use snake_case; type-owned behavior will use methods later.

## Example 1: a scalar value parameter

[Source](../../examples/fundamentals/value-parameter/main.ny) · [package.yaml](../../examples/fundamentals/value-parameter/package.yaml) · [expected.txt](../../examples/fundamentals/value-parameter/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func plus_two(value: int32) -> int32 {
  return value + 2;
}

func main() -> int32 {
  let original: int32 = 20;
  let result: int32 = plus_two(original);

  Console.Println("original={0}, result={1}", original, result);

  return 0;
}
```

Expected output:

```text
original=20, result=22
```

The return does not overwrite original: result receives the calculation. Do not generalize scalar copying to deep copying of strings or containers.

## Example 2: explicitly modify the caller

[Source](../../examples/fundamentals/borrow-parameter/main.ny) · [package.yaml](../../examples/fundamentals/borrow-parameter/package.yaml) · [expected.txt](../../examples/fundamentals/borrow-parameter/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func add_two(value: ref mut int32) -> void {
  value = value + 2;
}

func main() -> int32 {
  var count: int32 = 40;
  add_two(count);

  Console.Println("count={0}", count);

  return 0;
}
```

Expected output:

```text
count=42
```

Ref mut borrows the caller’s variable for mutation. Pass the variable directly, without explicit &mut. It is not a raw pointer and does not authorize retaining the borrow beyond its lifetime.

## Example 3: named options with defaults

[Source](../../examples/fundamentals/named-parameter/main.ny) · [package.yaml](../../examples/fundamentals/named-parameter/package.yaml) · [expected.txt](../../examples/fundamentals/named-parameter/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func total_price(unit: int32, quantity: int32, {discount: int32 = 0}) -> int32 {
  return unit * quantity - discount;
}

func main() -> int32 {
  Console.Println("plain={0}, discounted={1}", total_price(12, 4), total_price(12, 4, discount: 6));

  return 0;
}
```

Expected output:

```text
plain=48, discounted=42
```

Unit and quantity are required positional parameters. Discount is an optional named entry in a trailing bag. Call with discount: 6, without call-site braces.

## Common mistakes and boundaries

Do not put defaults on required positional parameters or pass a named option as an extra positional argument. Every path in an int32-returning function needs a result.

## Exercise: try before opening the answer

Write clamp_score: return 0 below 0, 100 above 100, otherwise the input. Call with -1, 42 and 101.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/06-functions-answer/main.ny) · [package.yaml](../../examples/fundamentals/06-functions-answer/package.yaml) · [expected.txt](../../examples/fundamentals/06-functions-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func clamp_score(value: int32) -> int32 {
  if value < 0 {
    return 0;
  }

  if value > 100 {
    return 100;
  }

  return value;
}

func main() -> int32 {
  Console.Println("{0},{1},{2}", clamp_score(-1), clamp_score(42), clamp_score(101));

  return 0;
}
```

Expected output:

```text
0,42,100
```

Use two early-return guards followed by return value. Results are 0, 42 and 100; the original bindings are unchanged.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](05-loops.md) · [Foundation index](README.md) · [Next](07-arrays.md)
