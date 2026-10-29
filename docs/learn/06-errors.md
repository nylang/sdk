# 06 · 空值、结果和错误处理

[English](en/06-errors.md)

[上一课](05-collections.md) · [教程目录](README.md) · [下一课](07-packages.md)

“没找到”和“运行失败”都是正常程序会遇到的情况，不能只考虑成功路径。

## 1. 可能没有值：`T?`

完整程序：

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

`int32?` 可以保存整数，也可以保存 `nil`，表示“没有”。
0 是一个真实整数，和 `nil` 不一样。价格是 0 可以表示免费，不能再用它混着表示商品不存在。

## 2. 先检查，再取出

局部片段：

```nyra
let price: int32? = find_price("铅笔");
if price != nil {
  let value: int32 = price as int32;
  Console.Println("价格：{0}", value);
}
```

`as int32` 在这里取出已经确认存在的值。
它不是“无论有没有都给我一个整数”，不能替代 `nil` 检查。

## 3. 失败时还需要原因：`Result<T, E>`

完整程序：

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

预期总价 36。

- `T` 是成功时的值，本例是总价。
- `E` 是失败原因，本例是 `OrderError`。
- `Ok(...)` 构造成功结果，`Err(...)` 构造失败结果。
- `IsOk()`、`IsErr()` 判断是哪一种结果。
- `get_if<T>()` 尝试取出指定类型，仍然要检查是否为空。

示例故意让成功值和错误值使用不同类型，方便理解。进阶的同类型分支不要靠类型名猜分支。
不要假设存在其他语言里的 `?` 自动向上传播错误语法。

## 4. 把失败原因翻译成人能读懂的文字

替换上面 `main` 里面的失败分支：

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

把调用参数改成 0 或 11，分别观察两条失败路径。
命令返回非零状态码是这个错误例子的预期行为，不等于编译器卡住。

## 5. 断言适合检查程序内部假设

局部片段：

```nyra
let total: int32 = 12 * 3;
assert(total == 36);
```

断言不成立会硬失败，不是普通错误返回。
“用户没输入文件”“商品不存在”等预期情况用分支或 `Result` 处理，不要全部交给断言。

## 练习

给 `find_price` 增加 `"尺子" -> 3`，查询它并输出价格。
再把 `order_total(3)` 改成 `order_total(11)`。

参考结果：第一次查询得到价格 3；第二个程序显示“库存不足”，并返回状态码 1。
