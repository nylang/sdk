# 00 · 先选择你的电脑系统

[English](en/00-start.md)

[教程目录](README.md)

Nyra 的代码在几个系统上写法相同。开始学习前，需要先配置与你电脑匹配的工具。
这一页帮你选入口，不需要把三个系统都安装一遍。

## 1. 选一条路线

- Apple 芯片的 Mac：[macOS 起步](00-macos-start.md)。
- Windows x86_64 电脑：[Windows 起步](00-windows-start.md)，使用 PowerShell。
- Linux x86_64 电脑：[Linux 起步](00-linux-start.md)，使用 Bash。

完成对应的第 00 课，看到 `你好，Nyra！` 后，统一进入 [第 01 课](01-values.md)。
其他架构要先取得匹配的 SDK，不能把 `darwin-arm64`、`windows-x86_64`、`linux-x86_64` 的目录名互相替换来冒充适配。

## 2. “电脑系统”和“目标系统”不一定相同

先学习在自己的电脑上运行程序，叫本机开发。

后面制作手机库时：

- Mac 上运行的编译器，可以生成 iOS 或 Android 用的库。
- Windows、Linux 上运行的编译器，可以配合 NDK 生成 Android 用的库。
- 本教程中，iOS 的最终链接和 Xcode 集成在 Mac 上进行。

手机使用的是编译后的库，不需要把 Nyra 编译器装进手机。

## 3. SDK 到底是什么

SDK 从[公开发行页](https://github.com/nylang/sdk/releases/tag/v1.0.3)下载；
先按 [INSTALL.md](../../INSTALL.md) 核对 SHA256SUMS 并完整解压。
公开 1.0.3 SDK 的主要布局是：

```text
SDK目录/
  manifest.json
  package-lock.json
  hosts/本机标识/bin/
    nyra 或 nyra.exe
    nyrac 或 nyrac.exe
    nyra-analyzer 或 nyra-analyzer.exe
  hosts/本机标识/llvm/
  packages/kernel/package.yaml
  packages/ntest/package.yaml
  packages/stdlib/package.yaml
  packages/包名/targets/本机标识/
```

`hosts` 放在开发电脑上执行的工具，`packages` 放 SDK 自带的库及其目标产物。
JSON、YAML 是独立生态包，不在这里假定存在 `targets/本机/json` 等旧布局。
SDK 1.0.3 每套只包含自己的桌面运行库；SDK 1.0.2 的跨目标目录保持原来的范围。
目标是否可用，以实际 SDK 的 manifest 为准。不要通过修改目录名冒充其他平台支持。

## 4. 后续代码相同，终端命令有区别

后续 `.ny` 代码块三个系统都按同样方式保存。
多数终端命令使用 macOS/Linux 的写法。Windows 的命令翻译方法在
[Windows 课的对应部分](00-windows-start.md#后续课程的命令怎么换成-powershell)。

先记住最常用的一对：

macOS / Linux：

```sh
"$NYRAC" run "$NYRA_WORK/playground/main.ny" --out-dir "$NYRA_WORK/out/current"
```

Windows PowerShell：

```powershell
& $env:NYRAC run "$env:NYRA_WORK/playground/main.ny" --out-dir "$env:NYRA_WORK/out/current"
```

Windows 前面的 `&` 表示执行后面路径指向的程序。
终端里的引号不要省略，它们帮助保留路径中的空格。

## 5. 这次要学手机开发或 C 互调

先完成自己系统的第 00 课。如果还不熟悉函数和指针，先学习基础课程，再看：

1. [15 · Nyra 与 C 相互调用](15-c-interop.md)。
2. [16 · 在 iOS 应用里使用 Nyra](16-ios.md)。
3. [17 · 在 Android 应用里使用 Nyra](17-android.md)。

这三课使用很小的业务库逐步连接手机界面，不会要求你先用 Nyra 重写整个手机 UI。

## 6. SDK 1.0.4 的包创建入口（候选功能）

使用带有 1.0.4 工具的 SDK 时，可以运行 `nyra new hello` 创建应用，或运行
`nyra new mylib --kind lib` 创建库。先加 `--dry-run --json` 可以查看计划。
已有源码目录使用 `nyra init ./existing --name existing`，不会重写源码。
VS Code 中的 **Nyra: Create Package** 和 **Nyra: Initialize Package** 使用同一套原生入口。
这部分目前属于 1.0.4 源码候选；旧版 SDK 没有这些命令时，请按各平台第 00 课手动创建文件。
