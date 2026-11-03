# 04 · If, else, switch and early returns

[中文](../../fundamentals/04-conditions.md) · [Previous](03-operators.md) · [Foundation index](README.md) · [Next](05-loops.md)

## Goals

Branches select which statements run. Start with one condition, then mutually exclusive alternatives, then a switch over discrete choices. Enums, structs and interfaces can wait.

## Read the syntax first

An if condition is bool. An else-if chain selects the first matching branch. Switch cases use colon labels and do not fall through. Return ends the current function, not merely a branch.

## Example 1: order of exclusive conditions

[Source](../../examples/fundamentals/grades/main.ny) · [package.yaml](../../examples/fundamentals/grades/package.yaml) · [expected.txt](../../examples/fundamentals/grades/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let score: int32 = 85;
  if score >= 90 {
    Console.Println("excellent");
  } else if score >= 60 {
    Console.Println("pass");
  } else {
    Console.Println("retry");
  }

  return 0;
}
```

Expected output:

```text
pass
```

85 fails the first comparison and passes the second. Putting >= 60 first would capture a score of 90 too. Try boundary values 59, 60, 89 and 90.

## Example 2: discrete commands and default

[Source](../../examples/fundamentals/switch/main.ny) · [package.yaml](../../examples/fundamentals/switch/package.yaml) · [expected.txt](../../examples/fundamentals/switch/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let command: int32 = 2;
  switch command {
    case 1:
      Console.Println("start");
    case 2:
      Console.Println("stop");
    default:
      Console.Println("unknown");
  }

  return 0;
}
```

Expected output:

```text
stop
```

The selected value is matched against cases. A colon introduces the case body. No break is needed to prevent falling into default. A value of 7 selects default.

## Example 3: reject invalid input first

[Source](../../examples/fundamentals/guard/main.ny) · [package.yaml](../../examples/fundamentals/guard/package.yaml) · [expected.txt](../../examples/fundamentals/guard/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func admitted_count(count: int32) -> int32 {
  if count < 0 {
    return 0;
  }

  return count;
}

func main() -> int32 {
  Console.Println("bad={0}, good={1}", admitted_count(-1), admitted_count(3));

  return 0;
}
```

Expected output:

```text
bad=0, good=3
```

The small pure helper rejects negatives first, leaving a clear success path. Returning 0 is this exercise’s rule, not a universal error strategy; Result comes later.

## Common mistakes and boundaries

Two independent if statements can both execute; they are not an else-if chain. Keep even short blocks expanded and readable.

## Exercise: try before opening the answer

Print freezing below 0, cool from 0 through 19, and warm at 20 or above. Test -1, 0, 19 and 20.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/04-conditions-answer/main.ny) · [package.yaml](../../examples/fundamentals/04-conditions-answer/package.yaml) · [expected.txt](../../examples/fundamentals/04-conditions-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func show_temperature(temperature: int32) -> void {
  if temperature < 0 {
    Console.Println("freezing");
  } else if temperature < 20 {
    Console.Println("cool");
  } else {
    Console.Println("warm");
  }
}

func main() -> int32 {
  show_temperature(-1);
  show_temperature(0);
  show_temperature(19);
  show_temperature(20);

  return 0;
}
```

Expected output:

```text
freezing
cool
cool
warm
```

Test temperature < 0, then < 20, then else. The four outputs are freezing, cool, cool and warm.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](03-operators.md) · [Foundation index](README.md) · [Next](05-loops.md)
