# 10: Tests, the analyzer and everyday checks

[中文](../10-tests-analyzer.md) · [Course index](README.md) · [Previous](09-text-files.md) · [Next](11-task-report.md)

Compilation answers whether the program is legal, not whether its calculation
is correct. Build a habit of checking both.

## 1. Three complementary checks

Compiler check validates syntax/types/imports. Unit tests compare actual behavior
with expectations. The analyzer supplies diagnostics, editor services and enabled
style checks. A wrong formula can still pass compilation.

## 2. Create a separate test package

Use the complete SDK's ntest and stdlib, without private implementation sources:

```sh
mkdir -p "$NYRA_WORK/test_playground/private"
cd "$NYRA_WORK/test_playground"

python3 - <<'PY'
from pathlib import Path
Path("package.yaml").write_text("name: lesson_tests\n", encoding="utf-8")
PY
```

This package is a sibling of playground. SDK test dependencies are discovered
by the toolchain; other test-only packages can use dev-dependencies.

## 3. Define the calculation

Create `test_playground/main.ny`:

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

Normal builds exclude test-only functions; imports and selftest parts follow the
toolchain's test-loading rules.

## 4. Add unit tests

Create `private/price_selftest.ny`:

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

A test function has no arguments or business return value. AssertEqI32 records
failure when the two integers differ. Run:

```sh
"$NYRAC" test "$NYRA_WORK/test_playground/main.ny" \
  --tag price \
  --out-dir "$NYRA_WORK/out/price-tests" \
  --report "$NYRA_WORK/out/price-tests/report.json"
```

Expect two passing tests. Change 36 to 35 to observe a failure, then restore it.
This exercises your package; it does not require the compiler's full regression
suite.

## 5. Run the analyzer explicitly

Return to the ordinary practice package:

```sh
cd "$NYRA_WORK/playground"
"$NYRA_ANALYZER" analyze "$NYRA_WORK/playground/main.ny"
```

An analyzer invoked without a command may wait for editor protocol messages on
standard I/O. Use analyze for the batch check shown here.

## 6. Configure style checks

Add this top-level entry to playground/package.yaml:

```yaml
analysis-options: analysis_options.yaml
```

Place it alongside name/dependencies, not inside a dependency. Create
analysis_options.yaml:

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

This imports defaults and overrides named rules. Invalid rule/option names are
configuration errors, not a way to turn checks off. Without analysis-options,
SDK defaults apply. With a file, import:default inherits defaults; one relative
configuration import is also possible. A file without import uses only its own
rules. The analyzer does not search parent directories for an unregistered file.

## 7. Configure VS Code

Set actual paths in user settings:

```json
{
  "nyra.sdkPath": "/your/path/nyra-sdk-1.0.3-darwin-arm64",
  "nyra.compilerPath": "/your/path/nyra-sdk-1.0.3-darwin-arm64/hosts/darwin-arm64/bin/nyrac",
  "nyra.analyzerPath": "/your/path/nyra-sdk-1.0.3-darwin-arm64/hosts/darwin-arm64/bin/nyra-analyzer"
}
```

Replace the placeholder path; shell variables are not expanded automatically in
this JSON. The [public extension repository](https://github.com/nylang/nylang-ide-vscode)
provides installation instructions. Debugging also needs an appropriate native
debug adapter; output and unit tests remain useful without one.

## Exercise

Add a zero-unit-price test to price_selftest.ny:

```nyra
@test(tag = "price")
func test_free_item() {
  AssertEqI32(total_price(0, 3), 0);
}
```
