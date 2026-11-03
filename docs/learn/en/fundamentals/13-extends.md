# 13 · Struct extends: layout extension and base methods

[中文](../../fundamentals/13-extends.md) · [Previous](12-properties.md) · [Foundation index](README.md) · [Next](14-interfaces.md)

## Goals

This lesson covers struct extends; interfaces come next. Extend a known base layout into a more specific layout without turning structs into virtual-method classes. Separate fields, base-method lookup and composition.

## Read the syntax first

A struct has at most one struct base. A derived value contains base fields and its additional fields. Calls on known struct types resolve statically; no implicit vptr/vtable or automatic virtual child selection is introduced.

## Example 1: base and additional fields

[Source](../../examples/fundamentals/extends-fields/main.ny) · [package.yaml](../../examples/fundamentals/extends-fields/package.yaml) · [expected.txt](../../examples/fundamentals/extends-fields/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

struct ColoredPoint extends Point {
  color: int32;
}

func main() -> int32 {
  let point: ColoredPoint = ColoredPoint{ x: 20, y: 22, color: 7 };
  Console.Println("x={0}, y={1}, color={2}", point.x, point.y, point.color);

  return 0;
}
```

Expected output:

```text
x=20, y=22, color=7
```

The derived literal initializes inherited x/y and added color. It does not introduce a field named Point. Additional fields do not imply a vtable. Do not redeclare base fields to “override” storage.

## Example 2: reuse known base methods on the same storage

[Source](../../examples/fundamentals/extends-methods/main.ny) · [package.yaml](../../examples/fundamentals/extends-methods/package.yaml) · [expected.txt](../../examples/fundamentals/extends-methods/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

method(Point) MoveX(amount: int32) -> void {
  self.x = self.x + amount;
}

method(Point) Sum() -> int32 {
  return self.x + self.y;
}

struct ColoredPoint extends Point {
  color: int32;
}

func main() -> int32 {
  var point: ColoredPoint = ColoredPoint{ x: 20, y: 22, color: 7 };
  point.MoveX(1);

  Console.Println("sum={0}, color={1}", point.Sum(), point.color);

  return 0;
}
```

Expected output:

```text
sum=43, color=7
```

ColoredPoint reuses known Point implementations. MoveX changes this object’s base x, rather than a discarded copy. Color is uninvolved. No same-name virtual child override is being demonstrated.

## Example 3: composition for a has-a relationship

[Source](../../examples/fundamentals/composition/main.ny) · [package.yaml](../../examples/fundamentals/composition/package.yaml) · [expected.txt](../../examples/fundamentals/composition/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

method(Point) Sum() -> int32 {
  return self.x + self.y;
}

struct Marker {
  position: Point;
  color: int32;
}

func main() -> int32 {
  let marker: Marker = Marker{ position: Point{ x: 20, y: 22 }, color: 7 };
  Console.Println("sum={0}", marker.position.Sum());

  return 0;
}
```

Expected output:

```text
sum=42
```

Marker has a position, so the path is marker.position.Sum(). Composition does not automatically expose every Point operation. An explicit field often expresses reusable data/capability more clearly than type extension.

## Common mistakes and boundaries

Do not import C++/Java assumptions about virtual methods, constructor chains or arbitrary base/child conversions. Extends does not auto-call Init or make factories/static methods an instance-construction chain. This course does not use development init/super/@override additions.

## Exercise: try before opening the answer

Add ColoredPoint.ColorCode() while leaving both Point methods unchanged. Identify added behavior versus reused base behavior.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/13-extends-answer/main.ny) · [package.yaml](../../examples/fundamentals/13-extends-answer/package.yaml) · [expected.txt](../../examples/fundamentals/13-extends-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

method(Point) MoveX(amount: int32) -> void {
  self.x = self.x + amount;
}

method(Point) Sum() -> int32 {
  return self.x + self.y;
}

struct ColoredPoint extends Point {
  color: int32;
}

method(ColoredPoint) ColorCode() -> int32 {
  return self.color;
}

func main() -> int32 {
  var point: ColoredPoint = ColoredPoint{ x: 20, y: 22, color: 7 };
  point.MoveX(1);

  Console.Println("sum={0}, color={1}", point.Sum(), point.ColorCode());

  return 0;
}
```

Expected output:

```text
sum=43, color=7
```

ColorCode returns self.color. MoveX/Sum use known base implementations; ColorCode is an added instance operation, also statically resolved.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](12-properties.md) · [Foundation index](README.md) · [Next](14-interfaces.md)
