# 16: iOS integration reference

[中文](../16-ios.md) · [Course index](README.md) · [Previous](15-c-interop.md) · [Next](17-android.md)

> Development-tooling reference: the nyra.py cross-build commands below belong
> to a separate source development environment, not the public SDK. NYRA_REPO
> must point to that environment if you have it. SDK 1.0.3 is desktop-only and
> does not provide this complete mobile build workflow or target runtime set.
> Read the integration model without assuming these commands run after lesson 00.

Use Swift for the UI and a small Nyra library for logic connected through C:

```text
Swift UI -> C declarations -> Nyra static library
```

The compiler is not installed on the phone, and this does not implement UIKit
or SwiftUI directly in Nyra.

## 1. Prepare a matching mobile toolchain

Use an Apple-silicon Mac, full Xcode with device/simulator SDKs, and an actual
compatible Nyra development SDK/tool environment. Later choose a simulator or
configure device signing. The desktop setup alone is not that environment.

```sh
export NYRA_SDK="/your/path/current-Nyra-SDK"
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

If xcrun selects only Command Line Tools, select full Xcode's tools in Xcode
settings. Do not substitute the macOS SDK for a missing iOS SDK.

## 2. Create reusable logic

```sh
mkdir -p "$NYRA_WORK/mobile_logic"
mkdir -p "$NYRA_WORK/out/ios/include"
```

Create mobile_logic/package.yaml:

```yaml
name: nyra_mobile_logic
```

Create mobile_logic/logic.ny:

```nyra
@extern("C", api) func nyra_add(left: int32, right: int32) -> int32 {
  return left + right;
}
```

The integer-only example avoids stdlib/mobile runtime dependencies initially.
Add correctly targeted libraries when introducing text, containers or JSON.

## 3. Generate the C header

```sh
"$NYRAC" --target ios --llvm-target arm64-apple-ios15.0 --relocation pic \
  build "$NYRA_WORK/mobile_logic/logic.ny" \
  --out-dir "$NYRA_WORK/out/ios/header-objects" \
  --c-header "$NYRA_WORK/out/ios/include/nyra_logic.h"
```

This produces declarations/objects, not an independently launchable iOS app.

## 4. Build device and simulator variants

Inspect the development-tool plan first:

```sh
python3 "$NYRA_REPO/nyra.py" cross-build --target ios-arm64 --minimum 15.0 --plan
```

Then build two static libraries:

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

Device arm64 and simulator arm64 are different platform variants. This simulator
example targets Apple-silicon Macs, not an Intel simulator. The minimum 15.0
deployment version must also be respected by the app project.

## 5. Assemble an XCFramework

```sh
xcodebuild -create-xcframework \
  -library "$NYRA_WORK/out/ios/device/libnyra_logic.a" \
  -headers "$NYRA_WORK/out/ios/include" \
  -library "$NYRA_WORK/out/ios/simulator/libnyra_logic.a" \
  -headers "$NYRA_WORK/out/ios/include" \
  -output "$NYRA_WORK/out/ios/NyraLogic.xcframework"
```

Xcode selects the correct variant from the framework. Do not merge device and
simulator objects into one ordinary archive. See [Apple's XCFramework guide](https://help.apple.com/xcode/mac/current/en.lproj/dev6f6ac218b.html).
Choose a fresh output name if an existing package is still in use. This is your
business-logic framework, distinct from any SDK NyraRuntime framework.

## 6. Create the Xcode app

Create an iOS App named NyraPhone, with Swift/SwiftUI. Save it in your practice
area, then set its actual path and copy the outputs:

```sh
export NYRA_IOS_PROJECT="$NYRA_WORK/ios_app/NyraPhone"
mkdir -p "$NYRA_IOS_PROJECT/Native/include"
cp -R "$NYRA_WORK/out/ios/NyraLogic.xcframework" "$NYRA_IOS_PROJECT/Native/"
cp "$NYRA_WORK/out/ios/include/nyra_logic.h" "$NYRA_IOS_PROJECT/Native/include/"
```

Avoid nesting a second copy into an existing framework. Add Native/NyraLogic.xcframework
to the App target's linked libraries, selecting **Do Not Embed** for this static
example. Do not also link the two original archives.

## 7. Make C declarations visible to Swift

Create Native/Bridge.h:

```c
#include "nyra_logic.h"
```

Set Objective-C Bridging Header to `$(PROJECT_DIR)/Native/Bridge.h` and preserve
inherited Header Search Paths while adding `$(PROJECT_DIR)/Native/include`.
This exposes C declarations within the App target; it does not require rewriting
the app in Objective-C. See [Apple's interoperability guide](https://developer.apple.com/documentation/swift/importing-objective-c-into-swift).
Regenerate the header/library after changing the Nyra API.

## 8. Display the result

Replace ContentView.swift:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Nyra 计算结果：\(nyra_add(20, 22))")
            .padding()
    }
}
```

Select an available iPhone simulator and run. The example UI displays a Chinese
label followed by 42. Device execution additionally uses Xcode's team/signing
setup. Expected UI output is a learning target, not a device acceptance record.

## 9. Add standard-library dependencies later

Use the correct runtime variant, never desktop darwin-arm64 libraries. This is
the development-era device-package configuration shape:

```yaml
name: nyra_mobile_logic
dependencies:
  stdlib:
    precompiled: /你的SDK/targets/ios-arm64/stdlib
```

A simulator build requires its own matching target package. The historical
paths above are not the SDK 1.0.3 public layout. Keep separate build configurations
instead of concurrently editing one manifest. Static logic archives do not
absorb every dependency: preserve link_dependencies from the cross-build receipt
and supply them at the final link. If using a runtime XCFramework, do not link
its component archives a second time. JSON/YAML need their own target artifacts.
Keep C/Swift boundaries to scalars, pointer/length pairs, buffers or clear handles.

## Troubleshooting

Check bridging/header paths for missing declarations, actual archive linkage for
undefined symbols, and device/simulator variants for platform mismatch. Duplicate
symbols often mean duplicated business/runtime linkage. Missing platform symbols
need matching target dependencies, not host libraries. Missing simulator setup
is an Xcode environment issue, separate from building the library.

## Exercise

Add nyra_multiply, regenerate the header, both archives and the XCFramework,
then display nyra_multiply(6,7) from Swift. Keep the complete call chain coherent.
