# 17 · 在 Android 应用里使用 Nyra

[上一课：iOS](16-ios.md) · [教程目录](README.md)


> **进阶参考范围**：本章保留开发期交叉编译与应用集成示例。文中的
> `nyra.py cross-build` 属于源码开发工具，不随公开 SDK 提供；只有另行取得
> 相应开发环境后才能执行这些命令，NYRA_REPO 也须指向该环境。
> SDK 1.0.3 是桌面发行包，不包含本章完整移动目标运行库。普通公开 SDK 用户
> 可先阅读调用链和应用代码；本章不代表已发布可直接执行的移动构建流程。

这一课的目标：在 Android 界面里显示 Nyra 计算的 42。
开发电脑可以是 macOS、Windows 或 Linux，使用对应的本机 Nyra SDK 和 NDK。

```text
Kotlin 界面 → JNI 包装层（C）→ Nyra 静态库
```

Nyra 编译器生成业务逻辑库，Android Studio 负责应用界面、JNI、APK 和设备运行。

## 1. 准备工具

先完成自己系统的第 00 课，配置 `NYRA_REPO`、`NYRA_WORK`、`NYRAC` 等变量。
本课需要支持当前交叉编译功能的新 SDK，不能直接沿用缺少新选项的旧 bootstrap seed。

另外安装 Android Studio，在 SDK Manager 的 SDK Tools 中安装：

- NDK（Side by side）。
- CMake，满足下面例子的最低版本 3.22。
- 运行时需要的 Android 模拟器／平台工具，或者准备一台支持目标 ABI 的设备。

先记录 SDK Manager 中 NDK 的真实安装位置。
NDK 是本机开发工具，与 Nyra SDK 是两个不同目录。

macOS/Linux 示例，替换路径：

```sh
export ANDROID_NDK_HOME="/你的AndroidSDK/ndk/实际版本目录"
cat "$ANDROID_NDK_HOME/source.properties"
```

PowerShell 示例：

```powershell
$env:ANDROID_NDK_HOME = "C:/你的AndroidSDK/ndk/实际版本目录"
Get-Content "$env:ANDROID_NDK_HOME/source.properties"
```

文件里的 `Pkg.Revision` 是 NDK 版本，后面让 Gradle 选择同一版本。
本例目标 API 下限是 28，不要把 `API 28` 和 `NDK 版本 28` 当作同一件事。

## 2. 准备 Nyra 代码

可以复用 iOS 课的 `mobile_logic` 包。如果没做过那一课，现在创建它。

macOS/Linux：

```sh
mkdir -p "$NYRA_WORK/mobile_logic"
mkdir -p "$NYRA_WORK/out/android/include"
```

PowerShell：

```powershell
New-Item -ItemType Directory -Force "$env:NYRA_WORK/mobile_logic" | Out-Null
New-Item -ItemType Directory -Force "$env:NYRA_WORK/out/android/include" | Out-Null
```

`mobile_logic/package.yaml`：

```yaml
name: nyra_mobile_logic
```

`mobile_logic/logic.ny`：

```nyra
@extern("C", api) func nyra_add(left: int32, right: int32) -> int32 {
  return left + right;
}
```

本例没有标准库或动态分配，只先打通最小调用链。

## 3. 编译两个 Android ABI

本课使用：

- Nyra 目标 `android-arm64` → Android 的 `arm64-v8a`。
- Nyra 目标 `android-x86_64` → Android 的 `x86_64`。

应按设备／模拟器实际架构选择。不能把同一份 `.a` 放进两个目录就算适配了两个 ABI。

macOS/Linux 先查看计划：

```sh
python3 "$NYRA_REPO/nyra.py" cross-build --target android-arm64 \
  --ndk "$ANDROID_NDK_HOME" --api 28 --plan
```

再生成库和头文件：

