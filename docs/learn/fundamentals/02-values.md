# 02 · 变量、类型、赋值与作用域

[English](../en/fundamentals/02-values.md) · [上一课](01-program.md) · [基础目录](README.md) · [下一课](03-operators.md)

## 本课目标

变量把一个值和名字联系起来。本课只用数字、布尔值与字符串，不引入对象所有权。学习声明、读取、赋值和作用域后，才能解释循环或方法为什么改变了某个值。

## 先读语法，再看程序

声明顺序是 `let 名字: 类型 = 初值;` 或 `var 名字: 类型 = 初值;`。let 不允许重新赋值；var 允许。赋值先求右边的值，再更新左边。一个块中的局部名字只在相应作用域内有效。

## 例 1：不变的单价与可变的数量

[下载源码](../examples/fundamentals/bindings/main.ny) · [package.yaml](../examples/fundamentals/bindings/package.yaml) · [expected.txt](../examples/fundamentals/bindings/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let unit_price: int32 = 12;
  var quantity: int32 = 2;
  quantity = quantity + 1;

  Console.Println("quantity={0}, total={1}", quantity, unit_price * quantity);

  return 0;
}
```

预期输出：

```text
quantity=3, total=36
```

读 quantity 得到旧值 2，加 1 后把 3 写回。unit_price 没有修改，使用 let。冒号是类型标注，不是赋值。

## 例 2：整数转换与小数运算

[下载源码](../examples/fundamentals/numeric-types/main.ny) · [package.yaml](../examples/fundamentals/numeric-types/package.yaml) · [expected.txt](../examples/fundamentals/numeric-types/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let small: int32 = 42;
  let wide: int64 = small;
  let precise: float64 = 5.0 / 2.0;

  if precise == 2.5 {
    Console.Println("wide={0}, fraction=2.5", wide);
  }

  return 0;
}
```

预期输出：

```text
wide=42, fraction=2.5
```

int32 到 int64 的同向扩宽可隐式完成。5.0 是 float64 字面量。这里不依赖浮点打印格式；分支只是检查这个可精确表示的结果。类型转换不应被当成任意数据校验。

## 例 3：块内临时量与外层结果

[下载源码](../examples/fundamentals/scope/main.ny) · [package.yaml](../examples/fundamentals/scope/package.yaml) · [expected.txt](../examples/fundamentals/scope/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var total: int32 = 10;
  if total > 0 {
    let extra: int32 = 5;
    total = total + extra;
  }

  Console.Println("total={0}", total);

  return 0;
}
```

预期输出：

```text
total=15
```

total 在外层声明，块内更新的是同一个变量；extra 在块内声明，块结束后不能再用。花括号不仅排版，还限定局部名字的可见范围。

## 常见错误与边界

`let n: int32 = 1;` 后不能写 `n = 2;`。不要把字符串 "42" 当整数 42；窄化和有损转换要明确意图，不能靠 as 保证不溢出。初始化一个带类型的零值可直接写 0。

## 练习：先自己写，再看答案

把初始数量改为 4，再增加 2，单价保持 12。预先计算应输出多少，再运行。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/02-values-answer/main.ny) · [package.yaml](../examples/fundamentals/02-values-answer/package.yaml) · [expected.txt](../examples/fundamentals/02-values-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let unit_price: int32 = 12;
  var quantity: int32 = 4;
  quantity = quantity + 2;

  Console.Println("quantity={0}, total={1}", quantity, unit_price * quantity);

  return 0;
}
```

预期输出：

```text
quantity=6, total=72
```

数量为 6，总价为 72；只修改 quantity 的初值和加数，不需要修改输出格式。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](01-program.md) · [基础目录](README.md) · [下一课](03-operators.md)
