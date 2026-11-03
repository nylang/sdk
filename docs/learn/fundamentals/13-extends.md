# 13 · struct extends：布局扩展与父类型方法

[English](../en/fundamentals/13-extends.md) · [上一课](12-properties.md) · [基础目录](README.md) · [下一课](14-interfaces.md)

## 本课目标

本课只讲结构体 extends，下一课才讲接口。extends 表示把一个已知基础布局扩展成更具体的布局；它不把结构体变成具有虚方法的类。用三个独立例子区分字段、父方法和组合。

## 先读语法，再看程序

`struct ColoredPoint extends Point` 最多有一个结构体基类。派生值包含基础字段，并增加自己的字段。方法调用在静态已知的结构体类型上解析；没有隐式 vptr/vtable，不存在自动动态选择子方法的保证。

## 例 1：基础字段和新增字段

[下载源码](../examples/fundamentals/extends-fields/main.ny) · [package.yaml](../examples/fundamentals/extends-fields/package.yaml) · [expected.txt](../examples/fundamentals/extends-fields/expected.txt)

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

预期输出：

```text
x=20, y=22, color=7
```

ColoredPoint 的字面量初始化基础 x、y 以及新增 color；不是嵌套一个叫 Point 的字段。可见 color 并不能证明有虚函数表。不要重新声明同名基础字段来“覆盖”存储。

## 例 2：调用已知父方法并操作同一基础存储

[下载源码](../examples/fundamentals/extends-methods/main.ny) · [package.yaml](../examples/fundamentals/extends-methods/package.yaml) · [expected.txt](../examples/fundamentals/extends-methods/expected.txt)

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

预期输出：

```text
sum=43, color=7
```

ColoredPoint 没有另写 MoveX 或 Sum，查找使用已知 Point 实现。MoveX 修改的是该对象的基础 x，不是复制一份父对象再丢掉。color 不参与这两项操作。这里没有子同名方法的虚重写。

## 例 3：如果只是“有一个点”，改用组合

[下载源码](../examples/fundamentals/composition/main.ny) · [package.yaml](../examples/fundamentals/composition/package.yaml) · [expected.txt](../examples/fundamentals/composition/expected.txt)

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

预期输出：

```text
sum=42
```

Marker 有一个 position，因此路径明确为 marker.position.Sum()。组合不会自动暴露 Point 所有操作。若只是共享一项数据或一段能力，显式字段通常比建立类型扩展关系容易维护。

## 常见错误与边界

不要从 C++／Java 类模型推断 virtual、构造链或任意父子转换。extends 不自动调用名为 Init 的方法，也不把静态方法和工厂当成实例初始化链。本课不使用开发中的 init/super/@override 扩展。

## 练习：先自己写，再看答案

为 ColoredPoint 写一个只属于派生类型的 ColorCode() 方法；保持 Point 的两个方法不变。说明哪部分是新增行为，哪部分来自基础类型。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/13-extends-answer/main.ny) · [package.yaml](../examples/fundamentals/13-extends-answer/package.yaml) · [expected.txt](../examples/fundamentals/13-extends-answer/expected.txt)

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

预期输出：

```text
sum=43, color=7
```

`method(ColoredPoint) ColorCode() -> int32` 返回 self.color。MoveX/Sum 来自基础类型的已知实现，ColorCode 是派生类型新增的静态解析实例操作。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](12-properties.md) · [基础目录](README.md) · [下一课](14-interfaces.md)
