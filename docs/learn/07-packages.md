# 07 · 多文件、包和 TU

[上一课](06-errors.md) · [教程目录](README.md) · [下一课](08-generics.md)

程序变长后，不要把所有内容堆进 `main.ny`。这一课先把一个程序分成三个文件，再看包之间如何引用。

## 1. 先分清三个名字

- 文件：磁盘上的 `main.ny`、`prices.ny` 等。
- 模块，也称 TU：一起处理的一份编译单元，有自己的公开边界。
- 包：由 `package.yaml` 标识，管理依赖和目录组织，可以包含多个模块。

可以把包想成一个项目文件夹，把模块想成里面相对独立的功能单元。
一个模块可以只有一个文件，也可以由主文件和几个 `part` 文件组成。

## 2. 第一次拆分：导入另一个模块

在 `playground` 新建 `prices.ny`，完整内容是：

```nyra
pub func PriceFor(quantity: int32) -> int32 {
  return quantity * 12;
}
```

把 `main.ny` 替换成：

```nyra
import "stdlib:stdlib.ny";
import "prices.ny";

func main() -> int32 {
  Console.Println("总价：{0}", PriceFor(3));
  return 0;
}
```

目录现在是：

```text
playground/
  package.yaml
  main.ny
  prices.ny
```

仍然编译 `main.ny`：

```sh
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/lesson07"
```

预期总价 36。`pub` 让其他模块可以使用这个函数。
如果去掉 `pub`，它就不是给导入者使用的公开入口。

`import` 引用一个模块，不会把两个文件强行合并成同一个模块。

## 3. 第二次拆分：同一个模块的 `part`

把主文件改成下面的完整程序：

```nyra
module ShopApp;
part "private/helpers.ny";

import "stdlib:stdlib.ny";
import "prices.ny";

func main() -> int32 {
  let total: int32 = PriceFor(3);
  Console.Println("优惠后：{0}", apply_discount(total, 6));
  return 0;
}
```

创建子目录：

```sh
mkdir -p "$NYRA_WORK/playground/private"
```

新建 `private/helpers.ny`：

```nyra
part of ShopApp;

func apply_discount(total: int32, discount: int32) -> int32 {
  return total - discount;
}
```

再次运行 `main.ny`，预期优惠后是 30。

这里 `main.ny` 和 `private/helpers.ny` 属于同一个 `ShopApp` 模块，
所以辅助函数不用为了主文件而加 `pub`。
`prices.ny` 仍是另一个模块，它用 `pub` 提供 `PriceFor`。

`part of` 文件里不写新的 `import`、`export`、`module` 或 `part`。
需要导入的依赖统一放在模块主文件。

## 4. `export` 和 `import` 的区别

假设库里有个入口文件 `shop.ny`，局部组织示例：

```nyra
export "prices.ny";
```

这表示导入 `shop.ny` 的人也可以看见 `prices.ny` 的公开内容。
它叫重新导出，不是把两个模块合并。

库的使用者最好只知道少量稳定入口，不应该依赖作者内部文件的布局。

## 5. 一个包引用另一个包

新版编译器会自动寻找 SDK 中的 `stdlib`、`kernel`、`ntest`，使用它们不必在
`package.yaml` 中写路径。例如只使用标准库的小程序可以这样写：

```yaml
name: hello
```

源码仍然需要导入：

```nyra
import "stdlib:stdlib.ny";
```

编译器和分析器根据自己的安装位置查找 SDK。开发时如果单独运行新编译器，
可以用环境变量 `NYRA_SDK_ROOT` 指向完整 SDK 目录。
交叉编译时会选择对应目标平台的库；缺少目标库会报错。
如果你显式配置了同名依赖，编译器使用你的配置。
`json`、`yaml` 等生态包仍需要在 `dependencies` 中声明。

SDK 1.0.2 和 1.0.3 支持这项隐式 SDK 依赖查找；更旧的 SDK 需要自己的显式配置。
Git 依赖还要核对 [1.0.3 的已知 lock 限制](../../RELEASE-1.0.3.md)。

先看独立目录结构示例，不要直接在已有 `playground` 下再建一个包：

```text
workspace/
  app/
    package.yaml
    main.ny
    private/
  price_library/
    package.yaml
    price_library.ny
    interface/
    public/
    private/
```

两个包是同级目录。一个包的内部不再套另一个 `package.yaml`。
`app/package.yaml` 中的依赖片段是：

```yaml
dependencies:
  price_library:
    path: ../price_library
```

这段需要和已有依赖合并，不能在同一个 YAML 文件里重复写两个 `dependencies`。

`price_library/package.yaml`：

```yaml
name: price_library
```

`price_library/price_library.ny`：

```nyra
pub func PriceFor(quantity: int32) -> int32 {
  return quantity * 12;
}
```

应用中就可以写：

```nyra
import "price_library:price_library.ny";
```

冒号左边是依赖键，右边是包内的入口路径。
前面几课的 `stdlib:stdlib.ny` 也是同样的形式。

## 6. 哪些文件放哪里

小应用先保持简单：

```text
my_app/
  package.yaml
  main.ny
  private/
    helpers.ny
```

可复用库需要稳定公开入口时，再引入：

- `.ni`：公开声明和接口，让使用者知道能调用什么。
- `public/`：需要随使用者一起实例化的公开模板等代码。
- `private/`：内部实现。
- 包根入口：组织公开导出和实现的链接关系。

不要为了“看起来完整”给每个小程序创建一堆空目录。
`package.yaml` 管依赖，不需要逐项列出所有模块或 TU。

## 常见错误

- `part of ShopApp` 和主文件的 `module ShopApp` 名字不一致。
- 在 `part of` 文件里写 `import`。
- 使用另一个模块的非 `pub` 函数。
- 把 `export` 理解成合并源码。
- 为了放示例，在源码包内部再嵌套一个独立包。

## 练习

把 `prices.ny` 的单价改成 15，主文件仍买 3 件、优惠 6 元。

参考结果：输出 39。你只需要改价格模块，不需要改 `apply_discount`。


## 1.0.3 源码候选版：本地包和发布入口

1.0.3 新增原生 `nyra` 包管理工具；`nyrac` 继续负责编译。已发布的旧 SDK
不会因源码更新自动获得这些功能。SDK 自带的 stdlib 仍然可以直接导入。

多个本地包可以在共同上级目录的 `workspace.yaml` 中登记 `包名: 包的 package.yaml 路径`，
依赖方使用 `workspace: true`；不需要先公开仓库。已有 Git/registry 来源的依赖也能
使用工作区中的本地副本，发布声明保留原来的来源。发布前执行 `nyra pack --check`；
外部本地依赖需要明确打包，不能把自己的绝对路径交给使用者。

完整配置、锁文件和多平台预编译包示例见[包管理操作指南](../package-management.md)。
