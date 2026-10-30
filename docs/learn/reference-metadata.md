# 元数据字典：@ 写在哪里、起什么作用

[English](en/reference-metadata.md) · [教程目录](README.md) · [语言字典](reference-keywords.md)

## 1. 编译器属性不是注释标签

`@inline`、`@test(...)` 是编译器读取的属性，要放在相应声明／语法位置。
`/** @brief ... @param ... @returns ... */` 是 API 文档注释，不能改变 ABI 或生成测试。
不支持的属性不会因为长得像其他语言的注解就自动生效；也不能给所有属性任意传键值参数。
下表说明当前原生语法／契约；公开起步 SDK 与较新的源码能力要分别对待。
有完整程序的条目直接练习；标为高级协议的条目须结合相应课程，不是复制一行就完成系统集成。

## 2. 常用属性

| 写法 | 附着位置 | 功能与限制 |
|---|---|---|
| `@inline` | 函数／方法 | 内联标记；不改变返回值或所有权。泛型有体本来就按内联实例化规则处理；`.ni` 普通函数体需 inline |
| `@build_type("dev|test")` | 声明或语句块 | 与编译器 `--build-type` 匹配时保留；`|` 分隔可选构建名，不是运行时 if |
| `@test` | 测试函数 | 注册单测，普通构建会剔除；用 `nyrac test` 运行 |
| `@test(tag = "math")` | 测试函数 | 一个字符串标签，用 `--tag math` 筛选；不是标签数组 |
| `@test(ignore = true)` | 测试函数 | 默认跳过；显式 `--include-ignored` 才包含 |
| `@test(should_abort = true)` | 测试函数 | 期望测试子进程中止；不是“任意失败都算通过” |
| `@test(should_abort = true, abort_contains = "text")` | 测试函数 | 另外要求中止信息包含子串；不能单独只写 abort_contains |
| `@profile(cpu, memory, tag = "work")` | 支持的同步函数／方法 | 选择 CPU／内存观测点；配合 `--profile`，不是自动启动全程序性能报告；异步／生成器不套用同步承诺；[完整性能例子](14-compiler-tools.md#6-测量自己的同步函数) |
| `@extern("C")` | 外部 ABI 函数 | C 调用约定，可用于声明或提供定义；不自动查找／链接外部库 |
| `@extern("C", api)` | 公开 C API | 交给头文件／导入导出处理；不能把 `export "x.ny"` 当成它 |
| `@extern("default")` | ABI 函数 | 选择默认 ABI；不等于 C ABI |

## 3. 完整程序：inline 与 build_type

```nyra
struct MathValue {
  value: int32;
}

@inline
method(MathValue) Double() -> int32 {
  return self.value + self.value;
}

func main() -> int32 {
  var expected: int32 = 42;
  @build_type("release") {
    expected = 42;
  }

  let value: MathValue = MathValue{ value: 21 };
  if value.Double() != expected {
    return 1;
  }

  return 0;
}
```

默认检查和运行返回 0。也可在第 00 课命令中加 `--build-type release`。
例子两个配置都预期 42，说明属性控制块是否存在，而不是要求用户在运行时选择构建类型。

## 4. 完整测试文件

另建测试练习目录，`package.yaml` 内容为 `name: metadata_tests`，`main.ny` 为：

```nyra
import "ntest:ntest.ny";

struct MathValue {
  value: int32;
}

method(MathValue) Double() -> int32 {
  return self.value + self.value;
}

@test(tag = "math")
func test_double() {
  let value: MathValue = MathValue{ value: 21 };
  AssertEqI32(value.Double(), 42);
}

@test(ignore = true)
func test_pending_example() {
  AssertTrue(true);
}

@test(should_abort = true)
func test_invalid_precondition() {
  assert(false);
}
```

运行：

```sh
"$NYRAC" test "$NYRA_WORK/metadata-tests/main.ny"
"$NYRAC" test "$NYRA_WORK/metadata-tests/main.ny" --tag math
```

第一条执行正常断言及预期中止测试，跳过 ignore；第二条只选 math。
`AssertEqI32` 是 ntest 函数，`assert` 是语言硬断言。运行预期中止例子时不能禁用断言。
更多测试流程见[第 10 课](10-tests-analyzer.md)。

## 5. 静态存储与资源嵌入

| 写法 | 位置 | 功能与边界 |
|---|---|---|
| `@singleton` | `static` 声明 | 单例存储／访问协议，读取按 `ref T` 处理 |
| `@lazy_singleton` | `static` 声明 | 懒单例；不要把它当普通可写 static 的同义词 |
| `@thread_local_singleton` | `static` 声明 | 每线程单例；不是进程共享单例 |
| `@thread_local` | 普通 `static` 声明 | 每线程存储，要求常量初始化；不能与单例家族混用 |
| `@embed("payload.bin")` | 字节数组 `static` 声明 | 编译期嵌入文件，不写普通初始化表达式 |
| `@embed_text("message.txt")` | `string static` 声明 | 编译期嵌入文本，不是运行时读文件 |
| `@embed_len(kBlob)` | 长度表达式位置 | 读取嵌入资源的字节长度，不是给另一个声明加的属性 |

完整双文件示例：`message.txt` 精确写入五个 ASCII 字节 `hello`，**不要末尾换行**；
同目录 `main.ny` 为：

```nyra
@embed_text("message.txt")
static kMessage: string;

func main() -> int32 {
  if kMessage.length != 5 {
    return 1;
  }

  return 0;
}
```

文件路径相对于声明所在源码文件解析；换一份资源再编译，内容才会更新。
如果编辑器自动加换行，长度会变成 6；这不是字符长度与字节长度混用的许可。
字节嵌入声明片段（需要同目录真实文件）：

```nyra
@embed("payload.bin")
static kBlob: <uint8>[];
```

## 6. 作用域和分配器协议

| 写法 | 位置 | 功能与前提 |
|---|---|---|
| `@scoped` | 结构体／接口 | 为 `scope (value)` 提供 Enter/Exit 协议，不是普通花括号标记 |
| `@stack_scope` | 相应接口 | 栈分配器 Mark/Reset 协议，不能与 scoped 混用 |
| `@heap`、`@stack`、`@arena` | 分配器结构体 | 标识分配器种类；不是给普通业务对象随意选堆栈的属性 |
| `@global_heap(malloc: "alloc", realloc: "resize", free: "release")` | 用户态顶层专用声明 | 映射进程全局堆入口，必须提供匹配 ABI 实现；不是普通 static 的修饰符，不用于 `.nk` |

完整 `@scoped` 程序：

```nyra
@scoped
struct Gate {
  depth: int32;
}

method(Gate) Enter() -> void {
  self.depth = self.depth + 1;
}

method(Gate) Exit() -> void {
  self.depth = self.depth - 1;
}

func main() -> int32 {
  var gate: Gate = Gate{ depth: 0 };
  scope (gate) {
    if gate.depth != 1 {
      return 1;
    }
  }

  if gate.depth != 0 {
    return 2;
  }

  return 0;
}
```

进入后 depth 为 1，离开后回到 0。`scope` 的 Enter/Exit 与对象最终 `drop` 是不同协议；
不能以“执行过 Exit”为由重复释放拥有字段。分配器教程见[第 13 课](13-systems.md)。

## 7. 高级／系统属性索引

| 写法 | 位置 | 用途和限制 |
|---|---|---|
| `@driven(ExecutorType)` | 使用 drive 的同步入口 | 固定具体执行器类型，与实参 typeof 必须匹配；还需完整 Executor 协议，见[第 12 课](12-concurrency.md) |
| `@builtin`／`@builtin("kind")` | 编译器约定的声明 | 内建实现钩子，不是用户自定义插件注册机制 |
| `@exhaustive_specialization` | 相应泛型函数 | 要求 oneof 成员的特化覆盖，不是 switch 的 default 替代品 |
| `@extern("declare") Name<int32>;` | `.ni` 特化公开面 | 发布一个具体泛型特化符号，不是无体的开放泛型模板 |
| `@extern("implement") Name<int32>;` | `.ny`／`.nk` 特化实现侧 | 本 TU 提供匹配特化定义；必须与公开面一致 |
| `@irq_safe` | 内核相关具体函数 | 中断安全效果检查，不凭一个外部声明就证明实现安全 |
| `@interrupt` | 内核处理函数 | 具体同步、无参数、无返回值，并接受中断安全检查；不生成硬件 trap frame、向量表或调度器 |

最小 C API 定义文件（**库源码，不是带 main 的程序**）：

```nyra
@extern("C", api)
pub func NyraAnswer() -> int32 {
  return 42;
}
```

编译、生成头文件、链接 C 消费者的完整步骤见[第 15 课](15-c-interop.md)。
不要只写 ABI 属性就宣称库已经链接、目标平台已经验收。

## 8. 不要照抄的旧写法／提案

| 名字 | 本教程如何处理 |
|---|---|
| `@global_allocator` | 已被替代，使用完整的 @global_heap 专用声明 |
| `@noinline`、`@rodata`、`@memory_trace`、`@no_trace` | 旧词汇设计中出现，但当前原生解析路径不提供可直接照抄的通用写法；不作为本教程可运行属性。只读全局用 readonly static；性能观测看 @profile |
| `@packed`、`@align(N)` | 设计中的可能扩展，不能当成现有 SDK 的布局保证 |
| 任意自创 `@名字` | 不是可自动运行的装饰器系统；先核对编译器支持 |

文档注释可以写 `@brief`、`@param`、`@returns`、`@note`、`@warning`；它们应在注释内，
不能移到声明前冒充编译器属性。教程只解释既有契约，不因加了一行表格就启用新语法。
