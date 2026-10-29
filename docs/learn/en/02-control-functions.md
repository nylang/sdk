# 02: Conditions, loops and functions

[中文](../02-control-functions.md) · [Course index](README.md) · [Previous](01-values.md) · [Next](03-structs.md)

Choose actions based on conditions and put repeated calculations into functions.

## 1. Choose with if

Complete program:

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

A score of 85 takes the passing branch. Conditions are checked from the top;
only the first satisfied branch runs. `==` compares, `!=` tests inequality and
`=` assigns. `&&`, `||` and `!` mean and, or and not. Fragment:

```nyra
let age: int32 = 18;
let has_ticket: bool = true;
if age >= 18 && has_ticket {
  Console.Println("可以入场");
}
```

## 2. Repeat with while

Complete program:

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

The sum is 15. The condition is checked after each iteration before another
begins. Forgetting to advance number can leave the loop running indefinitely.

## 3. Iterate a range

Replace the summation fragment in main:

```nyra
var total: int32 = 0;
for number in 1..6 {
  total = total + number;
}
Console.Println("1 到 5 的和：{0}", total);
```

`1..6` includes 1 and excludes 6. `break` exits the loop; `continue` skips the
remaining work in that iteration:

```nyra
for number in 0..10 {
  if number == 7 { break; }
  if number % 2 != 0 { continue; }
  Console.Println("{0}", number);
}
```

This prints 0, 2, 4 and 6.

## 4. Extract a function

Complete program:

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

The parameters receive arguments in order. `return` ends the function and
hands a result to its caller. A module-local helper uses snake_case; public
cross-module functions use pub and UpperCamelCase. Do not assume arbitrary
ordinary-function overloads based only on parameter types.

## 5. Named optional parameters

Place this definition outside main:

```nyra
func order_total(price: int32, quantity: int32, {discount: int32 = 0}) -> int32 {
  return price * quantity - discount;
}
```

Call it inside main:

```nyra
let normal: int32 = order_total(25, 3);
let discounted: int32 = order_total(25, 3, discount: 10);
Console.Println("原价：{0}，优惠后：{1}", normal, discounted);
```

The first two parameters are positional. The optional discount uses a named
argument and defaults to zero. Its default belongs in the final named bag,
not a newly invented defaulted positional parameter.

## Exercise

Write a function identifying even numbers, and print those in 1 through 5.

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

Expected output: 2 and 4 on separate lines.
