# 16 · 在 iOS 应用里使用 Nyra

[English](en/16-ios.md)

[上一课：C 互调](15-c-interop.md) · [教程目录](README.md) · [下一课：Android](17-android.md)


> **进阶参考范围**：本章保留开发期交叉编译与应用集成示例。文中的
> `nyra.py cross-build` 属于源码开发工具，不随公开 SDK 提供；只有另行取得
> 相应开发环境后才能执行这些命令，NYRA_REPO 也须指向该环境。
> SDK 1.0.3 是桌面发行包，不包含本章完整移动目标运行库。普通公开 SDK 用户
> 可先阅读调用链和应用代码；本章不代表已发布可直接执行的移动构建流程。

这一课的目标：在 iPhone 应用界面里显示 Nyra 计算出来的 42。
先用 Swift 写界面，Nyra 写一个很小的逻辑库，通过 C 接口连接。

```text
Swift 界面 → C 函数声明 → Nyra 静态库
```

这里不在手机上安装编译器，也不要求用 Nyra 直接编写 UIKit／SwiftUI 类。

## 1. 准备条件

在 Apple 芯片的 Mac 上操作，并完成 macOS 第 00 课。
另外需要：

- 完整 Xcode，以及 iOS 设备和模拟器 SDK，只有 Command Line Tools 不够。
- 从当前源码构建、包含新交叉编译功能的一整套 Nyra SDK。
- 本课先生成库；后面在 Xcode 运行应用时，再选择可用模拟器或配置真机签名。

第 00 课默认使用的旧 bootstrap seed 不是本课新功能的替代品。
把 `NYRA_SDK` 切换到实际准备好的新 SDK 后，重新设置工具变量。例如：

```sh
export NYRA_SDK="/你的路径/当前NyraSDK"
export NYRA_HOST="darwin-arm64"
export NYRAC="$NYRA_SDK/hosts/$NYRA_HOST/bin/nyrac"
export NYRA_ANALYZER="$NYRA_SDK/hosts/$NYRA_HOST/bin/nyra-analyzer"
export PATH="$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin:$PATH"
export CC="$NYRA_SDK/hosts/$NYRA_HOST/llvm/bin/clang"

"$NYRAC" version
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-path
xcrun --sdk iphonesimulator --show-sdk-path
```

如果 `xcrun` 只找到 Command Line Tools，在 Xcode 的设置中选中完整 Xcode 的命令行工具，再重试。
不要把空缺的 iOS SDK 路径换成 macOS SDK。

## 2. 写一个可以复用的手机逻辑库

```sh
mkdir -p "$NYRA_WORK/mobile_logic"
mkdir -p "$NYRA_WORK/out/ios/include"
```

新建 `mobile_logic/package.yaml`：

```yaml
name: nyra_mobile_logic
```

新建 `mobile_logic/logic.ny`：

```nyra
@extern("C", api) func nyra_add(left: int32, right: int32) -> int32 {
  return left + right;
}
```

本例只计算整数，没有标准库依赖，所以先不需要配置手机目标的 stdlib。
后面增加文字处理、容器、JSON 等功能时，再配置正确目标的预编译包。

## 3. 先生成 C 头文件

```sh
"$NYRAC" --target ios --llvm-target arm64-apple-ios15.0 --relocation pic \
  build "$NYRA_WORK/mobile_logic/logic.ny" \
  --out-dir "$NYRA_WORK/out/ios/header-objects" \
  --c-header "$NYRA_WORK/out/ios/include/nyra_logic.h"
```

生成的头文件声明 `nyra_add` 的 C 参数和返回类型。
这一步只构建对象并生成声明，不是一个能直接启动的 iOS App。

## 4. 分别编译真机和模拟器版本

先看计划，不构建：

```sh
python3 "$NYRA_REPO/nyra.py" cross-build --target ios-arm64 --minimum 15.0 --plan
```

然后构建两份静态库：

```sh
python3 "$NYRA_REPO/nyra.py" cross-build "$NYRA_WORK/mobile_logic/logic.ny" \
  --target ios-arm64 --minimum 15.0 --compiler "$NYRAC" \
  --kind static --out-dir "$NYRA_WORK/out/ios/objects" \
  -o "$NYRA_WORK/out/ios/device/libnyra_logic.a"

python3 "$NYRA_REPO/nyra.py" cross-build "$NYRA_WORK/mobile_logic/logic.ny" \
  --target ios-simulator-arm64 --minimum 15.0 --compiler "$NYRAC" \
  --kind static --out-dir "$NYRA_WORK/out/ios/objects" \
  -o "$NYRA_WORK/out/ios/simulator/libnyra_logic.a"
```

不要因为两份都是 arm64，就认为它们可以互换。
一份的目标是 iOS 真机，另一份的目标是 iOS 模拟器。
本教程的模拟器库面向 Apple 芯片 Mac，不包含 Intel Mac 的 x86_64 模拟器版本。

`--minimum 15.0` 是本例的部署下限。应用项目的部署版本不能低于所链接库的要求。

## 5. 打成一个 XCFramework

```sh
xcodebuild -create-xcframework \
  -library "$NYRA_WORK/out/ios/device/libnyra_logic.a" \
  -headers "$NYRA_WORK/out/ios/include" \
  -library "$NYRA_WORK/out/ios/simulator/libnyra_logic.a" \
  -headers "$NYRA_WORK/out/ios/include" \
  -output "$NYRA_WORK/out/ios/NyraLogic.xcframework"
```

