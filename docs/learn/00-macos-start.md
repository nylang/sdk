# 00 · 在 macOS 上运行第一段程序

[English](en/00-macos-start.md)

[选择系统](00-start.md) · [教程目录](README.md) · [下一课：变量和类型](01-values.md)

这一课只做一件事：让屏幕显示 `你好，Nyra！`。
先照着操作，后面几课再解释语言细节。

## 1. 准备好终端和编辑器

打开 macOS 的“终端”，准备一个能保存 UTF-8 文本的编辑器。
按 [SDK 安装指南](../../INSTALL.md) 下载匹配架构的完整 SDK 并校验、解压。
Apple 芯片选择 darwin-arm64；Intel Mac 选择 darwin-x86_64。
本课不要求取得或构建编译器源码。

检查系统工具：

```sh
uname -m
python3 --version
xcrun --show-sdk-path
```

如果 xcrun 提示没有开发者工具，运行 `xcode-select --install`，按系统提示安装后继续。

## 2. 选择一整套 SDK

下面的 SDK 路径是例子，换成实际包含 manifest.json 的目录。
Intel Mac 同时把 NYRA_HOST 改成 darwin-x86_64，并选择对应的 SDK。

```sh
export NYRA_SDK="$HOME/Downloads/nyra-sdk-1.0.3-darwin-arm64"
export NYRA_SDK_ROOT="$NYRA_SDK"
export NYRA_HOST="darwin-arm64"
export NYRAC="$NYRA_SDK/hosts/$NYRA_HOST/bin/nyrac"
export NYRA_ANALYZER="$NYRA_SDK/hosts/$NYRA_HOST/bin/nyra-analyzer"
export NYRA_WORK="$HOME/nyra-learning"
export PATH="$NYRA_SDK/hosts/$NYRA_HOST/bin:$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin:$PATH"
export SDKROOT="$(xcrun --show-sdk-path)"
export CC="$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin/clang"
export AR="$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin/llvm-ar"

"$NYRAC" version
"$NYRA_ANALYZER" version
```

这些变量只在当前终端会话中有效。关闭终端后，重新执行本节命令。
编译器、LLVM 工具和库从同一套 SDK 取，不要只替换编译器文件。

## 3. 创建练习目录

```sh
mkdir -p "$NYRA_WORK/playground"
cd "$NYRA_WORK/playground"

python3 - <<'PYTHON'
from pathlib import Path
Path("package.yaml").write_text("name: nyra_lessons\n", encoding="utf-8")
PYTHON
```

SDK 1.0.3 会自动找到自带的 kernel、stdlib 和 ntest；这里不写机器相关的依赖路径。
JSON/YAML 等生态包在对应课程中单独说明。后续源码仍需写 import。


## 4. 保存第一段代码

在这个目录里新建 `main.ny`，写入以下完整程序：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("你好，Nyra！");
  return 0;
}
```

保存时使用 UTF-8 编码。文件名是 `main.ny`，不要存成 `main.ny.txt`。

先检查代码：

```sh
"$NYRAC" check "$NYRA_WORK/playground/main.ny"
```

检查成功时可能没有额外输出。然后运行：

```sh
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/hello"
```

预期输出：

```text
你好，Nyra！
```

## 5. 这几行分别是什么意思

- `import`：使用标准库提供的功能。
- `func main()`：程序从这里开始执行。
- `-> int32`：结束时返回一个整数状态码。
- `Console.Println(...)`：把括号里的内容显示出来，并换行。
- `return 0;`：正常结束程序。

引号里的文字可以改。`Console`、`Println` 的大小写不能随意改。

## 6. 保存成可执行文件

```sh
"$NYRAC" build "$NYRA_WORK/playground/main.ny" --link \
  --out-dir "$NYRA_WORK/out/hello-build" \
  -o "$NYRA_WORK/out/hello-build/hello"

"$NYRA_WORK/out/hello-build/hello"
```

`check` 检查代码，`build --link` 生成可执行文件，`run` 编译后直接运行。
这里显式写 `--link`，避免把只生成目标文件误当成已经生成可执行程序。

## 遇到问题时按这个顺序看

1. 提示文件不存在：确认 `main.ny` 的保存位置，以及 `NYRAC` 是否还有效。
2. 提示没有 `stdlib`：确认 `main.ny` 同目录有刚才生成的 `package.yaml`。
3. 提示找不到系统头文件、链接器或系统库：重新检查 `xcrun`、`SDKROOT` 和 `CC`。
4. 提示架构不匹配：确认终端、SDK 和目标库都是本机支持的架构。
5. 出现 `NY...` 诊断：先看文件名、行号和第一条错误；先修第一条，再运行 `check`。
6. 课程要求的能力与已安装版本不同：核对发行说明；不要把不同版本的包拼起来。

## 动手练习

把输出改成两行，分别显示你的名字和今天的学习目标。

参考答案：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("我叫小明");
  Console.Println("今天要学会运行 Nyra 程序");
  return 0;
}
```

学会后，你应该能自己找到文件、修改内容、保存并重新运行。
