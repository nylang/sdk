# 语言字典：关键字、类型与常见语法词

[English](en/reference-keywords.md) · [教程目录](README.md)

这份字典按“这个词做什么”查阅。关键字区分大小写，语言词使用小写；
`Console`、`Array`、`Result`、`AssertTrue` 是库中的名字，不是关键字。
保留词、上下文语法词和内置操作分开列出：能写出一个词，不代表它能用在任意位置。
以下是教学参考，不把未来设计或任意 `@名字` 当成当前 SDK 能力。

## 模块与公开边界

| 词 | 功能／最小形式 | 去哪里学 |
|---|---|---|
| `module` | `module Prices;` 为一个 TU 命名，不是包声明 | [模块详解](reference-modules.md) |
| `part`、`of` | 主文件 `part "private/math.ny";`；子文件 `part of Prices;`，同一个 TU | [模块详解](reference-modules.md) |
| `import` | `import "prices.ny";` 使用另一个模块的公开面 | [第 07 课](07-packages.md) |
| `export` | `export "prices.ny";` 把另一模块的公开面重新提供给导入者 | [模块详解](reference-modules.md) |
| `pub` | `pub struct Price`、`pub method(Price) Total()`，允许跨模块使用 | [类型详解](reference-types.md) |
| `as` | `import "prices.ny" as prices;` 起导入别名；`value as int64` 做类型转换 | [模块详解](reference-modules.md) |
| `show`、`hide` | 导入／导出的名字白名单或排除名单；同一条不能混用 | [模块详解](reference-modules.md) |
| `namespace` | 组织名字；不新建 TU，也不新建包 | [模块详解](reference-modules.md) |

## 声明、类型和行为

| 词 | 功能／形式 | 注意 |
|---|---|---|
| `let`、`var` | 不可重新赋值／可重新赋值的局部绑定 | `let n: int32 = 1;`；不是所有权种类 |
| `const` | 泛型常量参数，如 `const N: uintptr` | 不是普通局部常量声明的替代写法 |
| `static` | 全局存储；或 `static method(T)` 类型级方法 | 类型级方法没有 `self` |
| `readonly` | 只读字段；`readonly static` 为只读全局存储 | 不等于深度冻结所有指针指向的对象 |
| `func` | `func main() -> int32`，定义函数 | 方法使用 `method` |
| `method` | `method(Counter) Add(n: int32) -> void` | 定义在结构体外，同一接收类型不按参数重载 |
| `factory` | `factory(Counter) Make(...) -> unique<Counter>` | 通过 `Counter.Make(...)` 调用，无 `self`，不用 `static factory` |
| `operator` | `method(T) operator drop() -> void` 等操作符方法 | 不写成全局操作符函数；不能加 `static` |
| `get`、`set` | `method(T) get value -> int32`／`set value(v: int32)` | 使用 `obj.value`／`obj.value = 42`，不加调用括号 |
| `struct` | 命名字段布局和值类型 | 方法和工厂另行定义 |
| `extends` | 结构体的单一布局扩展；接口的接口扩展 | 不是虚函数类继承 |
| `interface` | 方法／属性签名契约 | 成员签名以 `;` 结束，没有实现体 |
| `implements` | 结构体显式声明实现的接口 | 仅有同名方法不等于显式接口契约 |
| `delegate` | `delegate field : Iface;` 把接口操作转交字段 | 歧义要解决，不能隐式任选一个字段 |
| `enum` | 有名字的常量选项 | 不同于携带数据的 `variant` |
| `union` | C 风格重叠布局 | 不提供 `variant` 的活动分支安全性 |
| `variant` | 携带不同类型数据的和类型 | 用 `holds<T>()`、`get_if<T>()`、`visit` 等操作处理 |
| `typedef` | `typedef Count = int32;` 类型别名 | 不会凭空得到独立的新类型 |
| `tuple` | `tuple<int32, int32>` 临时组合返回值 | `let (a, b) = pair;` 解构 |
| `lambda` | `lambda [copy x] (...) -> R { ... }` 回调 | 捕获须写方式；不要假定任意借用捕获都支持 |
| `concept` | 命名泛型约束 | [第 08 课](08-generics.md) |
| `enable` | 受约束的参数通道，如格式化可变参数 | 不是布尔开关或条件编译指令 |

[类型、方法、工厂、接口和 drop 的完整程序](reference-types.md)。

## 控制流程和表达式

