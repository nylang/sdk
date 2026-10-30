# 10 · 测试、分析器和日常检查

[English](en/10-tests-analyzer.md)

[上一课](09-text-files.md) · [教程目录](README.md) · [下一课](11-task-report.md)

这一课建立一个习惯：改完代码，不只看“能不能编译”，也检查“结果是不是对的”。

测试与其他属性查阅：[元数据字典及完整例子](reference-metadata.md)。

## 1. 三种检查分别做什么

- 编译器 `check`：检查语法、类型、导入和其他编译规则。
- 单元测试：运行你写的例子，比较实际结果和期望结果。
- 分析器：提供静态分析、编辑器提示和配置的风格检查。

三者互相补充。一个写错计算公式的程序可能完全能编译。

## 2. 为测试单独准备一个练习包

本节使用完整 SDK 中的 ntest 和标准库，不需要取得编译器或 stdlib 的实现源码。

在第 00 课的终端执行：

```sh
mkdir -p "$NYRA_WORK/test_playground/private"
cd "$NYRA_WORK/test_playground"

python3 - <<'PY'
from pathlib import Path
Path("package.yaml").write_text("name: lesson_tests\n", encoding="utf-8")
PY
```

这个包和 `playground` 同级，不嵌套在它里面。
SDK 内置的测试依赖由工具链识别；其他仅测试使用的生态包仍可写在 dev-dependencies 中。

## 3. 写被测试的计算

新建 `test_playground/main.ny`：

```nyra
module PriceTests;
part "private/price_selftest.ny";

import "stdlib:stdlib.ny";
import "ntest:ntest.ny";

func total_price(unit_price: int32, quantity: int32) -> int32 {
  return unit_price * quantity;
}

func main() -> int32 {
  Console.Println("总价：{0}", total_price(12, 3));
  return 0;
}
```

正常构建会去掉测试专用内容。测试依赖的导入和 `_selftest.ny` 部件按工具链的测试规则处理。

## 4. 写测试例子

新建 `test_playground/private/price_selftest.ny`：

```nyra
part of PriceTests;

@test(tag = "price")
func test_three_items() {
  AssertEqI32(total_price(12, 3), 36);
}

@test(tag = "price")
func test_empty_order() {
  AssertEqI32(total_price(12, 0), 0);
}
```

`@test` 标记可运行的测试函数。测试函数不接收参数，不返回业务结果。
`AssertEqI32` 比较两个整数；不相等时记录测试失败。

运行：

```sh
"$NYRAC" test "$NYRA_WORK/test_playground/main.ny" \
  --tag price \
  --out-dir "$NYRA_WORK/out/price-tests" \
  --report "$NYRA_WORK/out/price-tests/report.json"
```

学习目标是看到两个测试都通过。故意把 36 改成 35，再运行一次，就应该看到失败。
最后把答案改回 36。

这里只是教你运行刚写的两个测试，不需要跑整个编译器的全量回归。

## 5. 用分析器检查普通程序

回到原来的练习包：

```sh
cd "$NYRA_WORK/playground"
"$NYRA_ANALYZER" analyze "$NYRA_WORK/playground/main.ny"
```

不要直接运行不带参数的分析器并等待结果；默认模式是供编辑器使用的标准输入输出协议，会等待消息。

## 6. 自己设置风格检查

在 `playground/package.yaml` 的顶层增加一行：

```yaml
analysis-options: analysis_options.yaml
```

与 `name`、`dependencies` 同级，不要放进某个依赖条目里。

新建 `playground/analysis_options.yaml`：

```yaml
import: default

linter:
  rules:
    no-trailing-whitespace:
      severity: warning
    max-line-length:
      severity: warning
      length: 100
```

含义是先继承 SDK 默认配置，再覆盖这里写出的规则。
配置有结构校验，规则名或选项拼错会提示错误，不能靠拼错名字来关闭规则。

- 不配置 `analysis-options`：使用 SDK 默认配置。
- 配了文件且写 `import: default`：继承默认配置。
- `import` 也可以是另一个配置文件的相对路径，但一次只能导入一份。
- 配了文件但没有 `import`：只使用该文件声明的配置。

分析器不会沿父目录自动搜索一个同名文件。文件必须由包配置明确指定。

## 7. 在 VS Code 里使用

如果你已经安装或加载了 Nyra 扩展，在 VS Code 的用户设置中设置实际路径：

```json
{
  "nyra.sdkPath": "/你的路径/nyra-sdk-1.0.3-darwin-arm64",
  "nyra.compilerPath": "/你的路径/nyra-sdk-1.0.3-darwin-arm64/hosts/darwin-arm64/bin/nyrac",
  "nyra.analyzerPath": "/你的路径/nyra-sdk-1.0.3-darwin-arm64/hosts/darwin-arm64/bin/nyra-analyzer"
}
```

这里的 `/你的路径/` 必须换成真实位置，终端里的 `$NYRA_SDK` 不会自动在这个 JSON 中展开。
显式配置两个可执行文件，避免扩展默认的旧目录约定选错工具。

如果还没装扩展，可以先继续使用命令行。扩展公开仓库是
[nylang/nylang-ide-vscode](https://github.com/nylang/nylang-ide-vscode)，安装方法以其说明为准。

调试还需要安装并配置一个原生调试适配器。暂时用输出和小测试检查逻辑也完全可以。

## 练习

增加一个“单价为零”的测试，期望总价为零。

参考新增片段，放到 `price_selftest.ny`：

```nyra
@test(tag = "price")
func test_free_item() {
  AssertEqI32(total_price(0, 3), 0);
}
```
