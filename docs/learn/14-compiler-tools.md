# 14 · 看懂编译过程和性能数据

[English](en/14-compiler-tools.md)

[上一课](13-systems.md) · [教程目录](README.md) · [下一课：C 互调](15-c-interop.md)

日常写程序不要求阅读 IR。这一课用于解释编译器在做什么，以及遇到慢、卡住或错误时怎样保留证据。
涉及 dump 和 profile 能力时，以已安装 SDK 的实际命令和发行说明为准。

## 1. 一段程序经过哪些步骤

先这样理解：

```text
你写的源码
  ↓ 识别语法，检查类型和名字
Nyra AST：保留语言层面的结构
  ↓ 展开泛型等抽象，降低复杂表达
Core AST：更基础的结构
  ↓ 生成指令
LLVM IR
  ↓ 优化并生成机器码
目标文件 .o
  ↓ 和依赖库连接
可执行文件
```

AST 是编译器理解代码后保存的结构化表示。
IR 是比源码更接近机器执行步骤的表示。
“链接”把目标文件和库组合起来，解决互相调用的符号。

## 2. 先准备一个很小的完整程序

替换 `playground/main.ny`：

```nyra
func add(left: int32, right: int32) -> int32 {
  return left + right;
}

func main() -> int32 {
  let result: int32 = add(20, 22);
  if result != 42 { return 1; }
  return 0;
}
```

它不需要控制台输出。成功状态码是 0。
小例子更容易看清结构，不必一上来导出整个编译器。

## 3. 导出四种视图

```sh
mkdir -p "$NYRA_WORK/dumps"

"$NYRAC" dump-nyra-ast "$NYRA_WORK/playground/main.ny" \
  -o "$NYRA_WORK/dumps/nyra"

"$NYRAC" dump-core-ast "$NYRA_WORK/playground/main.ny" \
  -o "$NYRA_WORK/dumps/core" \
  --out-dir "$NYRA_WORK/out/dump-core"

"$NYRAC" dump-c "$NYRA_WORK/playground/main.ny" \
  -o "$NYRA_WORK/dumps/c" \
  --out-dir "$NYRA_WORK/out/dump-c"

"$NYRAC" -O0 --ir-stage raw dump-ir "$NYRA_WORK/playground/main.ny" \
  -o "$NYRA_WORK/dumps/ir" \
  --out-dir "$NYRA_WORK/out/dump-ir"
```

分别观察语言结构、降级结构、C 形式的投影和 LLVM IR。
文件可能按 TU 分开，不要把多个 `.ll` 简单拼成一个文件来编译。

`dump-c` 是便于阅读和外部对照的导出能力。
正常编译仍然由 Nyra 的 Core 后端生成 LLVM IR，不是每次先调用 Clang 编译 C。

## 4. 想知道正在编译什么，开 `--verbose`

```sh
"$NYRAC" --verbose build "$NYRA_WORK/playground/main.ny" --link \
  --out-dir "$NYRA_WORK/out/verbose" \
  -o "$NYRA_WORK/out/verbose/program"
```

它显示工作进度和相应阶段耗时。长程序中看到最后一个开始或结束的 TU，有助于判断进度停在哪里。
不要把屏幕暂时没输出就直接认定为死锁：编译器可能仍在处理某个大 TU。

## 5. 测量编译器本身

```sh
"$NYRAC" --profile cpu,memory -O0 --ir-stage raw \
  dump-ir "$NYRA_WORK/playground/main.ny" \
  -o "$NYRA_WORK/dumps/profile-ir" \
  --out-dir "$NYRA_WORK/out/profile-ir" \
  2> "$NYRA_WORK/dumps/compiler-profile.log"

cat "$NYRA_WORK/dumps/compiler-profile.log"
```

这测量的是“编译这份程序”的过程，不是运行用户程序的耗时。
日志保留阶段记录，本课直接查看原始文本。开发期报告脚本不随公开 SDK 提供。

读数据时先区分：

- 经过时间：人等了多久，包括等待。
- CPU 时间：处理器实际花了多少工作时间。
- 分配次数：申请内存的操作次数，不等于同时存活的对象数。
- 累计分配字节：整个过程申请过多少，不等于峰值内存。
- 存活量、峰值、RSS：统计口径不同，不能互相直接替代。

多线程 CPU 时间可能超过经过时间。开启探针也有开销。
自定义分配器不一定全部进入默认堆计数，因此不能只靠一个数字断言“没有泄漏”。

## 6. 测量自己的同步函数

这是另一件事：给用户程序标点，并在运行时收集。
下面是完整程序，替换 `main.ny`：

```nyra
import "stdlib:stdlib.ny";

@profile(cpu, memory, tag = "lesson.message")
func make_message() -> string {
  var buffer: StringBuffer = StringBuffer.NewWithCapacity(64);
  buffer.Append("你好");
  buffer.Append("，Nyra");
  return buffer.Take();
}

func main() -> int32 {
  var sink: BoundedProfileSink =
    BoundedProfileSink.New(CreateAllocator(0i64, 8i64), 32);
  if !HostedProfileCaptureStart(&mut sink) {
    sink.Release();
    return 1;
  }
  let message: string = make_message();
  if !HostedProfileCaptureStop() {
    sink.Release();
    return 2;
  }
  Console.Eprintln("生成结果：{0}", message);
  let writer: HostedProfileTextWriter = HostedProfileTextWriter.New();
  ProfileExportText(&sink, writer, false, false, ProfileRcUnboundEventCount());
  sink.Release();
  return 0;
}
```

先构建，再运行生成的程序：

```sh
"$NYRAC" --profile cpu,memory build "$NYRA_WORK/playground/main.ny" --link \
  --out-dir "$NYRA_WORK/out/user-profile" \
  -o "$NYRA_WORK/out/user-profile/program"

"$NYRA_WORK/out/user-profile/program" \
  > "$NYRA_WORK/dumps/user-profile.stdout" \
  2> "$NYRA_WORK/dumps/user-profile.stderr"
```

本例的探针记录在 `user-profile.stdout`，提示文字在 `user-profile.stderr`。
可以继续运行：

```sh
cat "$NYRA_WORK/dumps/user-profile.stdout"
```

记录里的站点标识可能需要结合对应 IR 元数据解析名称。
缓冲区有容量上限，要检查丢事件、未绑定事件和导出完整性；不完整记录不能用来证明没有泄漏。
本例只示范同步 CPU／内存作用域，不宣称覆盖异步、生成器或所有分配器。

## 7. 优化等级和跨平台

调试时先使用 `-O0`。希望生成优化后的程序，可以用：

```sh
"$NYRAC" -O2 build "$NYRA_WORK/playground/main.ny" --link \
  --out-dir "$NYRA_WORK/out/release" \
  -o "$NYRA_WORK/out/release/program"
```

`-O2` 是字母 O，不是数字 0。比较性能时，编译器、输入、优化等级、调试选项和缓存条件都要相同。
不要把一次缓存命中与另一次冷编译直接比较。

跨平台除了 CPU 目标，还需要匹配的目标库和系统 SDK。
macOS 上生成 iOS 库需要 Apple 工具链；Android 需要合适的 NDK。
仅修改目标名字，不会自动得到所有依赖和最终可运行的应用。

## 练习

把第 2 节程序分别以 `-O0` 和 `-O2` 导出 IR，使用不同目录保存。
观察 `add` 是否仍然作为独立调用出现。
优化后可能被内联或常量折叠，具体结果以实际输出为准。

你现在已经能区分源码错误、降级结构、指令生成、链接依赖和程序运行这几类问题。
