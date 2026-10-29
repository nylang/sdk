# 17: Android integration reference

[中文](../17-android.md) · [Course index](README.md) · [Previous](16-ios.md)

> Development-tooling reference: nyra.py cross-build is not included in the
> public SDK. Executing those steps requires a separately available development
> environment with NYRA_REPO pointing to it. SDK 1.0.3 supplies desktop runtimes,
> not this entire mobile workflow. The app/JNI examples explain the integration
> without claiming a runnable mobile setup from the base desktop SDK.

The host may be macOS, Windows or Linux with its matching SDK and Android NDK:

```text
Kotlin UI -> JNI wrapper in C -> Nyra static library
```

Nyra produces the logic library; Android Studio handles UI, JNI, packaging and
execution.

## 1. Prepare the tools

Start with your host's lesson 00, then obtain the compatible cross-build environment.
Install Android Studio, NDK Side by side, CMake 3.22 or newer compatible tooling,
and an emulator/platform tools or a physical device. Record the actual NDK path.

macOS/Linux:

```sh
export ANDROID_NDK_HOME="/your/AndroidSDK/ndk/actual-version"
cat "$ANDROID_NDK_HOME/source.properties"
```

PowerShell:

```powershell
$env:ANDROID_NDK_HOME = "C:/your/AndroidSDK/ndk/actual-version"
Get-Content "$env:ANDROID_NDK_HOME/source.properties"
```

Pkg.Revision identifies the NDK version. Gradle must select that same installed
version. Android API level 28 is not the same concept as NDK version 28.

## 2. Prepare the Nyra package

Reuse mobile_logic from iOS or create it now. macOS/Linux:

```sh
mkdir -p "$NYRA_WORK/mobile_logic"
mkdir -p "$NYRA_WORK/out/android/include"
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:NYRA_WORK/mobile_logic" | Out-Null
New-Item -ItemType Directory -Force "$env:NYRA_WORK/out/android/include" | Out-Null
```

package.yaml:

```yaml
name: nyra_mobile_logic
```

logic.ny:

```nyra
@extern("C", api) func nyra_add(left: int32, right: int32) -> int32 {
  return left + right;
}
```

This first call chain needs no stdlib or dynamic allocation.

## 3. Build two Android ABIs

android-arm64 maps to arm64-v8a; android-x86_64 maps to x86_64. Choose the device's
real ABI instead of copying one archive into both directories. Inspect the plan:

```sh
python3 "$NYRA_REPO/nyra.py" cross-build --target android-arm64 \
  --ndk "$ANDROID_NDK_HOME" --api 28 --plan
```

Build libraries/header on macOS/Linux:

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

Equivalent PowerShell commands:

```powershell
python "$env:NYRA_REPO/nyra.py" cross-build --target android-arm64 --ndk "$env:ANDROID_NDK_HOME" --api 28 --plan

python "$env:NYRA_REPO/nyra.py" cross-build "$env:NYRA_WORK/mobile_logic/logic.ny" --target android-arm64 --ndk "$env:ANDROID_NDK_HOME" --api 28 --compiler "$env:NYRAC" --kind static --out-dir "$env:NYRA_WORK/out/android/objects" -o "$env:NYRA_WORK/out/android/arm64-v8a/libnyra_logic.a"

python "$env:NYRA_REPO/nyra.py" cross-build "$env:NYRA_WORK/mobile_logic/logic.ny" --target android-x86_64 --ndk "$env:ANDROID_NDK_HOME" --api 28 --compiler "$env:NYRAC" --kind static --out-dir "$env:NYRA_WORK/out/android/objects" -o "$env:NYRA_WORK/out/android/x86_64/libnyra_logic.a"

& $env:NYRAC --target android --llvm-target aarch64-linux-android28 --relocation pic build "$env:NYRA_WORK/mobile_logic/logic.ny" --out-dir "$env:NYRA_WORK/out/android/header-objects" --c-header "$env:NYRA_WORK/out/android/include/nyra_logic.h"
```

This fixed-width integer header can serve both variants. Recheck layouts when
adding structs, pointer-width-dependent fields or other target-specific data.

## 4. Create the Android Studio project

Create Kotlin app NyraPhone with package com.example.nyralesson. A different
package name requires corresponding JNI symbol changes. Save it in a separate
practice project and let Gradle complete its initial sync.

macOS/Linux project-path variable:

```sh
export NYRA_ANDROID_PROJECT="$NYRA_WORK/android_app/NyraPhone"
```

PowerShell:

```powershell
$env:NYRA_ANDROID_PROJECT = "$env:NYRA_WORK/android_app/NyraPhone"
```

