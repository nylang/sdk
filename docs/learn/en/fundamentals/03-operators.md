# 03 · Arithmetic, comparisons and expressions

[中文](../../fundamentals/03-operators.md) · [Previous](02-values.md) · [Foundation index](README.md) · [Next](04-conditions.md)

## Goals

An expression computes a value; a statement performs an action. Learn arithmetic, comparisons and logic before branching. Parentheses communicate intent without memorizing every precedence level.

## Read the syntax first

Arithmetic uses + - * / %. Comparisons produce bool. Logic uses && || !. Assignment = is not equality. Multiplication/division bind before addition/subtraction; parenthesize when unclear.

## Example 1: integer quotient and remainder

[Source](../../examples/fundamentals/division/main.ny) · [package.yaml](../../examples/fundamentals/division/package.yaml) · [expected.txt](../../examples/fundamentals/division/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let value: int32 = 17;
  let divisor: int32 = 5;

  Console.Println("quotient={0}, remainder={1}", value / divisor, value % divisor);
  Console.Println("grouped={0}", (2 + 3) * 4);

  return 0;
}
```

Expected output:

```text
quotient=3, remainder=2
grouped=20
```

Integer division truncates toward zero, rather than producing 3.4. Here 17 = 3 * 5 + 2. The example uses a fixed positive divisor; validate real inputs before division.

## Example 2: combined conditions and short-circuiting

[Source](../../examples/fundamentals/logic/main.ny) · [package.yaml](../../examples/fundamentals/logic/package.yaml) · [expected.txt](../../examples/fundamentals/logic/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let age: int32 = 20;
  let has_ticket: bool = true;
  let cancelled: bool = false;

  if age >= 18 && has_ticket && !cancelled {
    Console.Println("admitted");
  }

  let divisor: int32 = 0;
  if divisor != 0 && 12 / divisor > 1 {
    Console.Println("large quotient");
  }

  return 0;
}
```

Expected output:

```text
admitted
```

&& skips its right side when its left side is false, preventing division by zero here. || skips its right side when its left side is true. Bitwise & and | are not replacements.

## Example 3: bit flags

[Source](../../examples/fundamentals/bits/main.ny) · [package.yaml](../../examples/fundamentals/bits/package.yaml) · [expected.txt](../../examples/fundamentals/bits/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let read_flag: uint32 = 1u;
  let write_flag: uint32 = 2u;
  let flags: uint32 = read_flag | write_flag;

  Console.Println("flags={0}, shifted={1}", flags, 1u << 3u);
  if (flags & read_flag) != 0u {
    Console.Println("read enabled");
  }

  return 0;
}
```

Expected output:

```text
flags=3, shifted=8
read enabled
```

Bitwise OR combines flags; AND tests a bit. The shift uses an in-range unsigned count. Do not rely on out-of-range counts or unchecked signed behavior.

## Common mistakes and boundaries

Prefer readable parentheses: `(flags & read_flag) != 0u`. Compare values with ==; do not compare raw addresses to test string content.

## Exercise: try before opening the answer

Convert 125 total seconds into minutes and remaining seconds. Repeat for 59 and 180.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/03-operators-answer/main.ny) · [package.yaml](../../examples/fundamentals/03-operators-answer/package.yaml) · [expected.txt](../../examples/fundamentals/03-operators-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let total: int32 = 125;
  Console.Println("minutes={0}, seconds={1}", total / 60, total % 60);

  return 0;
}
```

Expected output:

```text
minutes=2, seconds=5
```

Use total / 60 and total % 60: 2m5s, 0m59s and 3m0s.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](02-values.md) · [Foundation index](README.md) · [Next](04-conditions.md)
