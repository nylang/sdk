# 07 · 本地数组、下标与字符串

[English](../en/fundamentals/07-arrays.md) · [上一课](06-functions.md) · [基础目录](README.md) · [下一课](08-addresses.md)

## 本课目标

一组同类型数字适合放进数组。本课先用固定数量的本地元素，不要求先掌握动态容器和泛型实现。字符串也有长度，但字符串的字节数量不一定等于人看到的字符数量。

## 先读语法，再看程序

本地数组变量可写 `<int32>[]`，初始化列表写 `{ 10, 20, 30 }`。下标从 0 开始，三个元素的有效下标是 0、1、2。数组不是随意越界访问内存的许可。

## 例 1：读取与修改一个元素

[下载源码](../examples/fundamentals/array-index/main.ny) · [package.yaml](../examples/fundamentals/array-index/package.yaml) · [expected.txt](../examples/fundamentals/array-index/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var scores: <int32>[] = { 10, 20, 30 };
  scores[1] = 42;

  Console.Println("first={0}, second={1}, last={2}", scores[0], scores[1], scores[2]);

  return 0;
}
```

预期输出：

```text
first=10, second=42, last=30
```

下标 1 指第二个元素。写 scores[1] 只改该位置，并不把整个数组换成一个数。这里是本地数组，不是 stdlib Array<T> 的共享存储合同。

## 例 2：按有效下标遍历

[下载源码](../examples/fundamentals/array-sum/main.ny) · [package.yaml](../examples/fundamentals/array-sum/package.yaml) · [expected.txt](../examples/fundamentals/array-sum/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let values: <int32>[] = { 10, 20, 12 };
  var total: int32 = 0;
  for index in 0..3 {
    total = total + values[index];
  }

  Console.Println("total={0}", total);

  return 0;
}
```

预期输出：

```text
total=42
```

范围 0..3 访问 0、1、2，正好三次。这里的 3 与初始化列表长度一致；可变长度业务应让长度和存储一起管理，不复制一个可能失配的常量。

## 例 3：字符串是值，不是 char*

[下载源码](../examples/fundamentals/string-value/main.ny) · [package.yaml](../examples/fundamentals/string-value/package.yaml) · [expected.txt](../examples/fundamentals/string-value/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let greeting: string = "Hello";
  let message: string = greeting.Concat(", Nyra");

  Console.Println("{0}", message);
  Console.Println("ascii-bytes={0}", greeting.length);

  return 0;
}
```

预期输出：

```text
Hello, Nyra
ascii-bytes=5
```

Concat 和 length 是标准库／内置类型提供的成员操作，下一阶段再学习怎样自己写方法。这里全是 ASCII 字节。不要把中文字符串的 length 当汉字数量；也不能假定 string 有 C 的零结尾。

## 常见错误与边界

三个元素不能读第 3 号下标；不要为了观察输出故意执行越界程序。动态 Array<T> 的 Get/Set 与本地数组不是完全相同的所有权模型，后续数据课单独讲。

## 练习：先自己写，再看答案

把数组换成 { 3, 1, 4, 2 }，用循环找最大值。先把 maximum 设为第一个元素，再逐个比较。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/07-arrays-answer/main.ny) · [package.yaml](../examples/fundamentals/07-arrays-answer/package.yaml) · [expected.txt](../examples/fundamentals/07-arrays-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let values: <int32>[] = { 3, 1, 4, 2 };
  var maximum: int32 = values[0];
  for index in 1..4 {
    if values[index] > maximum {
      maximum = values[index];
    }
  }

  Console.Println("maximum={0}", maximum);

  return 0;
}
```

预期输出：

```text
maximum=4
```

遍历 1..4，遇到更大的值就更新 maximum，最后是 4。不要无条件把 maximum 初始化为 0，否则全负数输入会出错。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](06-functions.md) · [基础目录](README.md) · [下一课](08-addresses.md)
