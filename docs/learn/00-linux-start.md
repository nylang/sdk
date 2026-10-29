# 00 · 在 Linux 上运行第一段程序

[选择系统](00-start.md) · [教程目录](README.md) · [下一课：变量和类型](01-values.md)

这一课使用 Linux x86_64、Bash 和匹配的本机 Nyra SDK。
SDK 1.0.3 的公开发行记录使用 Ubuntu 24.04.5 / glibc 2.39；其他发行版需核对兼容性。
先按 [SDK 安装指南](../../INSTALL.md) 下载、校验并解压完整 Linux SDK。

## 1. 准备环境

需要 Python 3.12 或更新的兼容版本，以及本机 C 开发环境。
Nyra SDK 带的 Clang 负责编译／链接，但系统头文件、启动对象和 libc 开发文件仍要由系统提供。

检查：

```sh
uname -m
python3 --version
cc --version
```

本课机器架构应为 `x86_64`。如果缺少开发工具：

Ubuntu/Debian 系可以参考：

```sh
sudo apt update
sudo apt install python3 build-essential zlib1g-dev libxml2-dev
```

AlmaLinux/Fedora 系可以参考：

```sh
sudo dnf install python3 gcc gcc-c++ glibc-devel zlib-devel libxml2-devel
```

发行版仓库里的 Python 版本不一定满足要求，安装后仍要检查版本。
Ubuntu 的 `build-essential` 包包含 GCC、make 和 libc 开发依赖；
这类开发依赖与 Nyra 的目标运行库不是一回事。
[可选：Ubuntu 包信息](https://packages.ubuntu.com/jammy/build-essential)。

这些是准备系统组件的方法，不是“所有发行版都已经通过发布验收”的承诺。
如果 SDK 报 `GLIBC_x.y not found`，应选择为兼容基线构建的 SDK 或重新构建本机工具，
不要直接覆盖系统 libc。

## 2. 选择完整 SDK

把 NYRA_SDK 改成实际解压位置，不需要进入编译器源码仓库：

```sh
export NYRA_SDK="$HOME/Downloads/nyra-sdk-1.0.3-linux-x86_64"
export NYRA_SDK_ROOT="$NYRA_SDK"
export NYRA_HOST="linux-x86_64"
export NYRAC="$NYRA_SDK/hosts/$NYRA_HOST/bin/nyrac"
export NYRA_ANALYZER="$NYRA_SDK/hosts/$NYRA_HOST/bin/nyra-analyzer"
export NYRA_WORK="$HOME/nyra-learning"
export PATH="$NYRA_SDK/hosts/$NYRA_HOST/bin:$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin:$PATH"
export CC="$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin/clang"
export AR="$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin/llvm-ar"

"$NYRAC" version
"$NYRA_ANALYZER" version
```

WSL 使用 Linux SDK，不要把 Windows exe 和 Linux 运行库混用。

## 3. 创建练习包

```sh
mkdir -p "$NYRA_WORK/playground"
cd "$NYRA_WORK/playground"

python3 - <<'PYTHON'
from pathlib import Path
Path("package.yaml").write_text("name: nyra_lessons\n", encoding="utf-8")
PYTHON
```

SDK 1.0.3 自动查找自带的 kernel、stdlib 和 ntest，不需要配置私有源码路径。


## 4. 保存并运行代码

新建 `playground/main.ny`，完整内容：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("你好，Nyra！");
  return 0;
}
```

运行：

```sh
"$NYRAC" check "$NYRA_WORK/playground/main.ny"
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/hello"
```

预期输出 `你好，Nyra！`。

保存成可执行文件：

```sh
"$NYRAC" build "$NYRA_WORK/playground/main.ny" --link \
  --out-dir "$NYRA_WORK/out/hello-build" \
  -o "$NYRA_WORK/out/hello-build/hello"
"$NYRA_WORK/out/hello-build/hello"
```

## 5. 后面的课程怎样继续

macOS/Linux 章节的 Bash 命令基本相同，继续使用本课设置的变量即可。
不过：

- Linux 没有 `xcrun` 和 Apple 系统 SDK，不运行 macOS 专用命令。
- `.dylib` 是 Apple 平台的动态库后缀，Linux 常见的是 `.so`。
- Android 交叉编译使用 Linux 版 NDK；本教程的 iOS 最终集成在 Mac 上完成。

## 常见问题

- `Permission denied`：确认 SDK 由保留执行权限的包解压，且所在磁盘允许执行。
- 文件明明存在却显示无法运行：可能选错架构，或缺少该 ELF 所需的动态加载器／系统库。
- 找不到 `crt1.o`、`crti.o`、`-lc`：检查系统 C 开发组件和 Clang 的本机工具链搜索路径。
- SDK 解压后路径多了一层：确认 `NYRA_SDK/manifest.json` 和 `NYRA_SDK/hosts/linux-x86_64` 确实存在。
- 出现源码错误：先运行 `check`，从第一条诊断开始修复。

**继续：[第 01 课](01-values.md)。**
