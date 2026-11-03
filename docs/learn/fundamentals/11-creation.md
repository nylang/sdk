# 11 · 静态方法、普通值与命名工厂

[English](../en/fundamentals/11-creation.md) · [上一课](10-methods.md) · [基础目录](README.md) · [下一课](12-properties.md)

## 本课目标

实例方法需要已有对象，但有些操作就是用来创建对象。本课先从返回普通值的静态方法开始，再引入返回拥有对象的 factory。两者都从类型调用，但返回合同不同。

## 先读语法，再看程序

`static method(Point) Origin() -> Point` 没有 self，调用 Point.Origin()。`factory(Point) Make(...) -> unique<Point>` 也没有 self，调用 Point.Make(...)。factory 是命名拥有对象创建入口，不写 static factory。

## 例 1：类型级操作返回普通值

[下载源码](../examples/fundamentals/static-value/main.ny) · [package.yaml](../examples/fundamentals/static-value/package.yaml) · [expected.txt](../examples/fundamentals/static-value/expected.txt)

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

预期输出：

```text
x=0, y=0
```

Origin 没有接收一个旧 Point，不应访问 self.x。返回 Point 值并不需要 new，也不自动变成堆拥有对象。调用写类型名而不是 point.Origin。

## 例 2：命名工厂返回唯一拥有对象

[下载源码](../examples/fundamentals/owned-factory/main.ny) · [package.yaml](../examples/fundamentals/owned-factory/package.yaml) · [expected.txt](../examples/fundamentals/owned-factory/expected.txt)

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

预期输出：

```text
sum=42
```

冒号左边 x、y 是字段名，右边是同名参数。point 的类型是 unique<Point>，通过它调用 Point 的实例方法。拥有者离开生命周期后由语言清理，不另行 Free。

## 例 3：用不同名字表达不同创建意图

[下载源码](../examples/fundamentals/named-creation/main.ny) · [package.yaml](../examples/fundamentals/named-creation/package.yaml) · [expected.txt](../examples/fundamentals/named-creation/expected.txt)

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

预期输出：

```text
square=36, wide=42
```

Square 与 WithSize 用名字表达输入含义，不依赖重载。它们返回普通 Rectangle，所以使用 static method。真正返回 unique/rc/arc 的入口才使用对应 factory 合同。

## 常见错误与边界

不能在没有 self 的静态方法／工厂中使用 self。不要把 factory 的返回类型改为普通 Point 却仍叫它 factory；不要假定 Point{} 会自动执行 Make、Origin 或 Init。

## 练习：先自己写，再看答案

新增静态方法 Rectangle.Unit()，返回 1×1。再给 Point 新增工厂 OnXAxis(x)，创建 y 为 0 的 unique<Point>。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/11-creation-answer/main.ny) · [package.yaml](../examples/fundamentals/11-creation-answer/package.yaml) · [expected.txt](../examples/fundamentals/11-creation-answer/expected.txt)

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

预期输出：

```text
area=1, x=42, y=0
```

Unit 返回 Rectangle 字面量；OnXAxis 返回 new unique<Point>{ x: x, y: 0 }。两者都从类型调用，但变量类型和拥有权不同。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](10-methods.md) · [基础目录](README.md) · [下一课](12-properties.md)
