# 06: Optional values and errors

[中文](../06-errors.md) · [Course index](README.md) · [Previous](05-collections.md) · [Next](07-packages.md)

Missing data and failed operations need deliberate handling, not just a happy path.

## 1. A value may be absent

Complete program:

```nyra
import "stdlib:stdlib.ny";

func find_price(name: ref string) -> int32? {
  if name == "铅笔" { return 2; }
  if name == "橡皮" { return 1; }
  return nil;
}

func main() -> int32 {
  let price: int32? = find_price("尺子");
  if price == nil {
    Console.Println("没有找到这个商品");
  } else {
    Console.Println("价格：{0}", price as int32);
  }
  return 0;
}
```

int32? contains an integer or nil. Zero is a real value, for example a free item;
it must not ambiguously mean that the item does not exist.

## 2. Check before extracting

Fragment:

```nyra
let price: int32? = find_price("铅笔");
if price != nil {
  let value: int32 = price as int32;
  Console.Println("价格：{0}", value);
}
```

After checking nil, `as int32` extracts the value. The cast does not replace the
presence check or manufacture an integer from absence.

## 3. Return a failure reason

Complete program:

```nyra
import "stdlib:stdlib.ny";

enum OrderError {
  InvalidQuantity,
  InsufficientStock,
}

func order_total(quantity: int32) -> Result<int32, OrderError> {
  if quantity <= 0 {
    return Err<int32, OrderError>(OrderError.InvalidQuantity);
  }
  if quantity > 10 {
    return Err<int32, OrderError>(OrderError.InsufficientStock);
  }
  return Ok<int32, OrderError>(quantity * 12);
}

func main() -> int32 {
  let result: Result<int32, OrderError> = order_total(3);
  if result.IsErr() {
    Console.Eprintln("下单失败");
    return 1;
  }
  let total: int32? = result.get_if<int32>();
  if total == nil {
    Console.Eprintln("没有取得总价");
    return 2;
  }
  Console.Println("总价：{0}", total as int32);
  return 0;
}
```

Expected total: 36. In Result<T,E>, T is success data and E the error type.
Ok/Err construct the alternatives; IsOk/IsErr test them; get_if<T>() still
requires checking its optional result. This introductory example uses distinct
success/error types. Do not guess a same-type alternative from a type name or
assume another language's automatic question-mark error propagation.

## 4. Turn errors into readable messages

Replace the failure branch in main:

```nyra
if result.IsErr() {
  let error: OrderError? = result.get_if<OrderError>();
  if error != nil {
    switch (error as OrderError) {
      case OrderError.InvalidQuantity { Console.Eprintln("数量必须大于零"); }
      case OrderError.InsufficientStock { Console.Eprintln("库存不足"); }
      default { Console.Eprintln("未知下单错误"); }
    }
  }
  return 1;
}
```

Try arguments 0 and 11 to exercise different failures. A nonzero exit status
on these paths is expected behavior, not a compiler hang.

## 5. Assert internal assumptions

Fragment:

```nyra
let total: int32 = 12 * 3;
assert(total == 36);
```

A failed assertion aborts; it is not a normal error return. Expected user/input
conditions should use a branch, optional result or Result.

## Exercises

Add an item with price 3 to find_price and query it. Change order_total(3) to
order_total(11). Expect the new item price on the first exercise and an
insufficient-stock message with exit status 1 on the second.
