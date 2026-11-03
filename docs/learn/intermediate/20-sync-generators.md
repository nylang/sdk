# 20 · sync*：用 yield 编写可迭代序列

[English](../en/intermediate/20-sync-generators.md) · [上一课](19-iterators.md) · [本阶段目录](README.md) · [下一课](21-async-await.md)

## 本课目标

上一课手写了游标。sync* 让编译器保存暂停位置和局部状态，生成同一类可迭代协议。先消费元素，再暂停／继续，最后用 yield* 转交子序列。

## 语法与合同

sync* 声明后的 -> int32 是每个元素类型，不是最终求和，也不是源码中写 Iterable<int32> 的位置。调用得到可迭代序列，Enum 后用 MoveNext/Current 拉取。yield 产生一项；yield* 接受元素类型匹配的 Iterable。同步生成器不用 Executor，也不能 await。

## 例 1：for 消费生成器

[源码](../examples/intermediate/sync-for/main.ny) · [package.yaml](../examples/intermediate/sync-for/package.yaml) · [expected.txt](../examples/intermediate/sync-for/expected.txt)

```nyra
import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  for value in count_to(3) {
    Console.Println("{0}", value);
  }

  return 0;
}
```

预期输出：

```text
1
2
3
```

每次继续迭代时从上次 yield 后接着执行。不是每次从函数首行重新开始。

## 例 2：零个元素仍然是有效序列

[源码](../examples/intermediate/sync-empty/main.ny) · [package.yaml](../examples/intermediate/sync-empty/package.yaml) · [expected.txt](../examples/intermediate/sync-empty/expected.txt)

```nyra
import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  var count: int32 = 0;
  for value in count_to(0) {
    count = count + 1;
  }

  Console.Println("count={0}", count);

  return 0;
}
```

预期输出：

```text
count=0
```

第一轮 MoveNext 就为 false，因此循环体不执行。不要为了空序列给 Current 编造一项。

## 协议补充：显式暂停与继续（SDK 限制）

**SDK 1.0.5 限制：** 下例是合法协议写法，但该版本在手动游标调用时可能报告缺少 ArrayCursor.MoveNext 实现，不能当成可直接运行的 1.0.5 示例。保留源码用于解释协议与修复验证；当前练习主线使用例 1 的 for。普通 Array 手动游标见第 19 课，它与该缺陷不是同一条路径。

[源码](../examples/intermediate/sync-resume/main.ny) · [package.yaml](../examples/intermediate/sync-resume/package.yaml) · [expected.txt](../examples/intermediate/sync-resume/expected.txt)

```nyra
import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  let sequence: Iterable<int32> = count_to(3);
  var cursor: Iterator<int32> = sequence.Enum();
  if !cursor.MoveNext() {
    return 1;
  }

  Console.Println("first={0}", cursor.Current());
  Console.Println("between");
  if !cursor.MoveNext() {
    return 2;
  }

  Console.Println("second={0}", cursor.Current());

  return 0;
}
```

预期输出：

```text
first=1
between
second=2
```

调用者可以在两次拉取之间做别的同步工作。本例没有线程或异步等待。不要依赖未消费元素的副作用一定已经发生。

## 例 3：yield 一个值与转发多个值

[源码](../examples/intermediate/sync-forward/main.ny) · [package.yaml](../examples/intermediate/sync-forward/package.yaml) · [expected.txt](../examples/intermediate/sync-forward/expected.txt)

```nyra
import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

sync* func with_tail(limit: int32) -> int32 {
  yield* count_to(limit);
  yield 42;
}

func main() -> int32 {
  for value in with_tail(2) {
    Console.Println("{0}", value);
  }

  return 0;
}
```

预期输出：

```text
1
2
42
```

yield* 遍历子序列，按原序产生它的元素；不是 yield 一个 Iterable 对象。空子序列不产生元素，仍继续执行后面的 yield。

## 常见错误与边界

不能在普通 func 中用 yield；不能在 sync* 中 await；不能把生成器源码返回类型写成 Array 以为会自动收集。退出消费者不意味着剩余元素必须继续产生。

## 练习

把 count_to(0) 和 count_to(3) 都累加并输出，观察空序列。

<details>
<summary>完整参考答案</summary>

[源码](../examples/intermediate/sync-answer/main.ny) · [package.yaml](../examples/intermediate/sync-answer/package.yaml) · [expected.txt](../examples/intermediate/sync-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  var total: int32 = 0;
  for value in count_to(0) {
    total = total + value;
  }

  Console.Println("empty={0}", total);
  for value in count_to(3) {
    total = total + value;
  }

  Console.Println("total={0}", total);

  return 0;
}
```

预期输出：

```text
empty=0
total=6
```

零元素也满足 Iterable 协议，不需要给 Current 编造默认值。

</details>

[上一课](19-iterators.md) · [本阶段目录](README.md) · [下一课](21-async-await.md)
