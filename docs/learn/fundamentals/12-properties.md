# 12 · get/set：字段访问与受控属性

[English](../en/fundamentals/12-properties.md) · [上一课](11-creation.md) · [基础目录](README.md) · [下一课](13-extends.md)

## 本课目标

字段直接存数据，属性把一次读取或写入交给方法。本课先写只读计算属性，再写带校验的 setter，最后把校验从创建入口复用。属性不是隐藏的普通字段。

## 先读语法，再看程序

getter 写 `method(T) get name -> Type`，没有参数括号。setter 写 `method(T) set name(value: Type)`。读属性用 obj.name，写属性用 obj.name = value；不是 obj.name()。后备字段与属性应取不同名字。

## 例 1：计算属性不额外存一份结果

[下载源码](../examples/fundamentals/getter/main.ny) · [package.yaml](../examples/fundamentals/getter/package.yaml) · [expected.txt](../examples/fundamentals/getter/expected.txt)

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

预期输出：

```text
area=42
```

area 每次读取时计算，没有第三个 area 字段需要同步。只有 getter 就不提供 area 的 setter；赋值 rectangle.area = 9 不是被许可的更新接口。

## 例 2：把写入检查放在一个位置

[下载源码](../examples/fundamentals/setter/main.ny) · [package.yaml](../examples/fundamentals/setter/package.yaml) · [expected.txt](../examples/fundamentals/setter/expected.txt)

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

预期输出：

```text
clamped=0
valid=42
```

value 是访问器名，current 是后备存储。setter 如果写 self.value = next 就会再次进入自身。截为 0 是本例明确的业务规则，重要数据也可用返回 Result 的普通方法报告拒绝原因。

## 例 3：创建入口复用属性不变量

[下载源码](../examples/fundamentals/property-creation/main.ny) · [package.yaml](../examples/fundamentals/property-creation/package.yaml) · [expected.txt](../examples/fundamentals/property-creation/expected.txt)

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

预期输出：

```text
initial=0
```

创建通过 setter 建立同一个规则，避免两套校验慢慢分叉。但字段布局可见的地方仍能直接写 current；真正隐藏布局需要模块与 .ni 边界，不是给字段起“私有风格”名字。

## 常见错误与边界

get/set 可以共享属性名，这是配对访问器，不是允许普通方法重载。属性不能保证调用零成本，也不适合掩藏让调用者意外的网络请求等副作用。

## 练习：先自己写，再看答案

为 Rectangle 增加 perimeter 只读属性。6×7 的周长应该是多少？改变字段后再读会怎样？

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/12-properties-answer/main.ny) · [package.yaml](../examples/fundamentals/12-properties-answer/package.yaml) · [expected.txt](../examples/fundamentals/12-properties-answer/expected.txt)

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

预期输出：

```text
before=26
after=34
```

返回 2 * (self.width + self.height)，得到 26。它每次重新计算，因此字段改变后不会留下过时的缓存值。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](11-creation.md) · [基础目录](README.md) · [下一课](13-extends.md)
