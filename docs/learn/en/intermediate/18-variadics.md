# 18 · Variadics: enable channels, access and forwarding

[中文](../../intermediate/18-variadics.md) · [Previous](17-lambda.md) · [Stage index](README.md) · [Next](19-iterators.md)

## Goals

Nyra variadics do not accept arbitrary values for dynamic type inspection. Normalize to int32, add one conversion, then forward an existing string pack.

## Syntax and contracts

A trailing ...enable<int32> accepts zero or more values. Read normalized int32 elements through length/indexing. Source expressions are evaluated and normalized once. The invocation-local pack is not a resizable or escapable Array.

## Example 1: zero, one and several arguments

[Source](../../examples/intermediate/variadic-sum/main.ny) · [package.yaml](../../examples/intermediate/variadic-sum/package.yaml) · [expected.txt](../../examples/intermediate/variadic-sum/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func sum(parts: ...enable<int32>) -> int32 {
  var total: int32 = 0;
  for index in 0..parts.length {
    total = total + parts[index];
  }

  return total;
}

func main() -> int32 {
  Console.Println("empty={0}, one={1}, many={2}", sum(), sum(7), sum(10, 20, 12));

  return 0;
}
```

Expected output:

```text
empty=0, one=7, many=42
```

An empty pack skips the loop and returns the initial total. Calls need no spread punctuation.

## Example 2: a defined conversion, not an arbitrary cast

[Source](../../examples/intermediate/variadic-conversion/main.ny) · [package.yaml](../../examples/intermediate/variadic-conversion/package.yaml) · [expected.txt](../../examples/intermediate/variadic-conversion/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Score {
  points: int32;
}

method(Score) ToInt32() -> int32 {
  return self.points;
}

func sum(parts: ...enable<int32>) -> int32 {
  var total: int32 = 0;
  for index in 0..parts.length {
    total = total + parts[index];
  }

  return total;
}

func main() -> int32 {
  let item: Score = Score{ points: 22 };
  Console.Println("total={0}", sum(20, item));

  return 0;
}
```

Expected output:

```text
total=42
```

Score provides the required instance converter. The body sees int32 values, not the original dynamic source types.

## Example 3: forward the complete compatible pack

[Source](../../examples/intermediate/variadic-forward/main.ny) · [package.yaml](../../examples/intermediate/variadic-forward/package.yaml) · [expected.txt](../../examples/intermediate/variadic-forward/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func log_line(format: ref string, parts: ...enable<string>) -> void {
  Console.Println(format, parts);
}

func main() -> int32 {
  log_line("value={0}, language={1}", 42, "Nyra");

  return 0;
}
```

Expected output:

```text
value=42, language=Nyra
```

Forward the whole compatible pack, without parts... or concatenating additional elements. Formatting normalizes the integer through the string channel.

## Common mistakes and boundaries

Do not teach arbitrary ...T, heterogeneous extraction, Array spreading or mixing a named optional bag with a pack. Do not retain a pack across async suspension. C ... has a separate ABI; planned args<T> is not released syntax here.

## Exercise

Write total_plus(base, parts), initialize the sum from base, then add the pack. Call with 10, 20, 12.

<details>
<summary>Complete answer</summary>

[Source](../../examples/intermediate/variadic-answer/main.ny) · [package.yaml](../../examples/intermediate/variadic-answer/package.yaml) · [expected.txt](../../examples/intermediate/variadic-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func total_plus(base: int32, parts: ...enable<int32>) -> int32 {
  var total: int32 = base;
  for index in 0..parts.length {
    total = total + parts[index];
  }

  return total;
}

func main() -> int32 {
  Console.Println("total={0}", total_plus(10, 20, 12));

  return 0;
}
```

Expected output:

```text
total=42
```

Fixed arguments precede the single trailing variadic.

</details>

[Previous](17-lambda.md) · [Stage index](README.md) · [Next](19-iterators.md)
