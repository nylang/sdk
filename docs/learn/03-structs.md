# 03 · 用结构体组织数据

[English](en/03-structs.md)

[上一课](02-control-functions.md) · [教程目录](README.md) · [下一课](04-ownership.md)

如果一本书既有书名，又有价格，把它们放在一起会比维护几个零散变量更清楚。

## 1. 定义一类数据

完整程序：

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

`struct Book` 定义数据形状。`title` 和 `price` 称为字段。
`Book { ... }` 创建一个值；`book.title` 读取其中的字段。

类型名字写作 `Book`，变量名字写作 `book`。这两个名字不是同一个东西。

## 2. 给数据增加行为

在上面的 `Book` 后面、`main` 前面加上：

```nyra
method(Book) DiscountedPrice(discount: int32) -> int32 {
  return self.price - discount;
}
```

在 `main` 里面调用：

```nyra
Console.Println("优惠后：{0} 元", book.DiscountedPrice(5));
```

`method(Book)` 表示这是 `Book` 的方法。
调用时，点号左边的 `book` 就是方法里面的 `self`。
方法写在结构体外面，不是塞进字段列表里。

## 3. 修改一个值

完整程序：

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

预期输出 `计数：5`。`void` 表示方法不返回一个结果值。

## 4. 静态方法和属性

给 `Counter` 再增加两个定义，放在 `main` 外面：

```nyra
static method(Counter) Zero() -> Counter {
  return Counter { value: 0 };
}

method(Counter) get is_zero -> bool {
  return self.value == 0;
}
```

调用片段：

```nyra
let empty: Counter = Counter.Zero();
Console.Println("是否为零：{0}", empty.is_zero);
```

`Counter.Zero()` 不依赖某个现成的计数器，所以是静态方法。
`is_zero` 是读取属性，调用时不写括号。

## 5. 用 `enum` 表示有限的选择

完整程序：

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

`switch` 从几种情况中选择一项。Nyra 的分支不会自动继续执行下一个分支，不需要额外写 `break`。

## 补充：只想临时返回两个结果

结构体适合有名字、有意义的一组数据。只想临时带回两个数，也可以用元组。
下面是独立的完整程序：

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

结果是商 3、余数 1。这个例子固定除以 2，不会除以零。
真实接口要考虑除数为零；第 06 课再介绍带失败原因的返回值。

## 练习与参考答案

定义一个矩形，给它增加计算面积的方法。

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

预期面积是 42。