Keep the Android application separate from the Nyra source package.

## 5. Copy artifacts and record the NDK version

Save this helper as prepare_android.py in your practice area:

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

Run on macOS/Linux:

```sh
python3 "$NYRA_WORK/prepare_android.py"
```

PowerShell:

```powershell
python "$env:NYRA_WORK/prepare_android.py"
```

The helper copies the designated library/header and writes nyra-ndk.properties.
It does not replace the app's existing Gradle files.

## 6. Add a thin JNI layer

Create app/src/main/cpp/bridge.c:

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

Keep package, class and method names aligned with Kotlin. nyra_add is a C API,
not a JNI entry with JNIEnv/context parameters.

## 7. Configure CMake linking

Create app/src/main/cpp/CMakeLists.txt:

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

libnyra_logic.a is a prebuilt link input; libnyra_bridge.so is the JNI shared
library Android loads. IMPORTED prevents rebuilding the static input; ANDROID_ABI
selects its variant. See [Android's CMake guide](https://developer.android.com/studio/projects/configure-cmake).
Do not put the static archive in jniLibs or load it with System.loadLibrary.

## 8. Connect Gradle

Preserve generated plugins, SDK versions and dependencies. Add this import once
at the top of app/build.gradle.kts:

```kotlin
import java.util.Properties
```

After plugin declarations and before android configuration, add:

```kotlin
val nyraNdk = Properties().apply {
    rootProject.file("nyra-ndk.properties").inputStream().use { load(it) }
}
```

Merge this fragment into the existing android block:

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

Update existing ndkVersion/ndk/externalNativeBuild entries rather than adding
conflicting duplicates or leaving the template CMake path active. Android Studio
must find the NDK in its selected SDK installation; a matching number alone does
not locate an arbitrary directory. Sync Gradle after editing. See the
[native Gradle guide](https://developer.android.com/studio/projects/gradle-external-native-builds).

## 9. Call the bridge from Kotlin

Create app/src/main/java/com/example/nyralesson/NyraBridge.kt:

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

System.loadLibrary takes nyra_bridge, without the lib prefix or .so extension.
For a minimal UI independent of template differences, replace MainActivity.kt:

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

Keep the generated Manifest pointing to MainActivity. Alternatively connect
NyraBridge().add(20,22) to your existing Compose or other UI.

## 10. Build and run

Choose an ABI-matching device/emulator. The expected display is a Chinese result
label followed by 42. For a Debug APK only, run in the Android project root.

macOS/Linux:

```sh
cd "$NYRA_ANDROID_PROJECT"
./gradlew assembleDebug
```

PowerShell:

```powershell
Set-Location $env:NYRA_ANDROID_PROJECT
.\gradlew.bat assembleDebug
```

Building an APK and executing it are separate evidence. The example includes
native segment alignment for 16 KB page devices, but the complete APK and every
native dependency still need packaging/alignment checks. See [Android's page-size
guide](https://developer.android.com/guide/practices/page-sizes).

## 11. Add text, collections or JSON carefully

Kotlin/Java strings are not Nyra string shells. Some JNI text APIs use Modified
UTF-8, not ordinary UTF-8. Prefer explicit byte buffers and lengths where suitable.
Release JNI-acquired buffers according to JNI rules; do not retain them afterwards.
JNIEnv is thread-local; long-lived Java objects require valid global-reference
lifetimes. See [Android JNI guidance](https://developer.android.com/ndk/guides/jni-tips).

Development-era target runtime configuration example:

```yaml
name: nyra_mobile_logic
dependencies:
  stdlib:
    precompiled: /你的SDK/targets/android-arm64/stdlib
```

Use the actual SDK manifest and matching target artifacts rather than assuming
these historical paths exist in 1.0.3. Keep Android arm64/x86_64 configurations
and outputs separate. Preserve the cross-build link dependency receipt and add
matching kernel/stdlib/platform/ecosystem archives to CMake; group cyclic ELF
archive dependencies correctly. Never fill missing targets with host libraries.
The minimal integer example avoids these runtime dependencies initially.

## Troubleshooting

A missing nyra_bridge library usually means the APK lacks the device's .so ABI.
A missing native method points to JNI naming/signature mismatches. Missing
nyra_add points to archive linkage; wrong ELF class points to architecture.
For missing NDKs, inspect SDK Manager, properties and Gradle SDK selection.
Remove stale template JNI calls, and regenerate/copy/rebuild after Nyra changes.

## Exercise

Add nyra_multiply(6,7) through every layer: Nyra API, generated header, both ABI
archives, C JNI wrapper and Kotlin declaration. Update the UI and check the whole
chain rather than changing one layer alone.
