# 16 · 泛型：类型参数、推导与约束

[English](../en/intermediate/16-generics.md) · [上一课](../fundamentals/15-interface-design.md) · [本阶段目录](README.md) · [下一课](17-lambda.md)

## 本课目标

泛型不是把值变成“任意东西”，而是让同一个定义在明确的类型上使用。先用数字函数，再用泛型结构体，最后把接口约束接到已学过的方法合同。

## 语法与合同

T 是类型参数；T: num 允许数字操作，但不是运行时字段类型。Box<int32> 与 Box<string> 是不同具体类型。能从实参推导时可省略显式类型实参；约束必须支持函数体使用的操作。泛型定义的可见体用于实例化，不代表任意类型都满足合同。

## 例 1：显式类型与自动推导

[源码](../examples/intermediate/generic-numbers/main.ny) · [package.yaml](../examples/intermediate/generic-numbers/package.yaml) · [expected.txt](../examples/intermediate/generic-numbers/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func larger<T: num>(left: T, right: T) -> T {
  if left > right {
    return left;
  }

  return right;
}

func main() -> int32 {
  let first: int32 = larger<int32>(20, 42);
  let second: int32 = larger(30, 12);

  Console.Println("first={0}, second={1}", first, second);

  return 0;
}
```

预期输出：

```text
first=42, second=30
```

两次调用都实例化为 int32。类型参数放在函数名后，值参数放在圆括号中；两组括号不是同一种参数。

## 例 2：泛型类型上的方法

[源码](../examples/intermediate/generic-box/main.ny) · [package.yaml](../examples/intermediate/generic-box/package.yaml) · [expected.txt](../examples/intermediate/generic-box/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Box<T> {
  value: T;
}

method(Box<T>) Get() -> T {
  return self.value;
}

func main() -> int32 {
  let number: Box<int32> = Box<int32>{ value: 42 };
  let word: Box<string> = Box<string>{ value: "Nyra" };

  Console.Println("{0}={1}", word.Get(), number.Get());

  return 0;
}
```

预期输出：

```text
Nyra=42
```

method(Box<T>) 保持接收者类型参数。Get 返回对应的 T，不把 int32 强行转换成 string。拥有资源字段的复制／移动规则仍然适用。

## 例 3：接口约束让方法调用有依据

[源码](../examples/intermediate/generic-contract/main.ny) · [package.yaml](../examples/intermediate/generic-contract/package.yaml) · [expected.txt](../examples/intermediate/generic-contract/expected.txt)

```nyra
import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct Card implements Scored {
  points: int32;
}

method(Card) Score() -> int32 {
  return self.points;
}

func read_score<T: Scored>(value: T) -> int32 {
  return value.Score();
}

func main() -> int32 {
  let card: Card = Card{ points: 42 };
  Console.Println("score={0}", read_score(card));

  return 0;
}
```

预期输出：

```text
score=42
```

泛型调用者知道具体 T，并要求 Scored。不要把这一种受约束实例化与所有调用都经接口表的模型混为一谈。

## 常见错误与边界

没有约束的 T 不能凭空使用数字或任意成员操作。num/real 不能作为普通存储字段。不要用 as 掩盖不满足的约束，也不要把未来的变参类型包当成现有泛型。

## 练习

写 smaller<T: num>，用 20、42 调用。结果应为 20。

<details>
<summary>完整参考答案</summary>

[源码](../examples/intermediate/generic-answer/main.ny) · [package.yaml](../examples/intermediate/generic-answer/package.yaml) · [expected.txt](../examples/intermediate/generic-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func smaller<T: num>(left: T, right: T) -> T {
  if left < right {
    return left;
  }

  return right;
}

func main() -> int32 {
  Console.Println("smaller={0}", smaller<int32>(20, 42));

  return 0;
}
```

预期输出：

```text
smaller=20
```

只改变比较方向，类型约束仍为 num。

</details>

[上一课](../fundamentals/15-interface-design.md) · [本阶段目录](README.md) · [下一课](17-lambda.md)
