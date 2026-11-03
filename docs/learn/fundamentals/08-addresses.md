# 08 · 借用、地址与 unsafe 的边界

[English](../en/fundamentals/08-addresses.md) · [上一课](07-arrays.md) · [基础目录](README.md) · [下一课](09-struct-data.md)

## 本课目标

这一课解释 C 背景读者关心的地址，但不把原始指针作为普通应用的默认接口。先比较值与借用，再展示一次可控的原始指针读写。暂时不做手动分配、释放或指针运算。

## 先读语法，再看程序

`ref T`、`ref mut T` 是借用参数合同；`*mut T` 是原始可写指针类型，`&mut value` 取得地址，`*address` 解引用。同一个 * 在乘法和指针位置含义不同；语法位置决定用途。

## 例 1：借用只读数据

[下载源码](../examples/fundamentals/read-borrow/main.ny) · [package.yaml](../examples/fundamentals/read-borrow/package.yaml) · [expected.txt](../examples/fundamentals/read-borrow/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func print_title(title: ref string) -> void {
  Console.Print("borrowed=");
  Console.Println(title);
}

func main() -> int32 {
  let title: string = "Nyra";
  print_title(title);
  Console.Println("still={0}", title);

  return 0;
}
```

预期输出：

```text
borrowed=Nyra
still=Nyra
```

只读借用不把调用者的拥有值交走，调用结束后 title 仍可使用。借用并不意味每次复制整段字节。

## 例 2：读取并修改仍存活的局部变量

[下载源码](../examples/fundamentals/raw-address/main.ny) · [package.yaml](../examples/fundamentals/raw-address/package.yaml) · [expected.txt](../examples/fundamentals/raw-address/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var value: int32 = 40;
  let address: *mut int32 = &mut value;
  unsafe {
    *address = *address + 2;
  }

  Console.Println("value={0}", value);

  return 0;
}
```

预期输出：

```text
value=42
```

地址指向仍存活、对齐的 value，解引用只发生在 unsafe 块中。unsafe 不替你检查有效性；本例也没有把局部地址返回给外部。

## 例 3：显式复制与普通读取

[下载源码](../examples/fundamentals/explicit-copy/main.ny) · [package.yaml](../examples/fundamentals/explicit-copy/package.yaml) · [expected.txt](../examples/fundamentals/explicit-copy/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let original: string = "Nyra".Concat(" language");
  let saved: string = copy(original);

  Console.Println("original={0}", original);
  Console.Println("saved={0}", saved);

  return 0;
}
```

预期输出：

```text
original=Nyra language
saved=Nyra language
```

copy 请求类型的复制操作；不要把它解释为任意对象都得到深度独立的图。move 则转移拥有权，后面所有权课再展开；普通字符串由语言安排清理，不额外手动 Free。

## 常见错误与边界

不能返回指向已经离开作用域的局部变量的地址。不能把 &、ref、* 当成同一个东西。不要通过多个入口并发修改同一份借用数据；unsafe 也不会消除这个义务。

## 练习：先自己写，再看答案

把 raw-address 的初始值换成 10，并连续加 2 两次。再用可变借用函数表达同一计算，解释哪一种接口更容易说明调用者义务。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/08-addresses-answer/main.ny) · [package.yaml](../examples/fundamentals/08-addresses-answer/package.yaml) · [expected.txt](../examples/fundamentals/08-addresses-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func add_two(value: ref mut int32) -> void {
  value = value + 2;
}

func main() -> int32 {
  var value: int32 = 10;
  add_two(value);
  add_two(value);

  Console.Println("value={0}", value);

  return 0;
}
```

预期输出：

```text
value=14
```

两种写法结果都是 14；借用函数可沿用第 06 课 add_two，调用两次，不需要在调用者显式解引用。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](07-arrays.md) · [基础目录](README.md) · [下一课](09-struct-data.md)