```sh
python3 "$NYRA_REPO/nyra.py" cross-build "$NYRA_WORK/mobile_logic/logic.ny" \
  --target android-arm64 --ndk "$ANDROID_NDK_HOME" --api 28 \
  --compiler "$NYRAC" --kind static --out-dir "$NYRA_WORK/out/android/objects" \
  -o "$NYRA_WORK/out/android/arm64-v8a/libnyra_logic.a"

python3 "$NYRA_REPO/nyra.py" cross-build "$NYRA_WORK/mobile_logic/logic.ny" \
  --target android-x86_64 --ndk "$ANDROID_NDK_HOME" --api 28 \
  --compiler "$NYRAC" --kind static --out-dir "$NYRA_WORK/out/android/objects" \
  -o "$NYRA_WORK/out/android/x86_64/libnyra_logic.a"

"$NYRAC" --target android --llvm-target aarch64-linux-android28 --relocation pic \
  build "$NYRA_WORK/mobile_logic/logic.ny" \
  --out-dir "$NYRA_WORK/out/android/header-objects" \
  --c-header "$NYRA_WORK/out/android/include/nyra_logic.h"
```

PowerShell 对应命令如下，可以直接使用，不需要自己转换多行语法：

```powershell
python "$env:NYRA_REPO/nyra.py" cross-build --target android-arm64 --ndk "$env:ANDROID_NDK_HOME" --api 28 --plan

python "$env:NYRA_REPO/nyra.py" cross-build "$env:NYRA_WORK/mobile_logic/logic.ny" --target android-arm64 --ndk "$env:ANDROID_NDK_HOME" --api 28 --compiler "$env:NYRAC" --kind static --out-dir "$env:NYRA_WORK/out/android/objects" -o "$env:NYRA_WORK/out/android/arm64-v8a/libnyra_logic.a"

python "$env:NYRA_REPO/nyra.py" cross-build "$env:NYRA_WORK/mobile_logic/logic.ny" --target android-x86_64 --ndk "$env:ANDROID_NDK_HOME" --api 28 --compiler "$env:NYRAC" --kind static --out-dir "$env:NYRA_WORK/out/android/objects" -o "$env:NYRA_WORK/out/android/x86_64/libnyra_logic.a"

& $env:NYRAC --target android --llvm-target aarch64-linux-android28 --relocation pic build "$env:NYRA_WORK/mobile_logic/logic.ny" --out-dir "$env:NYRA_WORK/out/android/header-objects" --c-header "$env:NYRA_WORK/out/android/include/nyra_logic.h"
```

这个头文件只有固定宽度整数接口，可以供这两个变体共用。
接口增加结构体、指针宽度或其他目标相关内容后，要重新核对布局，不能只凭文件名复用。

## 4. 新建 Android Studio 工程

1. 新建一个 Kotlin Android 应用，项目名用 `NyraPhone`。
2. 包名设成 `com.example.nyralesson`。如果改名，后面的 JNI 函数名也要相应修改。
3. 工程保存到 `cache/learn/android_app/NyraPhone`。
4. 先让 Android Studio 完成它自己的 Gradle 同步。

下面把该目录记录成变量。

macOS/Linux：

```sh
export NYRA_ANDROID_PROJECT="$NYRA_WORK/android_app/NyraPhone"
```

PowerShell：

```powershell
$env:NYRA_ANDROID_PROJECT = "$env:NYRA_WORK/android_app/NyraPhone"
```

这里的 Android 工程与 `mobile_logic` 包是同级的独立工程，不把 Android App 塞进 Nyra 源码包里。

## 5. 复制库，并记录实际 NDK 版本

把下面代码保存成 `cache/learn/prepare_android.py`：

```python
import os
import shutil
from pathlib import Path

project = Path(os.environ["NYRA_ANDROID_PROJECT"])
output = Path(os.environ["NYRA_WORK"]) / "out/android"
ndk = Path(os.environ["ANDROID_NDK_HOME"])
if not (project / "app").is_dir():
    raise SystemExit("先在指定位置创建 Android Studio 工程")

native = project / "app/src/main"
include = native / "cpp/include"
include.mkdir(parents=True, exist_ok=True)
shutil.copy2(output / "include/nyra_logic.h", include / "nyra_logic.h")
for abi in ("arm64-v8a", "x86_64"):
    destination = native / "nyra" / abi
    destination.mkdir(parents=True, exist_ok=True)
    shutil.copy2(output / abi / "libnyra_logic.a", destination / "libnyra_logic.a")

properties = (ndk / "source.properties").read_text(encoding="utf-8")
revision = next(line.split("=", 1)[1].strip() for line in properties.splitlines()
                if line.strip().startswith("Pkg.Revision"))
(project / "nyra-ndk.properties").write_text("ndkVersion=" + revision + "\n", encoding="utf-8")
print("已复制两个 ABI 的库；NDK 版本：" + revision)
```

