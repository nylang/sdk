# 01: Values, types and output

[中文](../01-values.md) · [Course index](README.md) · [Previous](00-start.md) · [Next](02-control-functions.md)

Use the `playground/main.ny` from lesson 00. Each complete program below replaces
the previous one; do not paste multiple entry points into one file.

## 1. Name your data

Complete program:

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let name: string = "小明";
  let age: int32 = 18;
  Console.Println("你好，{0}，你今年 {1} 岁", name, age);
  return 0;
}
```

Run it:

```sh
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/lesson01"
```

Expected output:

```text
你好，小明，你今年 18 岁
```

`name` and `age` are bindings. A type follows the colon; the initializer follows
`=`. `string` stores text and `int32` stores an integer. `{0}` and `{1}` select
additional output arguments starting at zero. These are formatting placeholders,
not `%s` or embedded source expressions.

## 2. Choose let or var

Use `let` when the binding is not reassigned, and `var` when it changes.

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

The final quantity is 3 and total is 36. Evaluate the assignment's right side
before storing it on the left. Binding reassignment and shared data mutation
are different questions; ownership comes later.

## 3. Common types

Use `int32`/`int64` for integers, `float64` for fractional values, `bool` for
true/false, `string` for text and `uint8` for a byte in 0..255. Fragment in main:

```nyra
let count = 3;
let enabled: bool = true;
let ratio: float64 = 1.5;
let marker: uint8 = 65u8;
Console.Println("数量：{0}，开启：{1}", count, enabled);
```

The compiler infers the type in `let count = 3`. Explicit types in lessons help
show the intended representation.

## 4. Arithmetic and conversion

Fragment:

```nyra
let quotient: int32 = 7 / 2;
let remainder: int32 = 7 % 2;
let decimal: float64 = (7 as float64) / 2.0;
Console.Println("整数商：{0}，余数：{1}", quotient, remainder);
```

Integer division gives 3 and the remainder is 1; floating division gives 3.5.
`as` performs a conversion, not a range-validation check. Choose adequate integer
width rather than relying on overflow.

## 5. Constants and global data

Complete program:

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

`constexpr` is a compile-time value. `static` is runtime global storage;
`readonly static` makes that runtime value readonly. A local `let` does not
by itself imply compile-time evaluation.

## Common mistake

Intentionally invalid fragment:

```nyra
let age: int32 = 18;
age = 19;
```

Use `var` if age needs reassignment.

## Fixed names and displayed text

Advanced fragment in main:

```nyra
let category: symbol = 'task;
if category == 'task {
  Console.Println("这是任务分类");
}
```

The symbol identifies a fixed category; the string stores text. Arbitrary user
input does not become a newly registered runtime symbol.

## Exercise

Calculate payment for three books costing 25 each, with a discount of 10.

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

Expected payment: 65. The sample keeps its Chinese display text intentionally.