XCFramework 把多个平台变体和头文件组织在一起，由 Xcode 根据构建目标选用。
它不是把设备与模拟器对象强行拼成同一份普通静态库。
[可选：Apple 对 XCFramework 的说明](https://help.apple.com/xcode/mac/current/en.lproj/dev6f6ac218b.html)。

如果输出目录已经存在，先用新的名字保存这一轮产物，例如 `NyraLogicNext.xcframework`。
不要在不清楚内容时覆盖一份正在被其他工程使用的包。

本节生成的是你自己的 `NyraLogic.xcframework`。
SDK 里可能还有 `NyraRuntime.xcframework`，后者是语言运行库，不是这个加法业务库。

## 6. 新建 Xcode 应用

1. 打开 Xcode，选择新建 iOS App。
2. 名字用 `NyraPhone`，语言用 Swift，界面用 SwiftUI。
3. 保存到 `cache/learn/ios_app/`，最终工程目录通常是 `cache/learn/ios_app/NyraPhone/`。
4. 如果你的保存位置不同，下面变量跟着修改。

```sh
export NYRA_IOS_PROJECT="$NYRA_WORK/ios_app/NyraPhone"
mkdir -p "$NYRA_IOS_PROJECT/Native/include"
cp -R "$NYRA_WORK/out/ios/NyraLogic.xcframework" "$NYRA_IOS_PROJECT/Native/"
cp "$NYRA_WORK/out/ios/include/nyra_logic.h" "$NYRA_IOS_PROJECT/Native/include/"
```

如果 `Native` 里已有旧的同名产物，先保留旧版本并明确替换这一份，避免复制出多层嵌套目录。

在 Xcode 的 App target 中，把 `Native/NyraLogic.xcframework` 加入链接库。
本例是静态库，不作为动态框架嵌入，选择 `Do Not Embed`。
不要同时再加入两份原始 `.a`，避免重复链接。

## 7. 让 Swift 看见 C 声明

新建 `Native/Bridge.h`：

```c
#include "nyra_logic.h"
```

打开 App target 的 Build Settings，设置：

- `Objective-C Bridging Header`：`$(PROJECT_DIR)/Native/Bridge.h`。
- `Header Search Paths`：保留 `$(inherited)`，再加 `$(PROJECT_DIR)/Native/include`。

这个桥接头使同一 App target 的 Swift 代码可以使用导入的 C 声明。
这里的“Objective-C”名称不表示必须把整个应用改写成 Objective-C。
[可选：Apple 的桥接头说明](https://developer.apple.com/documentation/swift/importing-objective-c-into-swift)。

不要在头文件里重新手写一个不同类型的 `nyra_add`。
修改 Nyra 接口后，重新生成并更新头文件和静态库。

## 8. 在界面显示结果

把生成工程中的 `ContentView.swift` 改成：

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Nyra 计算结果：\(nyra_add(20, 22))")
            .padding()
    }
}
```

在 Xcode 选择可用的 iPhone 模拟器，构建并运行。
学习目标是界面显示 `Nyra 计算结果：42`。
真机运行继续使用 Xcode 的开发团队、签名和设备配置流程。

这一课给出接入方法，不把文档里的预期界面当成已经完成的设备运行验收。

## 9. 想在业务库里使用标准库

要按平台变体准备依赖，不能沿用电脑的 `darwin-arm64` 库。
例如设备版的包配置形状：

```yaml
name: nyra_mobile_logic
dependencies:
  stdlib:
    precompiled: /你的SDK/targets/ios-arm64/stdlib
```

模拟器构建改用 `targets/ios-simulator-arm64/stdlib`。
不同目标最好用独立的构建包目录配置，避免同时构建时互相改写同一份配置。

静态业务库不会自动把依赖归档再套进自己里面。
检查 `cross-build` 输出的 `build.json` 中 `link_dependencies`，在最终应用链接时补齐依赖。
使用 SDK 的 `NyraRuntime.xcframework` 可提供已组织好的 kernel／stdlib／platform 运行库；
JSON、YAML 等独立包仍需各自匹配的目标产物。
不要既加入同一套运行库的 XCFramework，又把其中的原始归档再链接一遍。

对 C／Swift 的业务边界仍保持整数、指针长度、缓冲区或明确的句柄。
Nyra 的 `string` 和 `Array` 不直接当作 Swift 对象返回。

## 常见问题

- `Cannot find nyra_add in scope`：检查桥接头设置和头文件搜索路径。
- 链接时 `undefined symbol`：检查是否真的加入业务库，声明成功不等于链接成功。
- 提示构建目标是 simulator，但库是 iOS：混用了设备和模拟器库，重新选择对应变体。
- 重复符号：同一业务库或运行库被加入了多次。
- 链接缺少某个 Nyra／platform 符号：按构建记录补全对应目标的依赖，不要改用宿主库。
- 找不到模拟器：先在 Xcode 配好运行环境；这不影响前面单独构建库的学习。

## 练习

新增一个 C API `nyra_multiply`，重新生成头文件、两个库和 XCFramework。
把 Swift 页面改成显示 `nyra_multiply(6, 7)`。
目标结果仍然是 42，App 的调用路径没有改变。
