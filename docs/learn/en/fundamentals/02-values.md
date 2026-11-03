# 02 · Variables, types, assignment and scope

[中文](../../fundamentals/02-values.md) · [Previous](01-program.md) · [Foundation index](README.md) · [Next](03-operators.md)

## Goals

A variable associates a name with a value. Use numbers, Booleans and strings before object ownership. Learn declaration, reading, assignment and scope before reasoning about mutation in loops or methods.

## Read the syntax first

Declare with `let name: Type = initial;` or var. A let binding cannot be reassigned; var can. Assignment evaluates its right side before updating the left. Local names belong to their enclosing scope.

## Example 1: fixed price, changing quantity

[Source](../../examples/fundamentals/bindings/main.ny) · [package.yaml](../../examples/fundamentals/bindings/package.yaml) · [expected.txt](../../examples/fundamentals/bindings/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let unit_price: int32 = 12;
  var quantity: int32 = 2;
  quantity = quantity + 1;

  Console.Println("quantity={0}, total={1}", quantity, unit_price * quantity);

  return 0;
}
```

Expected output:

```text
quantity=3, total=36
```

Read the old quantity 2, add 1, and store 3. The unchanged unit_price uses let. The colon annotates a type; it is not assignment.

## Example 2: integer conversion and floating-point arithmetic

[Source](../../examples/fundamentals/numeric-types/main.ny) · [package.yaml](../../examples/fundamentals/numeric-types/package.yaml) · [expected.txt](../../examples/fundamentals/numeric-types/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let small: int32 = 42;
  let wide: int64 = small;
  let precise: float64 = 5.0 / 2.0;

  if precise == 2.5 {
    Console.Println("wide={0}, fraction=2.5", wide);
  }

  return 0;
}
```

Expected output:

```text
wide=42, fraction=2.5
```

Widening int32 to int64 is implicit. 5.0 is float64. The branch checks an exactly representable result without depending on float formatting. Conversion is not arbitrary data validation.

## Example 3: temporary local and outer result

[Source](../../examples/fundamentals/scope/main.ny) · [package.yaml](../../examples/fundamentals/scope/package.yaml) · [expected.txt](../../examples/fundamentals/scope/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var total: int32 = 10;
  if total > 0 {
    let extra: int32 = 5;
    total = total + extra;
  }

  Console.Println("total={0}", total);

  return 0;
}
```

Expected output:

```text
total=15
```

total belongs to the outer scope and is updated inside. extra belongs to the inner block and cannot be used afterward. Braces delimit scope as well as layout.

## Common mistakes and boundaries

You cannot assign n = 2 after let n: int32 = 1. String "42" is not integer 42. Narrowing/lossy conversion requires explicit intent; as does not guarantee range safety. An explicitly typed scalar zero can be written as 0.

## Exercise: try before opening the answer

Start with quantity 4, add 2, and retain price 12. Predict the output before running.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/02-values-answer/main.ny) · [package.yaml](../../examples/fundamentals/02-values-answer/package.yaml) · [expected.txt](../../examples/fundamentals/02-values-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let unit_price: int32 = 12;
  var quantity: int32 = 4;
  quantity = quantity + 2;

  Console.Println("quantity={0}, total={1}", quantity, unit_price * quantity);

  return 0;
}
```

Expected output:

```text
quantity=6, total=72
```

Quantity is 6 and total is 72. Change the initializer and increment, leaving the format unchanged.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](01-program.md) · [Foundation index](README.md) · [Next](03-operators.md)
