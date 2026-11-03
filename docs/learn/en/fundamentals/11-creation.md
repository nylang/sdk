# 11 · Static methods, values and named factories

[中文](../../fundamentals/11-creation.md) · [Previous](10-methods.md) · [Foundation index](README.md) · [Next](12-properties.md)

## Goals

Instance methods need an existing object; creation starts without one. Begin with static methods returning ordinary values, then factories returning owned objects. Both are called on a type, but have different result contracts.

## Read the syntax first

Static methods have no self and are called as Point.Origin(). A factory also has no self and is called as Point.Make(...), returning an owner such as unique<Point>. Do not write static factory.

## Example 1: a type-level operation returning a value

[Source](../../examples/fundamentals/static-value/main.ny) · [package.yaml](../../examples/fundamentals/static-value/package.yaml) · [expected.txt](../../examples/fundamentals/static-value/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

static method(Point) Origin() -> Point {
  return Point{ x: 0, y: 0 };
}

func main() -> int32 {
  let point: Point = Point.Origin();
  Console.Println("x={0}, y={1}", point.x, point.y);

  return 0;
}
```

Expected output:

```text
x=0, y=0
```

Origin receives no existing Point and cannot access self.x. Returning a Point value needs no new and does not become a heap owner. Call through the type, not point.Origin.

## Example 2: a factory returning a unique owner

[Source](../../examples/fundamentals/owned-factory/main.ny) · [package.yaml](../../examples/fundamentals/owned-factory/package.yaml) · [expected.txt](../../examples/fundamentals/owned-factory/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

factory(Point) Make(x: int32, y: int32) -> unique<Point> {
  return new unique<Point>{ x: x, y: y };
}

method(Point) Sum() -> int32 {
  return self.x + self.y;
}

func main() -> int32 {
  let point: unique<Point> = Point.Make(20, 22);
  Console.Println("sum={0}", point.Sum());

  return 0;
}
```

Expected output:

```text
sum=42
```

Left-of-colon x/y name fields; the right sides name parameters. The unique<Point> owner supports instance method calls. Language cleanup releases the owner, without a separate caller Free.

## Example 3: distinct names for creation intent

[Source](../../examples/fundamentals/named-creation/main.ny) · [package.yaml](../../examples/fundamentals/named-creation/package.yaml) · [expected.txt](../../examples/fundamentals/named-creation/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

static method(Rectangle) Square(side: int32) -> Rectangle {
  return Rectangle{ width: side, height: side };
}

static method(Rectangle) WithSize(width: int32, height: int32) -> Rectangle {
  return Rectangle{ width: width, height: height };
}

method(Rectangle) Area() -> int32 {
  return self.width * self.height;
}

func main() -> int32 {
  let square: Rectangle = Rectangle.Square(6);
  let wide: Rectangle = Rectangle.WithSize(6, 7);

  Console.Println("square={0}, wide={1}", square.Area(), wide.Area());

  return 0;
}
```

Expected output:

```text
square=36, wide=42
```

Names express intent without overload resolution. These return ordinary Rectangle values, so they are static methods. Use the factory contract for owned unique/rc/arc results.

## Common mistakes and boundaries

Static methods and factories cannot use self. Do not declare an ordinary Point result under a factory contract. Point{} does not automatically run Make, Origin or Init.

## Exercise: try before opening the answer

Add Rectangle.Unit() returning 1 by 1, then Point.OnXAxis(x) returning a unique<Point> with y equal to 0.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/11-creation-answer/main.ny) · [package.yaml](../../examples/fundamentals/11-creation-answer/package.yaml) · [expected.txt](../../examples/fundamentals/11-creation-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

static method(Rectangle) Unit() -> Rectangle {
  return Rectangle{ width: 1, height: 1 };
}

struct Point {
  x: int32;
  y: int32;
}

factory(Point) OnXAxis(x: int32) -> unique<Point> {
  return new unique<Point>{ x: x, y: 0 };
}

func main() -> int32 {
  let rectangle: Rectangle = Rectangle.Unit();
  let point: unique<Point> = Point.OnXAxis(42);

  Console.Println("area={0}, x={1}, y={2}", rectangle.width * rectangle.height, point.x, point.y);

  return 0;
}
```

Expected output:

```text
area=1, x=42, y=0
```

Unit returns a Rectangle literal; OnXAxis returns new unique<Point>{ x: x, y: 0 }. Type-level call syntax does not make their ownership contracts identical.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](10-methods.md) · [Foundation index](README.md) · [Next](12-properties.md)
