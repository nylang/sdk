# 17 · 函数值、lambda 与捕获

[English](../en/intermediate/17-lambda.md) · [上一课](16-generics.md) · [本阶段目录](README.md) · [下一课](18-variadics.md)

## 本课目标

先把已有函数作为值传入，再写无捕获 lambda，最后显式复制捕获。每一步都保留同一个调用合同，让你分清函数类型与闭包环境。

## 语法与合同

`(int32) -> int32` 是函数值类型。lambda 后是显式参数和返回类型；捕获写 `[copy step]`。捕获的 step 与参数 value 不同：前者来自创建位置，后者来自每次调用。复制捕获仍遵守该类型自己的复制与资源规则。

## 例 1：具名函数也能作参数

[源码](../examples/intermediate/function-value/main.ny) · [package.yaml](../examples/intermediate/function-value/package.yaml) · [expected.txt](../examples/intermediate/function-value/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func add_one(value: int32) -> int32 {
  return value + 1;
}

func apply_twice(value: int32, transform: (int32) -> int32) -> int32 {
  return transform(transform(value));
}

func main() -> int32 {
  Console.Println("result={0}", apply_twice(40, add_one));

  return 0;
}
```

预期输出：

```text
result=42
```

apply_twice 不需要知道操作的名字，只需要匹配函数签名。传 add_one 不是立即调用 add_one()。

## 例 2：无捕获临时函数

[源码](../examples/intermediate/lambda-empty/main.ny) · [package.yaml](../examples/intermediate/lambda-empty/package.yaml) · [expected.txt](../examples/intermediate/lambda-empty/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func add_one(value: int32) -> int32 {
  return value + 1;
}

func apply_twice(value: int32, transform: (int32) -> int32) -> int32 {
  return transform(transform(value));
}

func main() -> int32 {
  let double: (int32) -> int32 = lambda (value: int32) -> int32 {
    return value * 2;
  };

  Console.Println("result={0}", apply_twice(10, double));

  return 0;
}
```

预期输出：

```text
result=40
```

这个 lambda 只读取自己的 value 参数，没有外部依赖。函数类型不因变量名 double 而改变。

## 例 3：复制捕获保存创建时的数字

[源码](../examples/intermediate/lambda-copy/main.ny) · [package.yaml](../examples/intermediate/lambda-copy/package.yaml) · [expected.txt](../examples/intermediate/lambda-copy/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func add_one(value: int32) -> int32 {
  return value + 1;
}

func apply_twice(value: int32, transform: (int32) -> int32) -> int32 {
  return transform(transform(value));
}

func main() -> int32 {
  var step: int32 = 1;
  let transform: (int32) -> int32 = lambda [copy step] (value: int32) -> int32 {
    return value + step;
  };
  step = 100;

  Console.Println("result={0}, outer={1}", apply_twice(40, transform), step);

  return 0;
}
```

预期输出：

```text
result=42, outer=100
```

闭包中的 step 是创建时复制的 1；后来外部 step 改成 100 不改这次整数捕获。不要从标量例子推断任意对象图都深复制。

## 常见错误与边界

不要写裸捕获 [step]。本课只使用已支持的 copy 捕获，不把 ref/ref mut/weak 捕获当成可用能力。Nyra 函数值与 C 薄函数指针 ABI 不同；跨 C 边界另查互操作课。

## 练习

把捕获的初始 step 设为 2，连续应用两次，从 38 得到 42。

<details>
<summary>完整参考答案</summary>

[源码](../examples/intermediate/lambda-answer/main.ny) · [package.yaml](../examples/intermediate/lambda-answer/package.yaml) · [expected.txt](../examples/intermediate/lambda-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func add_one(value: int32) -> int32 {
  return value + 1;
}

func apply_twice(value: int32, transform: (int32) -> int32) -> int32 {
  return transform(transform(value));
}

func main() -> int32 {
  let step: int32 = 2;
  let transform: (int32) -> int32 = lambda [copy step] (value: int32) -> int32 {
    return value + step;
  };

  Console.Println("result={0}", apply_twice(38, transform));

  return 0;
}
```

预期输出：

```text
result=42
```

捕获的是增量，不是调用参数。

</details>

[上一课](16-generics.md) · [本阶段目录](README.md) · [下一课](18-variadics.md)
