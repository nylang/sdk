# 10 · Instance methods: behavior belongs to its type

[中文](../../fundamentals/10-methods.md) · [Previous](09-struct-data.md) · [Foundation index](README.md) · [Next](11-creation.md)

## Goals

Move the preceding area calculation onto Rectangle.Area. Explain the caller, receiver type, self, parameters and return value before writing state-changing methods.

## Read the syntax first

A method(Rectangle) declaration sits outside the struct. In rectangle.Area(), rectangle supplies the implicit receiver self. Do not repeat self in this introductory parameter list; ordinary parameters go inside parentheses.

## Example 1: turn a field calculation into an operation

[Source](../../examples/fundamentals/area-method/main.ny) · [package.yaml](../../examples/fundamentals/area-method/package.yaml) · [expected.txt](../../examples/fundamentals/area-method/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

method(Rectangle) Area() -> int32 {
  return self.width * self.height;
}

func main() -> int32 {
  let rectangle: Rectangle = Rectangle{ width: 6, height: 7 };
  Console.Println("area={0}", rectangle.Area());

  return 0;
}
```

Expected output:

```text
area=42
```

The receiver type is Rectangle. Self denotes this call’s value, not a global. Two rectangles call the same method body with their own fields.

## Example 2: modify an existing value

[Source](../../examples/fundamentals/counter-method/main.ny) · [package.yaml](../../examples/fundamentals/counter-method/package.yaml) · [expected.txt](../../examples/fundamentals/counter-method/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Counter {
  value: int32;
}

method(Counter) Add(amount: int32) -> void {
  self.value = self.value + amount;
}

func main() -> int32 {
  var first: Counter = Counter{ value: 0 };
  var second: Counter = Counter{ value: 10 };
  first.Add(2);
  first.Add(3);

  Console.Println("first={0}, second={1}", first.value, second.value);

  return 0;
}
```

Expected output:

```text
first=5, second=10
```

Amount excludes the implicit receiver. First uses var because it changes. Calling first.Add does not modify second. Void indicates mutation rather than a returned result.

## Example 3: reuse another method

[Source](../../examples/fundamentals/method-chain/main.ny) · [package.yaml](../../examples/fundamentals/method-chain/package.yaml) · [expected.txt](../../examples/fundamentals/method-chain/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

method(Rectangle) Area() -> int32 {
  return self.width * self.height;
}

method(Rectangle) DoubleArea() -> int32 {
  return self.Area() * 2;
}

func main() -> int32 {
  let rectangle: Rectangle = Rectangle{ width: 6, height: 7 };
  Console.Println("area={0}, doubled={1}", rectangle.Area(), rectangle.DoubleArea());

  return 0;
}
```

Expected output:

```text
area=42, doubled=84
```

Reuse through self.Area rather than duplicating the formula. Distinct names communicate distinct operations. A computed return value does not automatically update fields.

## Common mistakes and boundaries

Ordinary methods on one receiver cannot overload solely by parameter types/counts. Different types may each define Area. Calling an instance method as Rectangle.Area() omits its required receiver.

## Exercise: try before opening the answer

Add Counter.Reset(), assigning 0 to self.value. Call Add(5), Reset(), then Add(2), and inspect the result.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/10-methods-answer/main.ny) · [package.yaml](../../examples/fundamentals/10-methods-answer/package.yaml) · [expected.txt](../../examples/fundamentals/10-methods-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Counter {
  value: int32;
}

method(Counter) Add(amount: int32) -> void {
  self.value = self.value + amount;
}

method(Counter) Reset() -> void {
  self.value = 0;
}

func main() -> int32 {
  var counter: Counter = Counter{ value: 0 };
  counter.Add(5);
  counter.Reset();
  counter.Add(2);

  Console.Println("value={0}", counter.value);

  return 0;
}
```

Expected output:

```text
value=2
```

Reset is a void instance method; final value 2. Do not introduce a helper-bucket type or duplicate Counter parameter for this operation.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](09-struct-data.md) · [Foundation index](README.md) · [Next](11-creation.md)
