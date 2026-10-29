# 04 · 借用、复制和移动

[上一课](03-structs.md) · [教程目录](README.md) · [下一课](05-collections.md)

这一课不急着讲内存布局。先回答一个实际问题：把数据交给函数后，原来的变量还能不能用？

## 1. 先认识“谁负责收拾”

整数通常直接存一个数字。字符串、动态数组等数据，可能另外占用一块内存。
程序必须知道什么时候不再需要那块内存。

Nyra 通过值的所有权和作用域来安排清理。多数日常代码不需要自己调用释放函数。
“拥有数据”的变量负责保留资源，“借用数据”的参数只是在一段时间里使用它。

先记住三个意图：

- 只看一下：借用。
- 需要独立的一份：显式复制。
- 把自己的那份交出去：移动。

## 2. 只读参数用 `ref`

完整程序：

```nyra
import "stdlib:stdlib.ny";

func show_title(title: ref string) -> void {
  Console.Println("书名：{0}", title);
}

func main() -> int32 {
  let title: string = "Nyra".Concat(" 入门");
  show_title(title);
  Console.Println("原变量还可以用：{0}", title);
  return 0;
}
```

`title: ref string` 表示借用调用者的字符串来读。
调用时直接写 `show_title(title)`，不用额外加 `&`。
函数不能把这次借用当成自己的长期资源；如果要长期保存，需要取得合适的拥有值。

## 3. 修改调用者的数据用 `ref mut`

完整程序：

```nyra
import "stdlib:stdlib.ny";

struct Counter {
  value: int32;
}

func add_one(counter: ref mut Counter) -> void {
  counter.value = counter.value + 1;
}

func main() -> int32 {
  var counter: Counter = Counter { value: 41 };
  add_one(counter);
  Console.Println("{0}", counter.value);
  return 0;
}
```

预期输出 42。`ref mut` 表达的是修改原数据的借用，调用者仍然负责它的生命周期。
不要在可修改借用存续期间，再通过另一个入口同时修改同一份数据。

## 4. 普通参数不是自动深复制

```nyra
func title_length(title: string) -> int32 {
  return title.length;
}
```

这里是普通值参数，不是 `ref string`。但这也不意味着每次调用都复制整段文字。
字符串和共享句柄通常保留共享存储；整数复制数字；只能移动的类型遵守自己的移动规则。

因此，不要把“机器上可能传了一个指针”理解成语言中的借用。
接口设计时，想表达只读借用就明确写 `ref`。

## 5. `copy` 和 `move`

完整程序：

```nyra
import "stdlib:stdlib.ny";

func take_title(title: ref^ string) -> int32 {
  Console.Println("收到：{0}", title);
  return title.length;
}

func main() -> int32 {
  let original: string = "Nyra".Concat(" 入门");
  let independent: string = copy(original);
  let length: int32 = take_title(move(independent));
  Console.Println("原文：{0}，收到的字节数：{1}", original, length);
  return 0;
}
```

逐步看：

1. `original` 拥有一个字符串值。
2. `copy(original)` 调用字符串的显式复制操作，得到独立的字符存储。
3. `ref^ string` 表示参数接收所有权。
4. `move(independent)` 交出这个变量拥有的那一份。
5. 交出后不要再读取 `independent`。`original` 没有交出，仍然可以用。

`ref^` 虽然名字里有 `ref`，但它表达的是消耗参数，不是临时借用。
当前先在普通同步函数的必选位置参数上使用它，不要套进异步参数或字段类型。

对于共享数据，移动的是当前持有者的那份所有权；它不会自动保证“其他人都不再共享”。
对于自定义类型，`copy` 是否深复制由该类型的复制操作决定，不是所有类型统一按字节递归复制。

## 6. 独占和共享对象

完整程序：

```nyra
import "stdlib:stdlib.ny";

struct Settings {
  port: int32;
}

func read_settings(settings: unique<Settings>) -> int32 {
  return settings.port;
}

func main() -> int32 {
  let exclusive: unique<Settings> = new unique<Settings> { port: 8080 };
  let port: int32 = read_settings(move(exclusive));

  let shared: rc<Settings> = new rc<Settings> { port: 9000 };
  let another: rc<Settings> = shared;
  Console.Println("独占端口：{0}，共享端口：{1}", port, another.port);
  return 0;
}
```

- `unique<T>`：独占资源，不能随意再生成一个同样的拥有者。
- `rc<T>`：非原子引用计数，适合不跨线程共享的场景。
- `arc<T>`：原子引用计数，适用于需要跨线程维护引用计数的场景。
- `weak<...>`：不让对象因为自己而一直存活的弱引用，使用前需要尝试升级。

`arc` 只解决引用计数操作的并发问题。多个线程同时修改对象字段，仍然需要同步。
共享引用之间如果形成环，单靠强引用计数不能自动打破这个环；这时要重新组织所有权或使用弱引用。

## 7. 不是每种类型都允许复制

进阶声明片段，写在结构体外：

```nyra
method(MyResource) operator copy() -> MyResource = delete;
```

这表示该类型禁止复制。这里的 `MyResource` 是说明用的类型名，必须先有对应定义。
标准库的 `FastArray`、`FastString` 就强调显式转移和克隆，不允许普通浅复制拥有者。

## 常见错误

- 用 `ref` 接收参数，却试图把它当拥有值永久保存。
- `move(value)` 后继续读 `value`。
- 认为 `copy`、普通赋值和只读借用完全一样。
- 以为用了 `arc`，对象内部所有读写就都线程安全。

## 练习

把第 5 节的 `take_title(move(independent))` 改成 `take_title(copy(original))`。
参考理解：这次把一份新复制的临时值直接交给函数，`original` 仍然可以读取。

再把参数改成 `ref string`，并直接传入 `original`。
参考理解：函数现在只借用，不再接收所有权，也不需要为调用单独复制整段文字。