macOS/Linux：

```sh
python3 "$NYRA_WORK/prepare_android.py"
```

PowerShell：

```powershell
python "$env:NYRA_WORK/prepare_android.py"
```

脚本只更新本课指定的业务库、头文件和 `nyra-ndk.properties`。
它不覆盖 Android 工程已有的 Gradle 文件。

## 6. 写很薄的一层 JNI

新建 `app/src/main/cpp/bridge.c`：

```c
#include <jni.h>
#include "nyra_logic.h"

JNIEXPORT jint JNICALL
Java_com_example_nyralesson_NyraBridge_add(
        JNIEnv *env, jobject instance, jint left, jint right) {
    (void)env;
    (void)instance;
    return (jint)nyra_add((int32_t)left, (int32_t)right);
}
```

这层只负责把 Java／Kotlin 的整数交给 C API。
JNI 函数名中的包名、类名、方法名必须与 Kotlin 一致。
`nyra_add` 本身不是 JNI 入口，不能直接拿它替代带有 `JNIEnv` 等参数的 JNI 函数。

## 7. 告诉 CMake 怎样链接

新建 `app/src/main/cpp/CMakeLists.txt`：

```cmake
cmake_minimum_required(VERSION 3.22)
project(nyra_bridge C)

add_library(nyra_logic STATIC IMPORTED)
set_target_properties(nyra_logic PROPERTIES
    IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/../nyra/${ANDROID_ABI}/libnyra_logic.a"
)

add_library(nyra_bridge SHARED bridge.c)
target_include_directories(nyra_bridge PRIVATE
    "${CMAKE_CURRENT_LIST_DIR}/include"
)
target_link_libraries(nyra_bridge PRIVATE nyra_logic)
target_link_options(nyra_bridge PRIVATE
    "-Wl,-z,max-page-size=16384"
    "-Wl,-z,defs"
)
```

这里产生两个不同的角色：

- `libnyra_logic.a`：已经编好的 Nyra 业务逻辑，被静态链接进去。
- `libnyra_bridge.so`：Android 最终加载的 JNI 共享库。

