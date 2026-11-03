# 01 · Read a program from its first output

[中文](../../fundamentals/01-program.md) · [Previous](../00-start.md) · [Foundation index](README.md) · [Next](02-values.md)

## Goals

Start without custom types. A program enters main, executes statements in order, and returns to the operating system. Distinguish source text, output, a function body, statements and an exit status.

## Read the syntax first

`import "stdlib:stdlib.ny";` makes standard-library public names available. `func main() -> int32` defines the entry: empty parameter list, integer result. Braces delimit the body; ordinary statements end with semicolons. Console is a library type, not a keyword.

## Example 1: one output

[Source](../../examples/fundamentals/hello/main.ny) · [package.yaml](../../examples/fundamentals/hello/package.yaml) · [expected.txt](../../examples/fundamentals/hello/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("Hello, Nyra!");

  return 0;
}
```

Expected output:

```text
Hello, Nyra!
```

Only Println produces this line. Import does not print. Returning 0 reports success; it does not print the number.

## Example 2: order and comments

[Source](../../examples/fundamentals/sequence/main.ny) · [package.yaml](../../examples/fundamentals/sequence/package.yaml) · [expected.txt](../../examples/fundamentals/sequence/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  // Explain intent; this line is not executed.
  Console.Println("first");
  Console.Println("second");

  return 0;
}
```

Expected output:

```text
first
second
```

Statements run in written order. A // comment ends at the newline. Text inside a string is data. Swap the statements to swap the output.

## Example 3: print a computed result

[Source](../../examples/fundamentals/format/main.ny) · [package.yaml](../../examples/fundamentals/format/package.yaml) · [expected.txt](../../examples/fundamentals/format/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("answer={0}", 20 + 22);

  return 0;
}
```

Expected output:

```text
answer=42
```

{0} selects the first extra argument. Evaluate 20 + 22 before printing. The expected-output block is not source code to paste into main.ny.

## Common mistakes and boundaries

Do not substitute C syntax such as int main(), omit semicolons, or combine several main definitions. Fix a failed compilation before running an old executable.

## Exercise: try before opening the answer

Print ready followed by total=42. Explain why return 0 does not produce a third line.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/01-program-answer/main.ny) · [package.yaml](../../examples/fundamentals/01-program-answer/package.yaml) · [expected.txt](../../examples/fundamentals/01-program-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("ready");
  Console.Println("total={0}", 6 * 7);

  return 0;
}
```

Expected output:

```text
ready
total=42
```

Keep import and main, print "ready", then print "total={0}" with 6 * 7, and return 0.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](../00-start.md) · [Foundation index](README.md) · [Next](02-values.md)
