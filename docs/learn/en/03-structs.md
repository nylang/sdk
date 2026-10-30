# 03: Structs and methods

[中文](../03-structs.md) · [Course index](README.md) · [Previous](02-control-functions.md) · [Next](04-ownership.md)

A book's title and price belong together. A struct gives related data a name.

Full companion: [methods, static methods, named factories, get/set, extends, interfaces, delegation and drop](reference-types.md), including duplicate-name rules.

## 1. Define a data shape

Complete program:

```nyra
import "stdlib:stdlib.ny";

struct Book {
  title: string;
  price: int32;
}

func main() -> int32 {
  let book: Book = Book { title: "Nyra 入门", price: 35 };
  Console.Println("《{0}》：{1} 元", book.title, book.price);
  return 0;
}
```

`Book` is a type; title and price are fields. The literal constructs a value,
and `book.title` reads one field. Type Book and variable book have different roles.

## 2. Add behavior

Insert this after Book and before main:

```nyra
method(Book) DiscountedPrice(discount: int32) -> int32 {
  return self.price - discount;
}
```

Call it in main:

```nyra
Console.Println("优惠后：{0} 元", book.DiscountedPrice(5));
```

`method(Book)` associates behavior with Book. The receiver on the left of the
dot becomes self. Methods are declared outside the struct's field list.

## 3. Change a value

Complete program:

```nyra
import "stdlib:stdlib.ny";

struct Counter {
  value: int32;
}

method(Counter) Add(amount: int32) -> void {
  self.value = self.value + amount;
}

func main() -> int32 {
  var counter: Counter = Counter { value: 0 };
  counter.Add(3);
  counter.Add(2);
  Console.Println("计数：{0}", counter.value);
  return 0;
}
```

The count becomes 5. A void method does not return a result value.

## 4. Static methods and properties

Add these definitions outside main:

```nyra
static method(Counter) Zero() -> Counter {
  return Counter { value: 0 };
}

method(Counter) get is_zero -> bool {
  return self.value == 0;
}
```

Call fragment:

```nyra
let empty: Counter = Counter.Zero();
Console.Println("是否为零：{0}", empty.is_zero);
```

`Counter.Zero()` needs no existing Counter. A property such as is_zero is read
without call parentheses.

## 5. Represent a finite choice

Complete program:

```nyra
import "stdlib:stdlib.ny";

enum TaskState {
  Todo,
  Done,
}

func state_text(state: TaskState) -> string {
  switch state {
    case TaskState.Todo { return "待完成"; }
    case TaskState.Done { return "已完成"; }
    default { return "未知"; }
  }
}

func main() -> int32 {
  Console.Println("任务状态：{0}", state_text(TaskState.Done));
  return 0;
}
```

A switch selects a case. Cases do not implicitly fall through, so no extra
break statement is needed to prevent fallthrough.

## 6. Return a temporary pair

Use a named struct for meaningful records. A tuple can return a simple pair:

```nyra
import "stdlib:stdlib.ny";

func divide_with_remainder(value: int32, divisor: int32) -> tuple<int32, int32> {
  return { value / divisor, value % divisor };
}

func main() -> int32 {
  let (quotient, remainder) = divide_with_remainder(7, 2);
  Console.Println("商：{0}，余数：{1}", quotient, remainder);
  return 0;
}
```

The quotient is 3 and remainder 1. This example always divides by two; a real
variable-divisor API must handle zero, using the error techniques in lesson 06.

## Exercise

Define a rectangle and a method computing its area.

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
  let rectangle: Rectangle = Rectangle { width: 6, height: 7 };
  Console.Println("面积：{0}", rectangle.Area());
  return 0;
}
```

Expected area: 42.