| 词 | 功能／形式 |
|---|---|
| `if`、`else` | `if condition { ... } else { ... }` 条件分支 |
| `switch`、`case`、`default` | 按值选择分支；没有自动落入下一分支 |
| `while` | 条件循环 |
| `for`、`in` | `for item in items { ... }` 遍历 |
| `break`、`continue` | 离开当前循环／进入下一轮 |
| `return` | 返回当前函数、方法或工厂 |
| `scope` | `scope (region) { ... }` 使用作用域协议；不是裸块的别名 |
| `unsafe` | 标出原始指针等危险操作的区域；不自动提供内存安全 |
| `assert` | 运行时硬断言，受断言开关控制 |
| `static_assert` | 编译期断言 |
| `sizeof`、`alignof` | 查询类型大小、对齐 |
| `typeof` | 取表达式的类型，供类型位置等使用 |
| `true`、`false` | 布尔字面量 |
| `nil` | 可空类型 `T?` 的空值；不是任意整数或指针的通用零 |
| `async`、`await` | 异步函数与等待 |
| `sync`、`yield` | `sync*` 生成器与产生元素；`async*` 是异步生成器 |
| `drive` | 同步入口通过具体执行器驱动异步调用 |

见[控制流程](02-control-functions.md)、[并发](12-concurrency.md)、[系统编程](13-systems.md)。

## 所有权与借用

| 词 | 功能 | 典型形式 |
|---|---|---|
| `owned` | 语言所有权类型构造形式 | 不等于“需要手动 Free” |
| `unique` | 唯一拥有者 | `new unique<Box>{ value: 42 }` |
| `rc`、`arc` | 引用计数／原子引用计数拥有者 | `rc<T>`／`arc<T>` |
| `weak` | 非强拥有的弱引用 | 升级结果可能为空 |
| `ac` | arena cell，生存期由 arena 管理 | `ac<T>` |
| `ref` | 不可变借用 | `value: ref T` |
| `mut` | 可变权限修饰 | `ref mut T`、`*mut T`、`&mut value` |
| `copy` | 显式复制 | `copy(value)`；可调用类型的 copy 操作符 |
| `move` | 显式转移所有权 | `move(value)`；转移后不能再使用旧拥有者 |
| `new` | 按所有权和分配器创建对象 | `new unique<T>{ ... }`；也有显式分配器形式 |

`ref^ T` 是消费参数写法，由已有 `ref` 和 `^` 组成，不是新指针类型。
完整生命周期例子见[第 04 课](04-ownership.md)与 [drop 说明](reference-types.md#drop)。

## 内置类型

| 类型词 | 意义 |
|---|---|
| `int8`、`int16`、`int32`、`int64` | 固定位宽有符号整数 |
| `uint8`、`uint16`、`uint32`、`uint64` | 固定位宽无符号整数；`uint8` 也是字节 |
| `intptr`、`uintptr` | 指针位宽整数，随目标平台变化 |
| `float32`、`float64` | 浮点数 |
| `bool` | 布尔值 |
| `string` | 字符串值；不是需要用户手动释放的 C 字符串指针 |
| `symbol` | 符号标识，例如 `'ready`，不是字符串 |
| `void` | 不返回结果值 |

普通整数默认 `int32`，普通浮点数默认 `float64`；紧凑后缀如 `42u64`、`1.5f`。
`num`、`real` 是泛型约束／推导语法词，不可作为字段的存储类型。

## 上下文词与容易误会的名字

| 写法 | 正确理解 |
|---|---|
| `self` | 实例方法当前接收者；静态方法和工厂没有它 |
| `drop` | `operator drop` 的操作符名字，不是独立的普通关键字调用 |
| `delete` | `method(T) operator copy() -> T = delete;` 禁用复制的后缀；不是手工删除对象的语句 |
| `constexpr` | `if constexpr` 的编译期分支；也有标量编译期值声明，不能任意取地址 |
| `oneof`、`copyable`、`movable` | 泛型约束词，放在相应约束位置 |
| `holds`、`get_if`、`visit` | `variant` 等类型的成员操作，不是任意对象都有的语句 |
| `once` | 旧词汇设计中出现的名字；本教程不把它教成可直接使用的独立语句 |
| `@test`、`@inline` 等 | 编译器元数据，另查[元数据字典](reference-metadata.md) |
| `@brief`、`@param`、`@returns` | `/** ... */` 中的文档标签，不是编译器元数据 |
| `$` | 留给内部 ABI 连接，不可当成源码标识符字符或字符串插值语法 |

不要把语法说明里的 `...` 原样复制到完整程序。预定功能也不代表已发布 SDK 提供。
