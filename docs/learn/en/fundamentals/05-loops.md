# 05 · Loops, ranges, break and continue

[中文](../../fundamentals/05-loops.md) · [Previous](04-conditions.md) · [Foundation index](README.md) · [Next](06-functions.md)

## Goals

A loop repeats a block. Separate initialization, condition, update and result. Trace a few iterations by hand before running to recognize missing endpoints and infinite loops.

## Read the syntax first

While checks before each iteration. The range a..b includes a and excludes b. Break exits the nearest loop; continue skips the rest of the current iteration. The cursor and accumulator have different jobs.

## Example 1: accumulate step by step

[Source](../../examples/fundamentals/while-sum/main.ny) · [package.yaml](../../examples/fundamentals/while-sum/package.yaml) · [expected.txt](../../examples/fundamentals/while-sum/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var number: int32 = 1;
  var total: int32 = 0;
  while number <= 5 {
    total = total + number;
    number = number + 1;
  }

  Console.Println("sum={0}, next={1}", total, number);

  return 0;
}
```

Expected output:

```text
sum=15, next=6
```

Before iteration one: total=0, number=1. After it: 1 and 2. After iteration five: 15 and 6, so the condition fails. Updating number makes the loop terminate.

## Example 2: ranges and skipping

[Source](../../examples/fundamentals/range-control/main.ny) · [package.yaml](../../examples/fundamentals/range-control/package.yaml) · [expected.txt](../../examples/fundamentals/range-control/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  for number in 0..10 {
    if number == 7 {
      break;
    }

    if number % 2 != 0 {
      continue;
    }

    Console.Println("{0}", number);
  }

  return 0;
}
```

Expected output:

```text
0
2
4
6
```

Break at 7 prevents visiting 8 or 9. Continue on other odd values skips only that output. The exclusive endpoint 10 would not be visited anyway.

## Example 3: count nested iterations

[Source](../../examples/fundamentals/nested-loop/main.ny) · [package.yaml](../../examples/fundamentals/nested-loop/package.yaml) · [expected.txt](../../examples/fundamentals/nested-loop/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var count: int32 = 0;
  for row in 0..2 {
    for column in 0..3 {
      count = count + 1;
    }
  }

  Console.Println("cells={0}", count);

  return 0;
}
```

Expected output:

```text
cells=6
```

Each row starts a fresh three-column loop, for 2 * 3 iterations. Break exits only the nearest loop. Return exits the function and abandons its remaining work.

## Common mistakes and boundaries

Forgetting a while update can loop forever. Putting the update after a continue path can have the same effect. Do not replace range syntax with a C three-clause for.

## Exercise: try before opening the answer

Sum even values from 1 through 10 using for, without printing intermediate values. Explain why including 11 leaves the result unchanged.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/05-loops-answer/main.ny) · [package.yaml](../../examples/fundamentals/05-loops-answer/package.yaml) · [expected.txt](../../examples/fundamentals/05-loops-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var total: int32 = 0;
  for number in 1..11 {
    if number % 2 == 0 {
      total = total + number;
    }
  }

  Console.Println("total={0}", total);

  return 0;
}
```

Expected output:

```text
total=30
```

Use 1..11 and number % 2 == 0: total 30. Range 1..12 also visits 11, which is odd.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](04-conditions.md) · [Foundation index](README.md) · [Next](06-functions.md)
