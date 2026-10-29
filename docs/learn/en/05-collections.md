# 05: Strings, arrays and maps

[中文](../05-collections.md) · [Course index](README.md) · [Previous](04-ownership.md) · [Next](06-errors.md)

Work with text, lists of values and data looked up by name.

## 1. String length counts bytes

Complete program:

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

Expect 11 UTF-8 bytes and 7 Unicode scalars. A Chinese character commonly uses
multiple bytes; a visible grapheme can also contain several scalars. Byte length,
scalar count and displayed character count are different measurements.

## 2. Views and independent substrings

Fragment in main:

```nyra
let source: string = "  hello Nyra  ";
let trimmed: string = source.Trim();
let prefix: string = trimmed.View(0, 5);
let suffix: string = trimmed.Slice(6, 10);
let independent: string = trimmed.Substring(0, 5);
Console.Println("去空白：{0}", trimmed);
Console.Println("前段：{0}，后段：{1}", prefix, suffix);
```

Trim returns a view without copying the whole text. View takes byte start and
length; Slice takes start and exclusive end. Substring creates independent
storage. Do not cut through the middle of a UTF-8 scalar. Owning string windows
retain storage according to their ownership contract; borrowed raw-buffer views
have a separate validity period and must not outlive that buffer.

## 3. Store values in Array

Complete program:

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

Expect 3 values totaling 270. Array<int32> is a growable array of integers.
Indices run from zero to Len()-1; validate bounds before using Get.

```nyra
for score in scores {
  Console.Println("{0}", score);
}
```

Do not add/remove array elements during an active traversal.

## 4. Choose the correct mutation operation

Fragment:

```nyra
var first: Array<int32> = Array<int32>{};
first.Push(10);
var second: Array<int32> = first;
second.Set(0, 99);
Console.Println("第一份：{0}，第二份：{1}", first.Get(0), second.Get(0));
```

Array shells may share storage. Set/GetMut arrange independent writes when
needed. The first copy should still contain 10 and the second 99. Do not assume
every indexing and mutation entry point has an identical copy policy.

## 5. Look up data in a HashMap

Complete program:

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

Put inserts or updates; TryGet can return no value. The optional int32 type is
covered in lesson 06. Hash iteration order is not a stable output ordering;
record or sort an order when required.

## 6. Build text with a buffer

Fragment:

```nyra
var buffer: StringBuffer = StringBuffer.NewWithCapacity(64);
buffer.Append("你好");
buffer.Append("，");
buffer.Append("Nyra");
let result: string = buffer.Take();
Console.Println(result);
```

Take transfers the buffer storage to an owned string and empties the buffer.
Repeated Concat can reallocate and copy growing prefixes. A buffer is useful for
accumulation, without requiring premature optimization of every short join.

## 7. FastArray and FastString

Advanced fragment requiring a matching SDK:

```nyra
var builder: FastString = FastString.FromString("Nyra");
builder.Append(" 教程");
let text: string = builder.ToString();

var numbers: FastArray<int32> = FastArray<int32>.New();
numbers.Push(10);
numbers.Push(20);
Console.Println("{0}：{1}", text, numbers.Get(0) + numbers.Get(1));
```

These use explicit ownership rather than shared reference counting. Do not
infer allocation-free behavior from the word Fast: the current implementation
has no small-data inline storage. Clone creates an independent container; move
transfers ownership. ToString creates a normal string, not permission to retain
a borrowed pointer into mutable storage indefinitely.

## Exercise

Store three prices, change one, then recompute their total.

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

Expected updated total: 27.
