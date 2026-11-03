# 19 · Iterable 与 Iterator：游标状态协议

[English](../en/intermediate/19-iterators.md) · [上一课](18-variadics.md) · [本阶段目录](README.md) · [下一课](20-sync-generators.md)

## 本课目标

先展开 for 背后的三项操作，再验证两个游标各自前进，最后自己实现一个倒数游标。可迭代对象与迭代器不是同一个角色。

## 语法与合同

Iterable<T>.Enum() 返回一个位于首元素之前的新 Iterator<T>。每次 MoveNext() 返回 true 后才能读 Current()。MoveNext 返回 false 表示结束；Current 不是可空的“取下一个”。数据源必须在游标使用期间保持有效，不在遍历时任意使其存储失效。

## 例 1：手动展开遍历

[源码](../examples/intermediate/iterator-manual/main.ny) · [package.yaml](../examples/intermediate/iterator-manual/package.yaml) · [expected.txt](../examples/intermediate/iterator-manual/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func numbers() -> Array<int32> {
  var items: Array<int32> = Array<int32>{};
  items.Push(10);
  items.Push(20);
  items.Push(12);

  return items;
}

func main() -> int32 {
  let items: Array<int32> = numbers();
  var cursor: Iterator<int32> = items.Enum();
  var total: int32 = 0;
  while cursor.MoveNext() {
    total = total + cursor.Current();
  }

  Console.Println("total={0}", total);

  return 0;
}
```

预期输出：

```text
total=42
```

Enum 不先消耗一项；第一次 MoveNext 后才读 10。for value in items 使用同样协议，不要求数组下标。

## 例 2：两个游标不是共享位置

[源码](../examples/intermediate/iterator-independent/main.ny) · [package.yaml](../examples/intermediate/iterator-independent/package.yaml) · [expected.txt](../examples/intermediate/iterator-independent/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func numbers() -> Array<int32> {
  var items: Array<int32> = Array<int32>{};
  items.Push(10);
  items.Push(20);
  items.Push(12);

  return items;
}

func main() -> int32 {
  let items: Array<int32> = numbers();
  var first: Iterator<int32> = items.Enum();
  var second: Iterator<int32> = items.Enum();
  if !first.MoveNext() || !second.MoveNext() {
    return 1;
  }

  Console.Println("first={0}, second={1}", first.Current(), second.Current());
  if !first.MoveNext() {
    return 2;
  }

  Console.Println("next={0}, other={1}", first.Current(), second.Current());

  return 0;
}
```

预期输出：

```text
first=10, second=10
next=20, other=10
```

每次 Enum 创建独立位置；推进 first 不推进 second。这不是允许游标跨线程无同步共享的承诺。

## 例 3：自己实现状态与有效性

[源码](../examples/intermediate/iterator-custom/main.ny) · [package.yaml](../examples/intermediate/iterator-custom/package.yaml) · [expected.txt](../examples/intermediate/iterator-custom/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Countdown implements Iterator<int32> {
  next: int32;
  current: int32;
  valid: bool;
}

method(Countdown) MoveNext() -> bool {
  if self.next <= 0 {
    self.valid = false;
    return false;
  }

  self.current = self.next;
  self.next = self.next - 1;
  self.valid = true;

  return true;
}

method(Countdown) Current() -> int32 {
  assert(self.valid);

  return self.current;
}

func main() -> int32 {
  var cursor: Countdown = Countdown{ next: 3, current: 0, valid: false };
  while cursor.MoveNext() {
    Console.Println("{0}", cursor.Current());
  }

  return 0;
}
```

预期输出：

```text
3
2
1
```

valid 记录 Current 的前置条件；耗尽后重新置 false。类型显式 implements Iterator<int32>。这里实现的是单个游标，不冒充能创建新游标的 Iterable。

## 常见错误与边界

不能在第一次 MoveNext 前或耗尽后调用 Current，也不能把返回值名改为 next() 然后假定 for 会识别。创建新游标的 Enum 与推进已有游标是两步。

## 练习

把 Countdown 从 5 开始，不逐项打印，而是累加。

<details>
<summary>完整参考答案</summary>

[源码](../examples/intermediate/iterator-answer/main.ny) · [package.yaml](../examples/intermediate/iterator-answer/package.yaml) · [expected.txt](../examples/intermediate/iterator-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Countdown implements Iterator<int32> {
  next: int32;
  current: int32;
  valid: bool;
}

method(Countdown) MoveNext() -> bool {
  if self.next <= 0 {
    self.valid = false;
    return false;
  }

  self.current = self.next;
  self.next = self.next - 1;
  self.valid = true;

  return true;
}

method(Countdown) Current() -> int32 {
  assert(self.valid);

  return self.current;
}

func main() -> int32 {
  var cursor: Countdown = Countdown{ next: 5, current: 0, valid: false };
  var total: int32 = 0;
  while cursor.MoveNext() {
    total = total + cursor.Current();
  }

  Console.Println("total={0}", total);

  return 0;
}
```

预期输出：

```text
total=15
```

累计器与游标位置分别由自己的状态保存。

</details>

[上一课](18-variadics.md) · [本阶段目录](README.md) · [下一课](20-sync-generators.md)
