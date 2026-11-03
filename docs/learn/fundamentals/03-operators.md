# 03 · 运算、比较与表达式

[English](../en/fundamentals/03-operators.md) · [上一课](02-values.md) · [基础目录](README.md) · [下一课](04-conditions.md)

## 本课目标

表达式计算一个值，语句安排一次动作。先掌握算术、比较和逻辑运算，再进入条件分支。用括号表达意图比死记所有优先级更适合初学。

## 先读语法，再看程序

`+ - * / %` 是算术；`== != < <= > >=` 得到 bool；`&& || !` 是布尔逻辑。`=` 更新变量，不是比较。`*` 和 `/` 比 `+` 和 `-` 优先；有疑问就加括号。

## 例 1：整数除法与余数

[下载源码](../examples/fundamentals/division/main.ny) · [package.yaml](../examples/fundamentals/division/package.yaml) · [expected.txt](../examples/fundamentals/division/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let value: int32 = 17;
  let divisor: int32 = 5;

  Console.Println("quotient={0}, remainder={1}", value / divisor, value % divisor);
  Console.Println("grouped={0}", (2 + 3) * 4);

  return 0;
}
```

预期输出：

```text
quotient=3, remainder=2
grouped=20
```

整数除法向零截断，不得到 3.4。17 = 3 * 5 + 2。除数固定为正的 5；真实输入必须先检查不能为零。

## 例 2：多个条件与短路

[下载源码](../examples/fundamentals/logic/main.ny) · [package.yaml](../examples/fundamentals/logic/package.yaml) · [expected.txt](../examples/fundamentals/logic/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let age: int32 = 20;
  let has_ticket: bool = true;
  let cancelled: bool = false;

  if age >= 18 && has_ticket && !cancelled {
    Console.Println("admitted");
  }

  let divisor: int32 = 0;
  if divisor != 0 && 12 / divisor > 1 {
    Console.Println("large quotient");
  }

  return 0;
}
```

预期输出：

```text
admitted
```

&& 左边为 false 就不求右边，因此第二个 if 不执行除零。|| 左边为 true 时也跳过右边。不要用按位 &、| 替代逻辑运算。

## 例 3：用位表示开关

[下载源码](../examples/fundamentals/bits/main.ny) · [package.yaml](../examples/fundamentals/bits/package.yaml) · [expected.txt](../examples/fundamentals/bits/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let read_flag: uint32 = 1u;
  let write_flag: uint32 = 2u;
  let flags: uint32 = read_flag | write_flag;

  Console.Println("flags={0}, shifted={1}", flags, 1u << 3u);
  if (flags & read_flag) != 0u {
    Console.Println("read enabled");
  }

  return 0;
}
```

预期输出：

```text
flags=3, shifted=8
read enabled
```

按位或把两个位置的位组合起来，按位与检查某一位。移位只演示范围内的正数；不要用越界位数或未核对的符号行为做业务判断。

## 常见错误与边界

括号可读性优先：写 `(flags & read_flag) != 0u`，不要让读者猜结合顺序。比较两个数用 ==，检查字符串内容不要转为原始地址比较。

## 练习：先自己写，再看答案

设总秒数为 125，计算分钟和剩余秒数。再把总秒数换成 59 和 180。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/03-operators-answer/main.ny) · [package.yaml](../examples/fundamentals/03-operators-answer/package.yaml) · [expected.txt](../examples/fundamentals/03-operators-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let total: int32 = 125;
  Console.Println("minutes={0}, seconds={1}", total / 60, total % 60);

  return 0;
}
```

预期输出：

```text
minutes=2, seconds=5
```

分别用 total / 60、total % 60。结果是 2 分 5 秒、0 分 59 秒、3 分 0 秒。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](02-values.md) · [基础目录](README.md) · [下一课](04-conditions.md)
