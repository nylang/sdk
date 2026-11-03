# 06 · 函数、参数、返回值与借用

[English](../en/fundamentals/06-functions.md) · [上一课](05-loops.md) · [基础目录](README.md) · [下一课](07-arrays.md)

## 本课目标

函数给一段有明确输入输出的计算起名字。先从整数纯计算开始，再区分传入值和借用修改调用者，最后认识可选命名参数。不要一开始就把参数、泛型和接口混在一起。

## 先读语法，再看程序

`func name(parameter: Type) -> ResultType` 后接实现体。调用时实参先求值，再按参数合同进入函数。void 表示不返回结果值。非公开纯辅助函数用 snake_case；有明确所属类型的行为稍后改用 method。

## 例 1：整数参数是独立的值

[下载源码](../examples/fundamentals/value-parameter/main.ny) · [package.yaml](../examples/fundamentals/value-parameter/package.yaml) · [expected.txt](../examples/fundamentals/value-parameter/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func plus_two(value: int32) -> int32 {
  return value + 2;
}

func main() -> int32 {
  let original: int32 = 20;
  let result: int32 = plus_two(original);

  Console.Println("original={0}, result={1}", original, result);

  return 0;
}
```

预期输出：

```text
original=20, result=22
```

返回值并不会自动覆盖 original。result 接收计算结果。不要把这个整数例子的值复制规则推广为所有字符串、容器都会深复制。

## 例 2：明确修改调用者

[下载源码](../examples/fundamentals/borrow-parameter/main.ny) · [package.yaml](../examples/fundamentals/borrow-parameter/package.yaml) · [expected.txt](../examples/fundamentals/borrow-parameter/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func add_two(value: ref mut int32) -> void {
  value = value + 2;
}

func main() -> int32 {
  var count: int32 = 40;
  add_two(count);

  Console.Println("count={0}", count);

  return 0;
}
```

预期输出：

```text
count=42
```

ref mut 是可变借用，修改的是调用者的 count。调用时直接传变量，不需要显式 &mut。它不是原始指针参数，也不让函数在返回后随意保存这次借用。

## 例 3：带默认值的命名选项

[下载源码](../examples/fundamentals/named-parameter/main.ny) · [package.yaml](../examples/fundamentals/named-parameter/package.yaml) · [expected.txt](../examples/fundamentals/named-parameter/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func total_price(unit: int32, quantity: int32, {discount: int32 = 0}) -> int32 {
  return unit * quantity - discount;
}

func main() -> int32 {
  Console.Println("plain={0}, discounted={1}", total_price(12, 4), total_price(12, 4, discount: 6));

  return 0;
}
```

预期输出：

```text
plain=48, discounted=42
```

unit 和 quantity 是必填位置参数；discount 在尾部花括号参数袋中，是可省略命名选项。调用写 discount: 6，不在调用处写花括号。

## 常见错误与边界

不在必填位置参数上随意写默认值；不能把命名选项当第三个位置参数传。一个需要所有路径返回 int32 的函数不能只在某个 if 中 return。

## 练习：先自己写，再看答案

写一个 clamp_score(value: int32) -> int32：小于 0 返回 0，大于 100 返回 100，其余原样返回。用 -1、42、101 调用。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/06-functions-answer/main.ny) · [package.yaml](../examples/fundamentals/06-functions-answer/package.yaml) · [expected.txt](../examples/fundamentals/06-functions-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func clamp_score(value: int32) -> int32 {
  if value < 0 {
    return 0;
  }

  if value > 100 {
    return 100;
  }

  return value;
}

func main() -> int32 {
  Console.Println("{0},{1},{2}", clamp_score(-1), clamp_score(42), clamp_score(101));

  return 0;
}
```

预期输出：

```text
0,42,100
```

按顺序写两个早返回 guard，最后 return value。三个结果分别为 0、42、100；原输入绑定不因这次调用而改变。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](05-loops.md) · [基础目录](README.md) · [下一课](07-arrays.md)
