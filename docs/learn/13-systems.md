# 13 · 指针、分配器和内核代码

[上一课](12-concurrency.md) · [教程目录](README.md) · [下一课](14-compiler-tools.md)

这一课面向需要底层控制的读者。普通应用仍然可以继续使用标准库和自动清理的拥有类型。

## 1. 指针记录一个地址

完整的用户态程序：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var value: int32 = 40;
  let address: *mut int32 = &mut value;
  unsafe {
    *address = *address + 2;
  }
  Console.Println("结果：{0}", value);
  return 0;
}
```

`&mut value` 获取可写地址，`*mut int32` 表示指向整数的可写指针。
`*address` 访问这个地址里的值，这一步叫解引用，需要放在 `unsafe` 块里。

`unsafe` 不会检查地址是否有效，也不会让错误的指针变安全。
程序员必须保证地址仍存活、对齐正确、访问范围有效，而且没有冲突的访问。

## 2. 调用一个简单 C 函数

macOS 完整程序：

```nyra
import "stdlib:stdlib.ny";

@extern("C") func abs(value: int32) -> int32;

func main() -> int32 {
  Console.Println("绝对值：{0}", abs(-42));
  return 0;
}
```

预期结果 42。声明说明名称和参数按 C ABI 与外部实现连接。
这里只演示普通范围的整数，不用最小负整数来演示 `abs`。

`string` 不能直接当成 C 的 `char*`；一段字符串视图也不保证以零字节结尾。
与 C 交换文字时，要明确编码、长度、结尾、所有权和释放方式。

## 3. 分配器是“从哪里拿内存”的接口

前面的 `CreateAllocator` 使用普通进程堆。
对于很多短命临时数据，可以用 `MemStack`；同一生命周期的大组数据，可以考虑 `MemArena`。

下面的完整用户态程序先用一段本地缓冲区演示 `MemStack`：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var storage: <uint8>[] = <uint8>[256]{0u8};
  var stack: MemStack = MemStack{};
  stack.Init((&mut storage[0]) as *mut uint8, 256up);

  let mark: uintptr = stack.Mark();
  let memory: *mut uint8 = stack.Alloc(16up, align: 8up);
  if memory == (0 as *mut uint8) {
    Console.Eprintln("临时缓冲区容量不够");
    return 1;
  }
  unsafe {
    *memory = 42u8;
    Console.Println("临时数据：{0}", *memory);
  }
  stack.Reset(mark);
  return 0;
}
```

`Mark()` 记住位置，`Alloc()` 向前取一段，`Reset(mark)` 回到之前的位置。
重置后，刚才的 `memory` 不能再使用。原始缓冲区 `storage` 也必须比分配器及其分配结果活得久。

`<uint8>[256]{0u8}` 是创建本地数组的表达式。
这里的变量类型写 `<uint8>[]`，不是把长度放进类型里。

## 4. 用 `scope` 自动回到标记

在上例 `stack.Init(...)` 后，可以用下面的局部片段替换手写 `Mark` 到 `Reset` 的部分：

```nyra
scope (stack) {
  let memory: *mut uint8 = stack.Alloc(16up, align: 8up);
  if memory == (0 as *mut uint8) { return 1; }
  unsafe { *memory = 42u8; }
}
```

对支持标记协议的对象，`scope` 在进入时记录标记，离开时重置。
临时分配不能逃出这个作用域；从里面返回一段指向这块临时存储的视图仍然会出错。
如果里面创建了有析构动作的对象，还要确保对象清理先于存储重置，不要把“归还字节”当作执行所有析构。

## 5. 可以增长的 arena

先学习生命周期顺序，再看局部片段：

```nyra
var backing: Allocator = CreateAllocator(0i64, 8i64);
var provider: MemoryChunkProvider = MemoryChunkProviderFromAllocator(&mut backing);
var arena: MemArena = MemArena{};
if !arena.InitGrowable(&mut provider, 65536up) { return 1; }

let memory: *mut uint8 = arena.Alloc(128up, align: 8up);
if memory == (0 as *mut uint8) {
  arena.Release();
  return 2;
}
unsafe { *memory = 7u8; }

arena.Release();
```

先初始化后端分配器，再初始化 provider，最后初始化 arena。
它们使用期间不能移动地址或提前销毁；arena 通过 provider 逐块申请内存，不移动旧块。
`InitGrowable` 成功表示配置好，不表示已经拿到了所有未来需要的内存。
申请仍可能失败。`Release()` 是显式操作，会归还 provider 分配的块。

不要让 provider 反过来从这个 arena 自己申请块，否则会递归调用自己。
不要在 `Release()` 或 `ResetAll()` 后继续读取先前的指针、切片或视图。

## 6. `.nk` 和普通程序有什么不同

`.ny` 可以使用用户态标准库，`.nk` 面向内核和驱动的受限环境。
`.nk` 不导入 `stdlib`，不假设存在终端、文件系统或默认进程堆。

独立的 `.nk` 声明片段：

```nyra
import "kernel:kernel.ny";

struct Node {
  value: int32;
}

func create_node(allocator: Allocator) -> unique<Node> {
  return new(allocator) unique<Node> { value: 42 };
}
```

在允许的拥有对象形式中，必须显式提供 `new(allocator)` 的分配器。
不能直接把用户态程序的 `new unique<Node>` 照搬进来。
上面是供内核工程集成的函数，不是一个可以直接 `run` 启动的操作系统。

真正运行内核还需要启动代码、链接脚本、内存映射、板级支持和对应的目标运行库。
仅仅修改文件后缀或生成一份 RISC-V 目标文件，并不等于这些内容都已经存在。

## 练习与参考理解

把第 3 节单次申请大小改成 `1024up`。
这超出 256 字节缓冲区，应进入容量不足分支，而不是继续解引用空指针。

再回答：从 `scope(stack)` 内返回 `string.ViewFrom(...)` 指向的文字是否安全？
参考答案：如果视图指向被重置的临时存储，就不安全。应在重置前复制到生命周期足够长的存储。
