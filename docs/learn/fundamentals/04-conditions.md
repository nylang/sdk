# 04 · if、else、switch 与早返回

[English](../en/fundamentals/04-conditions.md) · [上一课](03-operators.md) · [基础目录](README.md) · [下一课](05-loops.md)

## 本课目标

分支只选择某些语句执行。先读一个条件，再读一串互斥条件，最后用 switch 表达离散选项。本课不把 switch、枚举、结构体和接口一起引入。

## 先读语法，再看程序

`if condition { ... } else { ... }` 的条件是 bool。else if 从上到下选第一个匹配项。switch 的 case 后写冒号，随后是该分支语句；匹配分支不会自动落到下一个 case。return 结束整个当前函数。

## 例 1：互斥条件的顺序

[下载源码](../examples/fundamentals/grades/main.ny) · [package.yaml](../examples/fundamentals/grades/package.yaml) · [expected.txt](../examples/fundamentals/grades/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let score: int32 = 85;
  if score >= 90 {
    Console.Println("excellent");
  } else if score >= 60 {
    Console.Println("pass");
  } else {
    Console.Println("retry");
  }

  return 0;
}
```

预期输出：

```text
pass
```

85 没达到 90，第二个条件满足。若先写 score >= 60，90 分也会先进入 pass，后面的优秀分支就没有机会。边界 59、60、89、90 值得逐个修改观察。

## 例 2：离散命令与 default

[下载源码](../examples/fundamentals/switch/main.ny) · [package.yaml](../examples/fundamentals/switch/package.yaml) · [expected.txt](../examples/fundamentals/switch/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let command: int32 = 2;
  switch command {
    case 1:
      Console.Println("start");
    case 2:
      Console.Println("stop");
    default:
      Console.Println("unknown");
  }

  return 0;
}
```

预期输出：

```text
stop
```

command 只求值后用于匹配。case 2: 后的语句属于这一分支，不需要为防止落入 default 而补 break。修改成 7 会进入 default。

## 例 3：先拒绝无效输入

[下载源码](../examples/fundamentals/guard/main.ny) · [package.yaml](../examples/fundamentals/guard/package.yaml) · [expected.txt](../examples/fundamentals/guard/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func admitted_count(count: int32) -> int32 {
  if count < 0 {
    return 0;
  }

  return count;
}

func main() -> int32 {
  Console.Println("bad={0}, good={1}", admitted_count(-1), admitted_count(3));

  return 0;
}
```

预期输出：

```text
bad=0, good=3
```

这个局部纯函数先处理非法负数，再给正常路径留出清楚的一段。这里用 0 是教学业务规则，不是所有错误都该用 0 掩盖；后续错误处理课会讲 Result。

## 常见错误与边界

不要把两个独立 if 当成互斥 else if；两个 if 可以都执行。不要因为某个分支很短就把多条语句挤在一行。

## 练习：先自己写，再看答案

按温度输出 freezing（小于 0）、cool（0 到 19）、warm（20 以上）。测试 -1、0、19、20。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/04-conditions-answer/main.ny) · [package.yaml](../examples/fundamentals/04-conditions-answer/package.yaml) · [expected.txt](../examples/fundamentals/04-conditions-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func show_temperature(temperature: int32) -> void {
  if temperature < 0 {
    Console.Println("freezing");
  } else if temperature < 20 {
    Console.Println("cool");
  } else {
    Console.Println("warm");
  }
}

func main() -> int32 {
  show_temperature(-1);
  show_temperature(0);
  show_temperature(19);
  show_temperature(20);

  return 0;
}
```

预期输出：

```text
freezing
cool
cool
warm
```

先检查 temperature < 0，再检查 temperature < 20，最后 else。输出顺序应是 freezing、cool、cool、warm。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](03-operators.md) · [基础目录](README.md) · [下一课](05-loops.md)
