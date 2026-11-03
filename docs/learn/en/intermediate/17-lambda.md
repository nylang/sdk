# 17 · Function values, lambdas and captures

[中文](../../intermediate/17-lambda.md) · [Previous](16-generics.md) · [Stage index](README.md) · [Next](18-variadics.md)

## Goals

Pass an existing function first, then a captureless lambda, then an explicit copy capture. Keep one calling contract while separating callable type from captured environment.

## Syntax and contracts

`(int32) -> int32` is a function-value type. Lambda has parameters and a result; `[copy step]` explicitly captures from its creation scope. Parameters arrive per call; captures belong to the environment. Type-specific copying/ownership still applies.

## Example 1: a named function as argument

[Source](../../examples/intermediate/function-value/main.ny) · [package.yaml](../../examples/intermediate/function-value/package.yaml) · [expected.txt](../../examples/intermediate/function-value/expected.txt)

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

Expected output:

```text
result=42
```

The caller needs a matching signature, not a hard-coded operation name. Passing add_one differs from calling add_one().

## Example 2: a captureless function

[Source](../../examples/intermediate/lambda-empty/main.ny) · [package.yaml](../../examples/intermediate/lambda-empty/package.yaml) · [expected.txt](../../examples/intermediate/lambda-empty/expected.txt)

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

Expected output:

```text
result=40
```

This lambda uses only its own parameter. Its binding name does not change the function type.

## Example 3: capture the number at creation

[Source](../../examples/intermediate/lambda-copy/main.ny) · [package.yaml](../../examples/intermediate/lambda-copy/package.yaml) · [expected.txt](../../examples/intermediate/lambda-copy/expected.txt)

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

Expected output:

```text
result=42, outer=100
```

The captured scalar remains 1 after the outer variable becomes 100. Do not infer deep cloning of arbitrary object graphs.

## Common mistakes and boundaries

Do not use bare [step]. This course uses supported copy captures, not deferred ref/ref mut/weak captures. Nyra function values differ from thin C function pointers.

## Exercise

Capture step 2 and apply twice to 38, producing 42.

<details>
<summary>Complete answer</summary>

[Source](../../examples/intermediate/lambda-answer/main.ny) · [package.yaml](../../examples/intermediate/lambda-answer/package.yaml) · [expected.txt](../../examples/intermediate/lambda-answer/expected.txt)

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

Expected output:

```text
result=42
```

The captured value is the increment, not a call parameter.

</details>

[Previous](16-generics.md) · [Stage index](README.md) · [Next](18-variadics.md)
