# 08: Generics, interfaces and callbacks

[中文](../08-generics.md) · [Course index](README.md) · [Previous](07-packages.md) · [Next](09-text-files.md)

Reuse an algorithm across types, express a common capability and pass behavior
as an argument.

Complete interface forms: [implements, interface extends, get/set and delegation](reference-types.md).

## 1. A numeric function with a type parameter

Complete program:

```nyra
import "stdlib:stdlib.ny";

func larger<T: num>(left: T, right: T) -> T {
  if left > right { return left; }
  return right;
}

func main() -> int32 {
  let integer: int32 = larger<int32>(12, 30);
  let decimal: float64 = larger<float64>(1.5, 2.5);
  Console.Println("整数：{0}", integer);
  Console.Println("小数比较正确：{0}", decimal == 2.5);
  return 0;
}
```

T can become int32 or float64. The num constraint gives numeric operations an
explicit premise; generics do not treat arbitrary types as unchecked bytes.

## 2. A generic struct

Complete program:

```nyra
import "stdlib:stdlib.ny";

struct Box<T> {
  value: T;
}

method(Box<T>) Get() -> T {
  return self.value;
}

func main() -> int32 {
  let number: Box<int32> = Box<int32> { value: 42 };
  let word: Box<string> = Box<string> { value: "Nyra" };
  Console.Println("{0}：{1}", word.Get(), number.Get());
  return 0;
}
```

Box<int32> and Box<string> are distinct concrete types, using the same type
parameter notation seen in Array and HashMap.

## 3. Describe a capability with an interface

Complete program:

```nyra
import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct Quiz implements Scored {
  correct: int32;
}

method(Quiz) Score() -> int32 {
  return self.correct * 10;
}

func show_score(item: Scored) -> void {
  Console.Println("得分：{0}", item.Score());
}

func main() -> int32 {
  let quiz: Quiz = Quiz { correct: 8 };
  show_score(quiz);
  return 0;
}
```

Expected score: 80. Scored requires Score(). Quiz explicitly implements that
contract with a method declared outside the struct. Another scoring type can
reuse show_score by providing the same interface.

## 4. Pass a function

Complete program:

```nyra
import "stdlib:stdlib.ny";

func add_one(value: int32) -> int32 {
  return value + 1;
}

func apply_twice(value: int32, transform: (int32) -> int32) -> int32 {
  return transform(transform(value));
}

func main() -> int32 {
  Console.Println("{0}", apply_twice(40, add_one));
  return 0;
}
```

Expected result: 42. `(int32) -> int32` is a function type accepting and returning
an integer.

## 5. Use a lambda for a small operation

Call fragment replacing the previous main's operation:

```nyra
let step: int32 = 1;
let transform: (int32) -> int32 = lambda [copy step] (value: int32) -> int32 {
  return value + step;
};
Console.Println("{0}", apply_twice(40, transform));
```

`[copy step]` explicitly captures an outer value. Do not shorten it to [step]
or assume every borrowing capture mode is supported. Named functions and
explicit captures make lifetimes easier to understand.

## 6. Compile-time and runtime branches

Definition fragment outside main:

```nyra
func layout_size<T>() -> uintptr {
  if constexpr (sizeof(T) <= 8up) {
    return 8up;
  } else {
    return sizeof(T);
  }
}
```

if constexpr selects using a compile-time condition. Ordinary if uses runtime
data; user input is not automatically known while compiling.

## Exercise

Add Homework implementing Scored, with a points field and Score returning it:

```nyra
struct Homework implements Scored {
  points: int32;
}

method(Homework) Score() -> int32 {
  return self.points;
}
```

Call `show_score(Homework { points: 95 })`. Expect score 95 without modifying
show_score.
