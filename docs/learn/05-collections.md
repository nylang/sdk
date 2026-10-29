# 05 · 字符串、数组和字典

[English](en/05-collections.md)

[上一课](04-ownership.md) · [教程目录](README.md) · [下一课](06-errors.md)

这一课处理“一段文字”“一组数”和“按名字查询的数据”。

## 1. 字符串的长度是字节数

完整程序：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let text: string = "Nyra 中文";
  Console.Println("原文：{0}", text);
  Console.Println("字节数：{0}", text.length);
  Console.Println("Unicode 标量数：{0}", Text.Utf8Count(text));
  return 0;
}
```

预期字节数是 11，Unicode 标量数是 7。
中文在 UTF-8 中通常占多个字节，所以 `length` 不等于屏幕上看见的字数。
一个可见符号也可能由多个 Unicode 标量组成，例如组合重音或某些表情。

## 2. 查看一部分，还是复制一部分

局部片段，放进 `main`：

```nyra
let source: string = "  hello Nyra  ";
let trimmed: string = source.Trim();
let prefix: string = trimmed.View(0, 5);
let suffix: string = trimmed.Slice(6, 10);
let independent: string = trimmed.Substring(0, 5);
Console.Println("去空白：{0}", trimmed);
Console.Println("前段：{0}，后段：{1}", prefix, suffix);
```

- `Trim()`：去掉两端空白，返回视图，不复制整段文字。
- `View(起点, 长度)`：按字节选一段。
- `Slice(起点, 终点)`：起点包含，终点不包含。
- `Substring(起点, 长度)`：创建独立的字符串存储。

这些索引是字节偏移。处理中文时不要随便从某个字的中间切开；第 09 课会介绍 `Text`。
普通拥有字符串的视图会按其所有权规则保留底层存储；从裸指针或可变缓冲区得到的借用视图另有生命周期限制。
不要把指向临时缓冲区的视图保存到缓冲区失效之后。

## 3. 用 `Array<T>` 保存一组数据

完整程序：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var scores: Array<int32> = Array<int32>{};
  scores.Push(80);
  scores.Push(90);
  scores.Push(100);

  var total: int32 = 0;
  for index in 0..scores.Len() {
    total = total + scores.Get(index);
  }
  Console.Println("数量：{0}，合计：{1}", scores.Len(), total);
  return 0;
}
```

预期数量 3、合计 270。`Array<int32>` 的意思是“元素都是 `int32` 的可增长数组”。
第一个元素的下标是 0，最后一个是 `Len() - 1`。
`Get` 不替你检查下标是否有效，读取前必须保证范围正确。

也可以逐个取出元素：

```nyra
for score in scores {
  Console.Println("{0}", score);
}
```

遍历期间不要增删数组元素。需要修改结构时，先结束当前遍历。

## 4. 修改数组时选对入口

局部片段：

```nyra
var first: Array<int32> = Array<int32>{};
first.Push(10);
var second: Array<int32> = first;
second.Set(0, 99);
Console.Println("第一份：{0}，第二份：{1}", first.Get(0), second.Get(0));
```

`Array` 的壳可以共享底层存储。`Set` 和 `GetMut` 会先处理共享时的独立写入。
这里预期第一份仍是 10，第二份是 99。
初学时用 `Get` 读取、`Set` 修改，不要把直接下标写入和所有入口都视为相同的复制策略。

## 5. 用 `HashMap` 按名字查询

完整程序：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var stock: HashMap<string, int32> = HashMap<string, int32>.New();
  stock.Put("铅笔", 12);
  stock.Put("橡皮", 5);
  let found: int32? = stock.TryGet("铅笔");
  if found != nil {
    Console.Println("铅笔库存：{0}", found as int32);
  }
  Console.Println("是否有尺子：{0}", stock.Contains("尺子"));
  return 0;
}
```

`HashMap<string, int32>` 表示名字是字符串，关联值是整数。
`Put` 写入或更新，`TryGet` 查询一个可能不存在的值。
`int32?` 的问号将在下一课详细解释。

不要依赖哈希表遍历的顺序。需要稳定顺序时，另外记录顺序或排序。

## 6. 拼很多段文字，用缓冲区

局部片段：

```nyra
var buffer: StringBuffer = StringBuffer.NewWithCapacity(64);
buffer.Append("你好");
buffer.Append("，");
buffer.Append("Nyra");
let result: string = buffer.Take();
Console.Println(result);
```

`Take()` 把存储转成拥有的字符串，并清空缓冲区。
反复使用 `result = result.Concat(next)` 可能重复分配和复制越来越长的文字。
少量拼接没必要过度优化，多次累积时缓冲区更合适。

## 7. 进阶：`FastArray` 和 `FastString`

局部片段，使用支持这些接口的完整 SDK：

```nyra
var builder: FastString = FastString.FromString("Nyra");
builder.Append(" 教程");
let text: string = builder.ToString();

var numbers: FastArray<int32> = FastArray<int32>.New();
numbers.Push(10);
numbers.Push(20);
Console.Println("{0}：{1}", text, numbers.Get(0) + numbers.Get(1));
```

这两种容器强调一个明确的拥有者，不使用共享引用计数。
当前实现还没有小数据内联存储，不要因为名字里有 `Fast` 就假定它一定不分配。
需要独立容器时用 `Clone()`，需要转移时用 `move(...)`，不要复制裸拥有指针。
`FastString.ToString()` 生成普通字符串，不表示允许外部永久借用内部可变存储。
“Fast” 也不是任何程序都一定更快，先用清楚的类型表达需求。

## 练习与参考答案

保存三个商品价格，输出总价。把其中一个价格改掉，再计算一次。

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var prices: Array<int32> = Array<int32>{};
  prices.Push(12);
  prices.Push(8);
  prices.Push(5);
  prices.Set(1, 10);
  var total: int32 = 0;
  for index in 0..prices.Len() {
    total = total + prices.Get(index);
  }
  Console.Println("总价：{0}", total);
  return 0;
}
```

修改后的总价是 27。
