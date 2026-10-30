# 模块详解：import、export、module 与 part

[English](en/reference-modules.md) · [教程目录](README.md) · [语言字典](reference-keywords.md)

## 1. 先画边界，再分文件

包由 `package.yaml` 标识并管理依赖，一个包可以包含多个模块。
**一个 module 就是一个 TU（翻译单元）**。TU 内的多个 `part` 文件一起编译；
`import`／`export` 连接不同 TU，不合并它们的语法树。
`module Prices;` 是本 TU 的名字，不是“把整个包都放进 Prices”。
单文件模块可以不写显式名字；一旦用 `part`，主文件就必须有对应 `module`。

每个模块应有单一职责，写清拥有的数据、不变量、对外操作、排除的职责和依赖方向。
增加 `part` 文件不会减少 TU 的总代码量，也不能修复职责混杂。
不要为了“文件更短”把所有模块拼成一个大 TU；也不必给每个小辅助函数建立新模块。

## 2. 一张对照表

| 写法 | 做什么 | 不做什么 |
|---|---|---|
| `module ShopApp;` | 命名当前 TU | 不查找同名目录、不自动收集文件 |
| `part "private/discount.ny";` | 明确加入同一 TU 的文件 | 不建立独立公开边界 |
| `part of ShopApp;` | 子文件声明所属 TU，名字必须匹配 | 子文件不能再写 module/part/import/export |
| `import "prices.ny";` | 当前 TU 使用目标 TU 的公开面 | 导入者的导入者不会因此自动看见它 |
| `export "prices.ny";` | 对本 TU 的导入者重新导出目标公开面 | 不等于 C ABI／DLL 符号导出 |
| `pub` | 将本声明放进公开面 | 不会自动让整个模块所有内容公开 |
| `as prices` | 名字从 `prices.Price` 等限定入口使用 | 没有 `as` 时不能凭路径猜限定名 |
| `show Price` | 只显示列出的公开顶层名字 | 不从链接图中删除模块 |
| `hide InternalTool` | 排除列出的公开顶层名字 | 不能隐藏本来就不是公开面的名字 |

`show`／`hide` 名单不能为空，名字必须存在，不能重复；同一条指令不能混用两者。
列类型名即可，不把 `Price.Total` 这样的方法路径放进顶层筛选名单。
导入一个类型后，仍按相应成员的可见性使用操作。

## 3. 可以整套复制的五文件示例

在新的练习目录 `module-lesson/` 中创建这些文件，不要嵌在已有包根内部：

```text
module-lesson/
  package.yaml
  main.ny
  shop.ny
  prices.ny
  private/
    discount.ny
```

### `package.yaml`

```yaml
name: module_lesson
```

### `prices.ny`

```nyra
module Prices;

/** @brief A quantity and its unit price; owns pricing arithmetic only. */
pub struct Price {
  unit: int32;
}

/** @brief Calculate the undiscounted total for a quantity. */
pub method(Price) Total(quantity: int32) -> int32 {
  return self.unit * quantity;
}
```

### `shop.ny`

```nyra
module Shop;

// Stable public entry; pricing remains a separate TU.
export "prices.ny" show Price;
```

### `private/discount.ny`

```nyra
part of ShopApp;

// App-specific policy; not part of the reusable pricing API.
func discounted(total: int32, discount: int32) -> int32 {
  if discount >= total {
    return 0;
  }

  return total - discount;
}
```

### `main.ny`

```nyra
module ShopApp;
part "private/discount.ny";

import "shop.ny" as shop show Price;

func main() -> int32 {
  let price: shop.Price = shop.Price{ unit: 12 };
  let total: int32 = discounted(price.Total(4), 6);
  if total != 42 {
    return 1;
  }

  return 0;
}
```

运行（第 00 课的环境变量仍有效）：

```sh
"$NYRAC" check "$NYRA_WORK/module-lesson/main.ny"
"$NYRAC" run "$NYRA_WORK/module-lesson/main.ny" \
  --out-dir "$NYRA_WORK/out/module-lesson"
```

Windows 按起步课换为 `& $env:NYRAC` 和相应环境变量路径。
成功返回 0；总价为 `12 * 4 - 6 = 42`，程序不打印文本。

这里有三个 TU：`ShopApp`（主文件加 discount part）、`Shop`、`Prices`。
`main.ny` 只导入 `shop.ny`，通过它的 `export` 获得 `Price`。
如果把 `shop.ny` 的 `export` 改成普通 `import`，调用方不再通过该入口获得 `Price`。
折扣是应用政策，因此留在应用 TU；定价是可复用操作，因此属于 `Price` 所在 TU。

## 4. 可见性与重名

普通平铺导入让公开名字进入当前作用域；两个平铺来源提供同名顶层声明会冲突。
用别名区分它们，例如下面是**导入语法片段**，文件必须真实存在：

```nyra
import "retail.ny" as retail show Price;
import "wholesale.ny" as wholesale show Price;
```

然后用 `retail.Price` 和 `wholesale.Price`。`namespace` 只组织名字，不能代替
模块和依赖设计。没有声明 `as`，不能凭 `stdlib` 这个依赖键自动写成 `stdlib.Console`。

## 5. 跨包导入与 Git 版本

`import "json:json.ny";` 中左边是依赖键，右边是该包入口。
`package.yaml` 决定到哪里取得包；`import` 决定当前 TU 使用哪一面。
发布给别人用的依赖声明使用 Git URL 和版本 tag；精确提交放锁文件。
本地联调的 workspace/path 不是别人机器上的发布依赖地址。
完整 Git/tag/lock 例子见[包管理指南](../package-management.md)。
SDK 的 kernel/stdlib/ntest 可按对应版本的隐式 SDK 规则解析，源码仍要显式导入。
注意公开起步版本的 [Git lock 限制](../../RELEASE-1.0.3.md)。

## 6. `.ny`、`.ni` 和 `.nk` 不是三个模块关键字

| 后缀 | 用途 | 重要边界 |
|---|---|---|
| `.ny` | 普通应用／库实现 | 非 pub 辅助实现可以放这里 |
| `.ni` | 公开 API 声明、内联／泛型公开面 | 顶层声明要求 pub；普通非泛型结构体不直接公开字段布局，普通函数体需符合 inline 规则 |
| `.nk` | 内核／驱动受限模式 | 不能当成能导入 stdlib 的普通用户态程序 |

最小 `.ni` 声明片段（这不是单独可运行的程序，需要实现和链接组织）：

```nyra
pub struct Counter;

pub method(Counter) Read() -> int32;
```

仅把 `.ny` 改后缀为 `.ni` 不能隐藏已写出的布局，也不能自动生成实现。
`part` 必须由主文件明确列出；不允许直接 import 一个 `part of` 文件。
