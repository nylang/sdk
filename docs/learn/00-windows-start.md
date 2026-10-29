# 00 · 在 Windows 上运行第一段程序

[English](en/00-windows-start.md)

[选择系统](00-start.md) · [教程目录](README.md) · [下一课：变量和类型](01-values.md)

这一课使用 Windows x86_64、本机 Nyra SDK 和 PowerShell。
命令中的路径是例子，先替换成你实际保存的位置。

## 1. 准备三个东西

1. Python 3.12 或更新的兼容版本，确保 `python --version` 能正常执行。
2. Visual Studio 或 Build Tools 的 C++ 桌面开发工具，以及匹配的 Windows SDK。
3. 一整套已准备好的 `windows-x86_64` Nyra SDK。

安装 C++ 工具时，在 Visual Studio Installer 中选择 `Desktop development with C++`。
开发者终端会设置系统头文件和库路径，不是只有 `clang.exe` 就足够了。
不同版本的入口名称可能略有变化；可选操作说明是
[微软的命令行工具指南](https://learn.microsoft.com/en-us/cpp/build/building-on-the-command-line)。

从开始菜单打开 **x64 Native Tools Command Prompt**，再在里面运行：

```text
powershell
```

这样进入的 PowerShell 会继承 x64 开发环境。
本课剩余命令都在这个 PowerShell 里执行，不要混进普通 CMD。

## 2. 选择完整 SDK

按 [SDK 安装指南](../../INSTALL.md) 下载、校验并解压 windows-x86_64 发行包。
假设解压在 E:/sdks/nyra-sdk-1.0.3-windows-x86_64，换成实际位置：

```powershell
$env:NYRA_SDK = "E:/sdks/nyra-sdk-1.0.3-windows-x86_64"
$env:NYRA_SDK_ROOT = $env:NYRA_SDK
$env:NYRA_HOST = "windows-x86_64"
$env:NYRAC = "$env:NYRA_SDK/hosts/$env:NYRA_HOST/bin/nyrac.exe"
$env:NYRA_ANALYZER = "$env:NYRA_SDK/hosts/$env:NYRA_HOST/bin/nyra-analyzer.exe"
$env:NYRA_WORK = "$env:USERPROFILE/nyra-learning"
$env:CC = "$env:NYRA_SDK/hosts/$env:NYRA_HOST/llvm/bin/clang.exe"
$env:AR = "$env:NYRA_SDK/hosts/$env:NYRA_HOST/llvm/bin/llvm-ar.exe"
$env:PATH = "$env:NYRA_SDK/hosts/$env:NYRA_HOST/bin;$env:NYRA_SDK/hosts/$env:NYRA_HOST/llvm/bin;$env:PATH"
$env:PYTHONUTF8 = "1"

python --version
& $env:NYRAC version
& $env:NYRA_ANALYZER version
```

关闭终端后，需要重新执行本节设置。

## 3. 创建练习包

```powershell
New-Item -ItemType Directory -Force "$env:NYRA_WORK/playground" | Out-Null
Set-Location "$env:NYRA_WORK/playground"

@'
from pathlib import Path
Path("package.yaml").write_text("name: nyra_lessons\n", encoding="utf-8")
'@ | python -
```

SDK 1.0.3 自动查找自带的 kernel、stdlib 和 ntest。这里无需编译器源码或绝对依赖地址。


## 4. 保存并运行代码

用编辑器在 `playground` 新建 `main.ny`，保存为 UTF-8：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("你好，Nyra！");
  return 0;
}
```

执行：

```powershell
& $env:NYRAC check "$env:NYRA_WORK/playground/main.ny"
& $env:NYRAC run "$env:NYRA_WORK/playground/main.ny" --out-dir "$env:NYRA_WORK/out/hello"
```

预期输出 `你好，Nyra！`。

保存成可执行文件：

```powershell
& $env:NYRAC build "$env:NYRA_WORK/playground/main.ny" --link --out-dir "$env:NYRA_WORK/out/hello-build" -o "$env:NYRA_WORK/out/hello-build/hello.exe"
& "$env:NYRA_WORK/out/hello-build/hello.exe"
```

## 后续课程的命令怎么换成 PowerShell

Nyra 代码不用翻译，终端命令按下面规律换：

- `$NYRA_WORK` 换成 `$env:NYRA_WORK`，其他环境变量同理。
- 执行变量指向的工具，前面加 `&`，例如 `& $env:NYRAC`。
- `python3` 在本课环境中换成 `python`。
- Bash 行末的 `\` 不是 PowerShell 续行符。初学时把命令写在一行即可。
- `mkdir -p 路径` 换成 `New-Item -ItemType Directory -Force 路径`。
- `cd 路径` 可以写成 `Set-Location 路径`。
- 运行可执行文件时使用它的 `.exe` 路径。

几个可直接复制的常用命令：

```powershell
& $env:NYRAC check "$env:NYRA_WORK/playground/main.ny"
& $env:NYRAC run "$env:NYRA_WORK/playground/main.ny" --out-dir "$env:NYRA_WORK/out/current"
& $env:NYRA_ANALYZER analyze "$env:NYRA_WORK/playground/main.ny"
```

遇到课程里的 `python3 - <<'PY' ... PY`，那是 Bash 的多行输入写法。
在 PowerShell 中，把相同 Python 代码放进 `@' ... '@ | python -`，像第 3 节一样。
也可以把 Python 代码保存为 `cache/learn/某个名字.py`，再用 `python 文件路径` 执行。

不要在旧版 Windows PowerShell 中用默认的 `>` 重定向保存重要 UTF-8 数据或探针原始字节，
它可能重新编码文本。需要保留某个命令的 stdout/stderr 原始内容时，用 Python 的 `subprocess`，
并把输出文件以 `wb` 模式打开。例如：

```python
import os
import subprocess
from pathlib import Path

work = Path(os.environ["NYRA_WORK"])
out = work / "out/capture"
out.mkdir(parents=True, exist_ok=True)
command = [os.environ["NYRAC"], "check", str(work / "playground/main.ny")]
with (out / "stdout.log").open("wb") as stdout, (out / "stderr.log").open("wb") as stderr:
    subprocess.run(command, stdout=stdout, stderr=stderr, check=True)
```

把它保存成 Python 文件再运行。其他捕获场景只替换 `command` 列表。

## 常见问题

- `python` 打开应用商店：检查 Python 安装和应用执行别名，先让 `python --version` 正常。
- 工具路径不存在：用 `Test-Path $env:NYRAC` 检查，SDK 目录可能多套了一层。
- 缺少 `windows.h`、`kernel32.lib` 或 CRT：确认在正确的 x64 开发者环境中启动了 PowerShell。
- 路径含空格时报错：保留引号和调用运算符 `&`。
- 运行时找不到库：确认使用同一套 SDK，并检查是否额外引入了需要部署的第三方 DLL。
- 看见乱码：先确认源码为 UTF-8、SDK 支持 UTF-8 启动路径，再看终端显示设置，不要修改业务字符串绕过去。

这一课使用 Windows x86_64 本机 SDK；它不代表 Windows ARM64 或所有旧版 Windows 都已验收。

**继续：[第 01 课](01-values.md)。**
