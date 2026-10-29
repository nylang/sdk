# 02 · 判断、循环和函数

[上一课](01-values.md) · [教程目录](README.md) · [下一课](03-structs.md)

这一课让程序根据条件选择动作，并把重复的步骤整理成函数。

## 1. 用 `if` 做选择

完整程序：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let score: int32 = 85;
  if score >= 90 {
    Console.Println("优秀");
  } else if score >= 60 {
    Console.Println("及格");
  } else {
    Console.Println("继续努力");
  }
  return 0;
}
```

结果是 `及格`。条件从上到下判断，进入第一个满足条件的分支，后面的分支就不执行。

`==` 比较是否相等，`!=` 比较是否不同，`=` 是赋值。
`&&` 表示两个条件都成立，`||` 表示至少一个成立，`!` 表示取反。

局部片段：

```nyra
let age: int32 = 18;
let has_ticket: bool = true;
if age >= 18 && has_ticket {
  Console.Println("可以入场");
}
```

## 2. 用 `while` 重复执行

完整程序：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var number: int32 = 1;
  var total: int32 = 0;
  while number <= 5 {
    total = total + number;
    number = number + 1;
  }
  Console.Println("1 到 5 的和：{0}", total);
  return 0;
}
```

预期结果是 15。每次执行完循环体，重新检查条件。
如果忘记增加 `number`，条件可能一直成立，程序就不会结束。

## 3. 知道次数时用 `for`

替换上面 `main` 里面的求和部分：

```nyra
var total: int32 = 0;
for number in 1..6 {
  total = total + number;
}
Console.Println("1 到 5 的和：{0}", total);
```

`1..6` 包含 1，不包含 6，也就是 1、2、3、4、5。
`break;` 提前结束循环，`continue;` 跳过本次剩余内容。

局部片段：

```nyra
for number in 0..10 {
  if number == 7 { break; }
  if number % 2 != 0 { continue; }
  Console.Println("{0}", number);
}
```

依次输出 0、2、4、6。

## 4. 把计算写成函数

完整程序：

```nyra
import "stdlib:stdlib.ny";

func discounted_total(price: int32, quantity: int32, discount: int32) -> int32 {
  return price * quantity - discount;
}

func main() -> int32 {
  let first: int32 = discounted_total(25, 3, 10);
  let second: int32 = discounted_total(12, 2, 0);
  Console.Println("第一单：{0}，第二单：{1}", first, second);
  return 0;
}
```

`price`、`quantity`、`discount` 是参数，调用时依次传入。
`return` 把结果交还给调用者，也结束当前函数。

这里的辅助函数只在本模块内用，所以用 `snake_case` 命名。
后面写跨模块的公开函数时，会用 `pub` 和 `UpperCamelCase`。
名字相同的普通函数不能靠参数不同任意重载；需要时给功能起不同的名字。

## 5. 可选的命名参数

函数定义放在 `main` 外面：

```nyra
func order_total(price: int32, quantity: int32, {discount: int32 = 0}) -> int32 {
  return price * quantity - discount;
}
```

调用片段放在 `main` 里面：

```nyra
let normal: int32 = order_total(25, 3);
let discounted: int32 = order_total(25, 3, discount: 10);
Console.Println("原价：{0}，优惠后：{1}", normal, discounted);
```

前两个参数按位置传入。`discount` 需要写名字，可以省略，省略时使用 0。
不要把它改写成位置参数的 `discount: int32 = 0`；默认值写在末尾的命名参数袋里。

## 练习与参考答案

写一个函数判断数字是否为偶数，输出 1 到 5 中的偶数。

```nyra
import "stdlib:stdlib.ny";

func is_even(value: int32) -> bool {
  return value % 2 == 0;
}

func main() -> int32 {
  for value in 1..6 {
    if is_even(value) {
      Console.Println("{0}", value);
    }
  }
  return 0;
}
```

预期分两行输出 2 和 4。