`IMPORTED` 告诉 CMake 不要重新编译那份预制静态库，`ANDROID_ABI` 用来选择正确的变体。
这是 Android CMake 的常规预制库接入方式。
[可选：Android 的 CMake 接入说明](https://developer.android.com/studio/projects/configure-cmake)。

这份 `.a` 不放进 `jniLibs`，也不通过 `System.loadLibrary` 加载。
它是 `.so` 的链接输入。

## 8. 连接到 Gradle

打开 App 模块的 `app/build.gradle.kts`，保留原来生成的插件、SDK 版本和依赖配置。
在文件最上面增加导入（已有同一导入时不用重复）：

```kotlin
import java.util.Properties
```

再在顶层插件声明之后、`android` 配置之前增加：

```kotlin
val nyraNdk = Properties().apply {
    rootProject.file("nyra-ndk.properties").inputStream().use { load(it) }
}
```

把下面内容合并进原有 `android { ... }`，不要无意复制第二套相互冲突的配置：

```kotlin
android {
    ndkVersion = nyraNdk.getProperty("ndkVersion")

    defaultConfig {
        minSdk = 28
        ndk {
            abiFilters.clear()
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
        }
    }
}
```

如果原来已有 `ndkVersion`、`ndk` 或 `externalNativeBuild`，编辑现有项，不要让旧配置继续指向模板自带的另一套 CMake 文件。
NDK 要同时安装在 Android Studio 使用的 Android SDK 中；版本号相同并不意味着 IDE 一定能找到任意外部目录。

Gradle 通过 CMake 构建并打包共享库；修改后进行 Gradle Sync。
[可选：Android 的 Gradle 原生构建说明](https://developer.android.com/studio/projects/gradle-external-native-builds)。

## 9. Kotlin 调用桥接类

新建 `app/src/main/java/com/example/nyralesson/NyraBridge.kt`：

```kotlin
package com.example.nyralesson

class NyraBridge {
    external fun add(left: Int, right: Int): Int

    companion object {
        init {
            System.loadLibrary("nyra_bridge")
        }
    }
}
```

`System.loadLibrary` 只写 `nyra_bridge`，不加 `lib` 前缀和 `.so` 后缀。
这里加载的是 JNI 共享库，不是静态库。

为了先避开不同 UI 模板的区别，可以把同包的 `MainActivity.kt` 临时改成最简单的：

```kotlin
package com.example.nyralesson

import android.app.Activity
import android.os.Bundle
import android.widget.TextView

class MainActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val result = NyraBridge().add(20, 22)
        setContentView(TextView(this).apply {
            text = "Nyra 计算结果：$result"
            textSize = 24f
            setPadding(32, 96, 32, 32)
        })
    }
}
```

保留生成工程中的 Manifest 入口，并确保它仍然指向这个 `MainActivity`。
你也可以只把 `NyraBridge().add(20, 22)` 接到现有 Compose 或其他界面里。

## 10. 运行和检查

在 Android Studio 选择架构匹配的设备／模拟器，构建并运行。
学习目标是看到 `Nyra 计算结果：42`。

如果只想构建 Debug APK，在项目根目录使用：

macOS/Linux：

```sh
cd "$NYRA_ANDROID_PROJECT"
./gradlew assembleDebug
```

PowerShell：

```powershell
Set-Location $env:NYRA_ANDROID_PROJECT
.\gradlew.bat assembleDebug
```

构建 APK 和设备运行是两个步骤。设备不可用时，前面的库、JNI 和 APK 构建仍然可以单独学习，
但不能因此宣称已经验证手机运行行为。

Android 也存在 16 KB 内存页设备；本例给 JNI 库设置了相应的链接段对齐参数。
最终 APK 还要检查所有原生依赖和打包对齐，不能只检查自己写的这一份库。
[可选：Android 的 16 KB 页面说明](https://developer.android.com/guide/practices/page-sizes)。

## 11. 以后增加文字、容器或 JSON

先保持 JNI 薄，业务逻辑仍放 Nyra：

- Kotlin／Java 字符串不是 Nyra `string`，不能直接强转地址。
- JNI 的部分字符串接口使用 Modified UTF-8，不能不加检查就当普通 UTF-8 字节流。
- UTF-8 数据可以在边界明确采用字节数组和字节长度，再在各自语言中转换。
- JNI 获取的数组或字符串内存，要按 JNI 约定释放；不要保存到释放之后。
- `JNIEnv` 属于当前线程，不跨线程复用；需要长期保存 Java 对象时，还要遵守全局引用的生命周期。

这些边界规则比把整个 VM 对象传进业务层更容易维护。
[可选：Android 的 JNI 使用说明](https://developer.android.com/ndk/guides/jni-tips)。

使用 Nyra 标准库时，把 Nyra 包依赖指向对应目标的预编译目录：

```yaml
name: nyra_mobile_logic
dependencies:
  stdlib:
    precompiled: /你的SDK/targets/android-arm64/stdlib
```

x86_64 变体改用 `android-x86_64`。这两个目标的包配置和输出要分开。
按 `cross-build` 的 `build.json` 保留最终链接依赖；静态业务库不自动吞并其他归档。
在 CMake 中补入匹配的 kernel／stdlib／platform 以及实际用到的独立包，
ELF 归档有循环引用时需要正确分组。不要把宿主 Linux 或 Windows 的库拿来填缺口。

当前最小例子不需要这些运行库，所以可以先把加法链路跑通，再逐步加依赖。

## 常见问题

- `UnsatisfiedLinkError` 且找不到 `nyra_bridge`：检查 APK 是否包含当前设备 ABI 对应的 `.so`。
- 找不到 native `add` 方法：检查 Kotlin 包名、类名、方法名与 JNI 符号。
- 链接缺少 `nyra_add`：检查静态库是否加入 CMake，且实际包含生成的 C API。
- `wrong ELF class` 或架构错误：混用了不同 ABI 的库。
- NDK 版本找不到：检查 SDK Manager 的安装位置、`nyra-ndk.properties` 和 Gradle 使用的 SDK。
- 模板里的旧 JNI 函数仍被引用：清理对应模板调用，确认只使用本课配置的 CMake 输入。
- 修改 Nyra 代码后结果没变：重新生成库、运行复制脚本，再重新构建 Android 工程。

## 练习

新增 `nyra_multiply(6, 7)`，依次更新：Nyra 接口、头文件、两个 ABI 的库、JNI 包装函数和 Kotlin 声明。
然后在界面显示它的结果。
每次修改接口，都沿调用链逐层检查，避免只更新其中一层。
