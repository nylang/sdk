# 01 · 从一行输出读懂程序

[English](../en/fundamentals/01-program.md) · [上一课](../00-start.md) · [基础目录](README.md) · [下一课](02-values.md)

## 本课目标

先不定义自己的类型。把程序看作一组按顺序执行的语句：从 main 进入，做事情，然后返回给操作系统。读完本课应能分清源码、输出、函数体、语句和退出码。

## 先读语法，再看程序

`import "stdlib:stdlib.ny";` 让当前文件能使用标准库公开名字。`func main() -> int32` 定义入口，`()` 是空参数列表，`-> int32` 是返回类型。`{` 与 `}` 围住函数体；普通语句用 `;` 结束。Console 是库中类型，不是语言关键字。

## 例 1：最小输出

[下载源码](../examples/fundamentals/hello/main.ny) · [package.yaml](../examples/fundamentals/hello/package.yaml) · [expected.txt](../examples/fundamentals/hello/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("Hello, Nyra!");

  return 0;
}
```

预期输出：

```text
Hello, Nyra!
```

运行到 Println 才产生这一行；import 本身不打印。return 0 表示正常结束，不会把数字 0 打印出来。

## 例 2：按顺序执行与注释

[下载源码](../examples/fundamentals/sequence/main.ny) · [package.yaml](../examples/fundamentals/sequence/package.yaml) · [expected.txt](../examples/fundamentals/sequence/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  // Explain intent; this line is not executed.
  Console.Println("first");
  Console.Println("second");

  return 0;
}
```

预期输出：

```text
first
second
```

两条输出按照书写顺序执行。双斜线到行末是注释；字符串内的文字是数据。交换两条语句，输出顺序随之交换。

## 例 3：输出一个计算结果

[下载源码](../examples/fundamentals/format/main.ny) · [package.yaml](../examples/fundamentals/format/package.yaml) · [expected.txt](../examples/fundamentals/format/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("answer={0}", 20 + 22);

  return 0;
}
```

预期输出：

```text
answer=42
```

{0} 使用字符串后第一个参数。20 + 22 先计算成 42，再交给输出操作。预期输出块不是要粘入 main.ny 的源码。

## 常见错误与边界

不要写成 C 的 `int main()`，不要遗漏分号，也不要把多个完整例子的 main 合并。若编译失败，先修正报错，不运行旧输出文件。

## 练习：先自己写，再看答案

输出两行：第一行 ready，第二行 total=42。尝试解释为什么 return 0 不会成为第三行。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/01-program-answer/main.ny) · [package.yaml](../examples/fundamentals/01-program-answer/package.yaml) · [expected.txt](../examples/fundamentals/01-program-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("ready");
  Console.Println("total={0}", 6 * 7);

  return 0;
}
```

预期输出：

```text
ready
total=42
```

保留 import 和 main；依次调用 `Console.Println("ready");` 与 `Console.Println("total={0}", 6 * 7);`，最后 return 0。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](../00-start.md) · [基础目录](README.md) · [下一课](02-values.md)
