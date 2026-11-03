# 09 · Structs: fields, literals, nesting and values

[中文](../../fundamentals/09-struct-data.md) · [Previous](08-addresses.md) · [Foundation index](README.md) · [Next](10-methods.md)

## Goals

Now define data types of your own. A point has x and y; an order has unit price and quantity. A struct groups related fields under a meaningful type. Methods, extension and interfaces come afterward.

## Read the syntax first

Field declarations end in semicolons. A literal such as Point{ x: 3, y: 4 } initializes named fields with colons and commas. Read with point.x. A type name is not an object variable.

## Example 1: full and partial initialization

[Source](../../examples/fundamentals/struct-fields/main.ny) · [package.yaml](../../examples/fundamentals/struct-fields/package.yaml) · [expected.txt](../../examples/fundamentals/struct-fields/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

func main() -> int32 {
  let first: Point = Point{ x: 3, y: 4 };
  let second: Point = Point{ x: 9 };

  Console.Println("first={0},{1}", first.x, first.y);
  Console.Println("second={0},{1}", second.x, second.y);

  return 0;
}
```

Expected output:

```text
first=3,4
second=9,0
```

Omitted scalar fields are zero-initialized, so second.y is 0. Omission does not invoke a hidden constructor. The type’s design must decide whether a zero value is meaningful.

## Example 2: separate integer-only struct values

[Source](../../examples/fundamentals/struct-values/main.ny) · [package.yaml](../../examples/fundamentals/struct-values/package.yaml) · [expected.txt](../../examples/fundamentals/struct-values/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

func main() -> int32 {
  let original: Point = Point{ x: 3, y: 4 };
  var changed: Point = original;
  changed.x = 10;

  Console.Println("original={0}, changed={1}", original.x, changed.x);

  return 0;
}
```

Expected output:

```text
original=3, changed=10
```

These fields are ordinary integers, so changing changed.x leaves original.x unchanged. Shared handles, containers and move-only resources have their own contracts; do not infer universal deep copying.

## Example 3: compose another struct as a field

[Source](../../examples/fundamentals/nested-struct/main.ny) · [package.yaml](../../examples/fundamentals/nested-struct/package.yaml) · [expected.txt](../../examples/fundamentals/nested-struct/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

struct Bounds {
  origin: Point;
  width: int32;
}

func main() -> int32 {
  var box: Bounds = Bounds{ origin: Point{ x: 1, y: 2 }, width: 6 };
  box.origin.x = 10;

  Console.Println("x={0}, width={1}", box.origin.x, box.width);

  return 0;
}
```

Expected output:

```text
x=10, width=6
```

Bounds has a Point; it is not a subtype of Point. The path box.origin.x follows explicit fields. This “has a” composition is an important comparison for extends.

## Common mistakes and boundaries

Do not put method implementations in the field list or confuse declaration semicolons with literal commas. An underscore does not automatically make a field private; use real module/public-face boundaries.

## Exercise: try before opening the answer

Define Rectangle with width and height. Compute area for 6 by 7 from its fields, then omit height in a second literal.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/09-struct-data-answer/main.ny) · [package.yaml](../../examples/fundamentals/09-struct-data-answer/package.yaml) · [expected.txt](../../examples/fundamentals/09-struct-data-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

func main() -> int32 {
  let full: Rectangle = Rectangle{ width: 6, height: 7 };
  let partial: Rectangle = Rectangle{ width: 6 };

  Console.Println("full={0}, partial={1}", full.width * full.height, partial.width * partial.height);

  return 0;
}
```

Expected output:

```text
full=42, partial=0
```

Area is rectangle.width * rectangle.height, producing 42. Omitted height is 0, so that area is 0: a reason to design creation rules and invariants.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](08-addresses.md) · [Foundation index](README.md) · [Next](10-methods.md)
