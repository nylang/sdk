# 05 · 循环、范围、break 与 continue

[English](../en/fundamentals/05-loops.md) · [上一课](04-conditions.md) · [基础目录](README.md) · [下一课](06-functions.md)

## 本课目标

循环反复执行一个块。本课把循环拆成起点、条件、更新和结果四部分，先手算几轮，再运行。这样能看懂少算一项、多算一项和死循环的原因。

## 先读语法，再看程序

while 每轮先判断条件；for 范围 `a..b` 包含 a、不包含 b。break 离开最近一层循环；continue 跳过当前轮剩余语句。循环变量和累计结果不是同一个职责。

## 例 1：逐轮累计

[下载源码](../examples/fundamentals/while-sum/main.ny) · [package.yaml](../examples/fundamentals/while-sum/package.yaml) · [expected.txt](../examples/fundamentals/while-sum/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var number: int32 = 1;
  var total: int32 = 0;
  while number <= 5 {
    total = total + number;
    number = number + 1;
  }

  Console.Println("sum={0}, next={1}", total, number);

  return 0;
}
```

预期输出：

```text
sum=15, next=6
```

进入第一轮前 total=0、number=1；第一轮后变为 1、2。第五轮后是 15、6，条件不成立退出。更新 number 是让循环收敛的一部分。

## 例 2：范围与跳过

[下载源码](../examples/fundamentals/range-control/main.ny) · [package.yaml](../examples/fundamentals/range-control/package.yaml) · [expected.txt](../examples/fundamentals/range-control/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  for number in 0..10 {
    if number == 7 {
      break;
    }

    if number % 2 != 0 {
      continue;
    }

    Console.Println("{0}", number);
  }

  return 0;
}
```

预期输出：

```text
0
2
4
6
```

到 7 时 break，8 和 9 不再访问。到奇数时 continue，只跳过这一轮输出。范围上限 10 本来就不包含。

## 例 3：嵌套循环的执行次数

[下载源码](../examples/fundamentals/nested-loop/main.ny) · [package.yaml](../examples/fundamentals/nested-loop/package.yaml) · [expected.txt](../examples/fundamentals/nested-loop/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var count: int32 = 0;
  for row in 0..2 {
    for column in 0..3 {
      count = count + 1;
    }
  }

  Console.Println("cells={0}", count);

  return 0;
}
```

预期输出：

```text
cells=6
```

每一行都重新遍历三列，共 2 * 3 次。break 只退出最近一层；若要结束整个函数，用 return，但那也会结束函数的剩余工作。

## 常见错误与边界

while 内遗漏更新会一直重复；把更新放在可能被 continue 跳过的位置也可能不终止。不要用 C 的 `for (i=0; ...; ...)` 替代范围语法。

## 练习：先自己写，再看答案

用 for 累计 1 到 10 中的偶数，不打印中间值。再把上限改成 11，解释结果为何相同。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/05-loops-answer/main.ny) · [package.yaml](../examples/fundamentals/05-loops-answer/package.yaml) · [expected.txt](../examples/fundamentals/05-loops-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var total: int32 = 0;
  for number in 1..11 {
    if number % 2 == 0 {
      total = total + number;
    }
  }

  Console.Println("total={0}", total);

  return 0;
}
```

预期输出：

```text
total=30
```

使用 1..11 和 number % 2 == 0，结果 30；1..12 额外包含 11，但它是奇数。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](04-conditions.md) · [基础目录](README.md) · [下一课](06-functions.md)
