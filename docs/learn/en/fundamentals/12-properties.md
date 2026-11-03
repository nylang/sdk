# 12 · Get/set: fields and controlled properties

[中文](../../fundamentals/12-properties.md) · [Previous](11-creation.md) · [Foundation index](README.md) · [Next](13-extends.md)

## Goals

A field stores data; a property delegates reading or writing to methods. Start with a computed getter, add validation in a setter, then reuse that validation during creation. A property is not simply a hidden field.

## Read the syntax first

A getter has no parameter parentheses; a setter takes one value. Read obj.name and assign obj.name = value, without method-call parentheses. Give backing fields and properties distinct names.

## Example 1: compute instead of storing a duplicate

[Source](../../examples/fundamentals/getter/main.ny) · [package.yaml](../../examples/fundamentals/getter/package.yaml) · [expected.txt](../../examples/fundamentals/getter/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

method(Rectangle) get area -> int32 {
  return self.width * self.height;
}

func main() -> int32 {
  let rectangle: Rectangle = Rectangle{ width: 6, height: 7 };
  Console.Println("area={0}", rectangle.area);

  return 0;
}
```

Expected output:

```text
area=42
```

Area is computed on read, without a duplicated stored field. A getter alone supplies no setter: assigning rectangle.area = 9 is not an offered update operation.

## Example 2: centralize write validation

[Source](../../examples/fundamentals/setter/main.ny) · [package.yaml](../../examples/fundamentals/setter/package.yaml) · [expected.txt](../../examples/fundamentals/setter/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Counter {
  current: int32;
}

method(Counter) get value -> int32 {
  return self.current;
}

method(Counter) set value(next: int32) {
  if next < 0 {
    self.current = 0;
    return;
  }

  self.current = next;
}

func main() -> int32 {
  var counter: Counter = Counter{ current: 0 };
  counter.value = -5;
  Console.Println("clamped={0}", counter.value);
  counter.value = 42;
  Console.Println("valid={0}", counter.value);

  return 0;
}
```

Expected output:

```text
clamped=0
valid=42
```

Value names the accessors; current names storage. Assigning self.value inside its setter would recurse. Clamping is this example’s explicit rule; an ordinary Result-returning method can report rejected input instead.

## Example 3: reuse the property invariant during creation

[Source](../../examples/fundamentals/property-creation/main.ny) · [package.yaml](../../examples/fundamentals/property-creation/package.yaml) · [expected.txt](../../examples/fundamentals/property-creation/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Counter {
  current: int32;
}

method(Counter) get value -> int32 {
  return self.current;
}

method(Counter) set value(next: int32) {
  if next < 0 {
    self.current = 0;
    return;
  }

  self.current = next;
}

static method(Counter) StartingAt(initial: int32) -> Counter {
  var counter: Counter = Counter{ current: 0 };
  counter.value = initial;

  return counter;
}

func main() -> int32 {
  let counter: Counter = Counter.StartingAt(-10);
  Console.Println("initial={0}", counter.value);

  return 0;
}
```

Expected output:

```text
initial=0
```

Creation uses the setter to establish the same rule. Visible layout still permits direct current access: actual encapsulation needs module/.ni boundaries, not a private-looking name.

## Common mistakes and boundaries

Paired get/set accessors may share a property name; that does not permit ordinary method overloading. Property syntax does not promise zero cost or justify surprising network side effects.

## Exercise: try before opening the answer

Add a readonly perimeter property to Rectangle. What is the result for 6 by 7, and what happens after changing a field?

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/12-properties-answer/main.ny) · [package.yaml](../../examples/fundamentals/12-properties-answer/package.yaml) · [expected.txt](../../examples/fundamentals/12-properties-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

method(Rectangle) get perimeter -> int32 {
  return 2 * (self.width + self.height);
}

func main() -> int32 {
  var rectangle: Rectangle = Rectangle{ width: 6, height: 7 };
  Console.Println("before={0}", rectangle.perimeter);
  rectangle.width = 10;
  Console.Println("after={0}", rectangle.perimeter);

  return 0;
}
```

Expected output:

```text
before=26
after=34
```

Return 2 * (self.width + self.height): 26. Recomputing each read avoids a stale cached result after fields change.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](11-creation.md) · [Foundation index](README.md) · [Next](13-extends.md)
