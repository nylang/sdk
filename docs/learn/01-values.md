# 01 · 变量、类型和输出

[上一课](00-macos-start.md) · [教程目录](README.md) · [下一课](02-control-functions.md)

这一课学习如何记住一个数字或一段文字。仍然使用第 00 课的 `playground/main.ny`。
本课各个“完整程序”互相替换，不要同时粘进一个文件。

## 1. 给数据起名字

完整程序：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let name: string = "小明";
  let age: int32 = 18;
  Console.Println("你好，{0}，你今年 {1} 岁", name, age);
  return 0;
}
```

运行方式和上一课相同：

```sh
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/lesson01"
```

预期输出：

```text
你好，小明，你今年 18 岁
```

`name` 和 `age` 是你起的名字。
`string` 表示文字，`int32` 表示整数。冒号左边是名字，右边是类型，等号后面是初始值。

`{0}` 使用第一个附加参数，`{1}` 使用第二个附加参数，从 0 开始数。
Nyra 这里不是 `%s`，也不是直接把变量写进花括号。

## 2. `let` 和 `var`

`let` 用于不重新赋值的绑定，`var` 用于需要修改的绑定。

完整程序：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let unit_price: int32 = 12;
  var quantity: int32 = 2;
  quantity = quantity + 1;
  let total: int32 = unit_price * quantity;
  Console.Println("数量：{0}，总价：{1}", quantity, total);
  return 0;
}
```

结果是数量 3、总价 36。
`quantity = quantity + 1` 的意思是：先计算右边，再把新值存回左边。

初学时，“不修改就用 `let`”足够用了。
后面会看到，绑定能否重新赋值与它指向的数据是否共享，是两个不同问题。

## 3. 常见类型

- `int32`：一般整数，例如人数、次数。
- `int64`：需要更大范围的整数。
- `float64`：小数，例如 1.5。
- `bool`：只有 `true` 和 `false`，常用于判断。
- `string`：文字。
- `uint8`：一个无符号字节，范围是 0 到 255。

局部片段，放在 `main` 里面：

```nyra
let count = 3;
let enabled: bool = true;
let ratio: float64 = 1.5;
let marker: uint8 = 65u8;
Console.Println("数量：{0}，开启：{1}", count, enabled);
```

`let count = 3` 省略了类型，编译器会推断它。
教学例子经常写出类型，是为了让你看清数据是什么。

## 4. 算术和类型转换

局部片段：

```nyra
let quotient: int32 = 7 / 2;
let remainder: int32 = 7 % 2;
let decimal: float64 = (7 as float64) / 2.0;
Console.Println("整数商：{0}，余数：{1}", quotient, remainder);
```

整数商是 3，余数是 1。`decimal` 是 3.5。
`as float64` 表示按指定类型转换，不能把类型转换当成检查数值是否越界的工具。

整数有范围。大数计算要选择足够宽的类型，不要依靠溢出得到正确结果。

## 5. 常量和可修改的全局数据

下面的完整程序把声明放在 `main` 外面：

```nyra
import "stdlib:stdlib.ny";

constexpr kUnitPrice: int32 = 12;
readonly static kMaxQuantity: int32 = 100;
static order_count: int32 = 0;

func main() -> int32 {
  order_count = order_count + 1;
  Console.Println("单价：{0}，上限：{1}，订单：{2}",
    kUnitPrice, kMaxQuantity, order_count);
  return 0;
}
```

- `constexpr`：编译时确定的值，这种常量不需要一份可寻址的全局变量存储。
- `static`：程序运行时存在的全局数据，允许写入。
- `readonly static`：运行时的只读全局数据，禁止修改。

局部 `let` 不等于 `constexpr`。不要因为一个局部变量没有修改，就认为它一定在编译时求值。

## 常见错误

故意写错的局部片段：

```nyra
let age: int32 = 18;
age = 19;
```

需要修改时，用 `var age: int32 = 18;`。

## 补充：名字不是用来显示的文字

先认识一种进阶类型，暂时不需要用它重写前面的程序：

```nyra
let category: symbol = 'task;
if category == 'task {
  Console.Println("这是任务分类");
}
```

这是放在 `main` 里的局部片段。`'task` 是编译时就确定的符号，适合表达固定分类。
`"task"` 是字符串，适合保存、处理和显示文字。
不要把用户任意输入的文本当成可以随时动态注册的新符号。

## 练习与参考答案

三本书，每本 25 元，优惠 10 元。用变量算出实际付款金额。

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let unit_price: int32 = 25;
  let quantity: int32 = 3;
  let discount: int32 = 10;
  let payment: int32 = unit_price * quantity - discount;
  Console.Println("实际付款：{0} 元", payment);
  return 0;
}
```

预期输出 `实际付款：65 元`。
