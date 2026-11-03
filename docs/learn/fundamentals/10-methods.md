# 10 · 实例方法：把行为放回数据类型

[English](../en/fundamentals/10-methods.md) · [上一课](09-struct-data.md) · [基础目录](README.md) · [下一课](11-creation.md)

## 本课目标

上一课会直接读取字段计算面积。本课把同一段计算命名为 Rectangle.Area，并解释调用者、接收类型、self、参数和返回值，之后再写修改状态的方法。

## 先读语法，再看程序

`method(Rectangle) Area() -> int32` 是独立的顶层声明，写在 struct 外。调用 `rectangle.Area()` 时，rectangle 是隐式接收者 self。self 不用在参数列表重复声明；普通参数继续放在括号内。

## 例 1：从字段计算到实例操作

[下载源码](../examples/fundamentals/area-method/main.ny) · [package.yaml](../examples/fundamentals/area-method/package.yaml) · [expected.txt](../examples/fundamentals/area-method/expected.txt)

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

预期输出：

```text
area=42
```

method 的接收类型是 Rectangle，self 是每次调用的具体值，不是全局变量。两个 Rectangle 值调用同一方法，各自读取自己的字段。

## 例 2：修改已有值

[下载源码](../examples/fundamentals/counter-method/main.ny) · [package.yaml](../examples/fundamentals/counter-method/package.yaml) · [expected.txt](../examples/fundamentals/counter-method/expected.txt)

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

预期输出：

```text
first=5, second=10
```

Add 接受的 amount 不包含接收者本身。first 使用 var 以便修改；调用 first.Add 不会自动修改 second。返回 void 说明这个操作靠副作用改变已有值。

## 例 3：一个方法复用另一个方法

[下载源码](../examples/fundamentals/method-chain/main.ny) · [package.yaml](../examples/fundamentals/method-chain/package.yaml) · [expected.txt](../examples/fundamentals/method-chain/expected.txt)

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

预期输出：

```text
area=42, doubled=84
```

类型内部复用也通过 self.Area 调用，不复制一套面积公式。Area 与 DoubleArea 名字不同，职责清楚；返回值并不会自动更新字段。

## 常见错误与边界

同一接收类型的普通方法不能仅靠参数不同重载。不同类型可以各自有 Area；这不是全局禁止同名。不要把实例方法写成 Rectangle.Area()，因为它需要一个实例。

## 练习：先自己写，再看答案

给 Counter 增加 Reset()，将 self.value 设为 0。先 Add(5)，再 Reset，再 Add(2)，检查最终值。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/10-methods-answer/main.ny) · [package.yaml](../examples/fundamentals/10-methods-answer/package.yaml) · [expected.txt](../examples/fundamentals/10-methods-answer/expected.txt)

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

预期输出：

```text
value=2
```

Reset 是 void 实例方法；最终值 2。不要为了 Reset 再建一个无关工具类型或传入重复的 Counter 参数。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](09-struct-data.md) · [基础目录](README.md) · [下一课](11-creation.md)
