# 07 · Local arrays, indexing and strings

[中文](../../fundamentals/07-arrays.md) · [Previous](06-functions.md) · [Foundation index](README.md) · [Next](08-addresses.md)

## Goals

Arrays group values of one type. Begin with a fixed set of local elements, before dynamic containers or generic implementations. Strings have lengths too, but bytes are not necessarily human-readable characters.

## Read the syntax first

A local array can use type `<int32>[]` and initializer `{ 10, 20, 30 }`. Indexing starts at 0: three elements have indices 0, 1 and 2. An array does not authorize out-of-bounds memory access.

## Example 1: read and update an element

[Source](../../examples/fundamentals/array-index/main.ny) · [package.yaml](../../examples/fundamentals/array-index/package.yaml) · [expected.txt](../../examples/fundamentals/array-index/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var scores: <int32>[] = { 10, 20, 30 };
  scores[1] = 42;

  Console.Println("first={0}, second={1}, last={2}", scores[0], scores[1], scores[2]);

  return 0;
}
```

Expected output:

```text
first=10, second=42, last=30
```

Index 1 selects the second element. Updating it changes one slot, not the whole array. This is a local array, not the shared-storage contract of stdlib Array<T>.

## Example 2: traverse valid indices

[Source](../../examples/fundamentals/array-sum/main.ny) · [package.yaml](../../examples/fundamentals/array-sum/package.yaml) · [expected.txt](../../examples/fundamentals/array-sum/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let values: <int32>[] = { 10, 20, 12 };
  var total: int32 = 0;
  for index in 0..3 {
    total = total + values[index];
  }

  Console.Println("total={0}", total);

  return 0;
}
```

Expected output:

```text
total=42
```

Range 0..3 visits exactly indices 0, 1 and 2. Its endpoint matches this literal. Variable-length application data should keep storage and length together, not duplicate a drifting constant.

## Example 3: a string value is not char*

[Source](../../examples/fundamentals/string-value/main.ny) · [package.yaml](../../examples/fundamentals/string-value/package.yaml) · [expected.txt](../../examples/fundamentals/string-value/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let greeting: string = "Hello";
  let message: string = greeting.Concat(", Nyra");

  Console.Println("{0}", message);
  Console.Println("ascii-bytes={0}", greeting.length);

  return 0;
}
```

Expected output:

```text
Hello, Nyra
ascii-bytes=5
```

Concat and length are supplied member operations; later lessons define your own methods. This example is ASCII. For other text, do not equate byte length with character count or assume C zero termination.

## Common mistakes and boundaries

Do not read index 3 in a three-element array or execute an out-of-bounds example to see what happens. Dynamic Array<T> has separate Get/Set and ownership rules, covered later.

## Exercise: try before opening the answer

Find the maximum in { 3, 1, 4, 2 }. Initialize maximum from the first element, then compare each element.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/07-arrays-answer/main.ny) · [package.yaml](../../examples/fundamentals/07-arrays-answer/package.yaml) · [expected.txt](../../examples/fundamentals/07-arrays-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let values: <int32>[] = { 3, 1, 4, 2 };
  var maximum: int32 = values[0];
  for index in 1..4 {
    if values[index] > maximum {
      maximum = values[index];
    }
  }

  Console.Println("maximum={0}", maximum);

  return 0;
}
```

Expected output:

```text
maximum=4
```

Visit indices 1..4 and update maximum when larger: result 4. Initializing maximum to 0 would fail for an all-negative array.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](06-functions.md) · [Foundation index](README.md) · [Next](08-addresses.md)
