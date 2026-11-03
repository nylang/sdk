# 09 · struct：字段、字面量、嵌套与值

[English](../en/fundamentals/09-struct-data.md) · [上一课](08-addresses.md) · [基础目录](README.md) · [下一课](10-methods.md)

## 本课目标

现在开始定义自己的数据。一个点有 x、y；一张订单有单价和数量。struct 把相关字段放在一个有意义的类型里。这一课暂时不写方法、继承或接口。

## 先读语法，再看程序

结构体字段写在大括号内，每个字段用分号结束。`Point{ x: 3, y: 4 }` 是字面量，字段初始化用冒号和逗号；`point.x` 读取字段。类型名不是变量名。

## 例 1：完整初始化和部分初始化

[下载源码](../examples/fundamentals/struct-fields/main.ny) · [package.yaml](../examples/fundamentals/struct-fields/package.yaml) · [expected.txt](../examples/fundamentals/struct-fields/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

func main() -> int32 {
  let first: Point = Point{ x: 3, y: 4 };
  let second: Point = Point{ x: 9 };

  Console.Println("first={0},{1}", first.x, first.y);
  Console.Println("second={0},{1}", second.x, second.y);

  return 0;
}
```

预期输出：

```text
first=3,4
second=9,0
```

省略的标量字段按零初始化，因此 second.y 是 0。省略字段不是调用一个隐藏构造函数；是否允许零值参与业务必须由类型设计决定。

## 例 2：两个仅含整数的值互不联动

[下载源码](../examples/fundamentals/struct-values/main.ny) · [package.yaml](../examples/fundamentals/struct-values/package.yaml) · [expected.txt](../examples/fundamentals/struct-values/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

func main() -> int32 {
  let original: Point = Point{ x: 3, y: 4 };
  var changed: Point = original;
  changed.x = 10;

  Console.Println("original={0}, changed={1}", original.x, changed.x);

  return 0;
}
```

预期输出：

```text
original=3, changed=10
```

这里只包含普通整数，改变 changed.x 不改变 original.x。若字段是共享句柄、容器或不可复制资源，必须按对应所有权合同理解，不能据此推断任意 struct 都深复制。

## 例 3：字段也可以是另一个结构体

[下载源码](../examples/fundamentals/nested-struct/main.ny) · [package.yaml](../examples/fundamentals/nested-struct/package.yaml) · [expected.txt](../examples/fundamentals/nested-struct/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

struct Bounds {
  origin: Point;
  width: int32;
}

func main() -> int32 {
  var box: Bounds = Bounds{ origin: Point{ x: 1, y: 2 }, width: 6 };
  box.origin.x = 10;

  Console.Println("x={0}, width={1}", box.origin.x, box.width);

  return 0;
}
```

预期输出：

```text
x=10, width=6
```

Bounds 有一个 Point，而不是 Point 的子类型。`box.origin.x` 沿明确字段访问；这一种“有一个”的关系叫组合，是后面理解 extends 的重要对照。

## 常见错误与边界

不要在字段列表里塞 method 实现；不要把字段声明的分号和字面量的逗号混淆。字段没有因为名字以 _ 开头就自动变成私有；跨模块封装要用真正的公开边界。

## 练习：先自己写，再看答案

定义 Rectangle，字段 width、height；创建 6×7 的值，用字段直接算面积；再创建一个只初始化 width 的值观察 height。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/09-struct-data-answer/main.ny) · [package.yaml](../examples/fundamentals/09-struct-data-answer/package.yaml) · [expected.txt](../examples/fundamentals/09-struct-data-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

func main() -> int32 {
  let full: Rectangle = Rectangle{ width: 6, height: 7 };
  let partial: Rectangle = Rectangle{ width: 6 };

  Console.Println("full={0}, partial={1}", full.width * full.height, partial.width * partial.height);

  return 0;
}
```

预期输出：

```text
full=42, partial=0
```

面积是 rectangle.width * rectangle.height，得到 42；省略的 height 为 0，面积也为 0。这正是后面需要业务创建入口和不变量的原因。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](08-addresses.md) · [基础目录](README.md) · [下一课](10-methods.md)
