# 18 · 变参：enable 通道、访问与转发

[English](../en/intermediate/18-variadics.md) · [上一课](17-lambda.md) · [本阶段目录](README.md) · [下一课](19-iterators.md)

## 本课目标

Nyra 的语言级变参不是随意塞入任何类型再动态识别。先写归一到 int32 的求和，再定义一个转换，最后转发已有字符串包。

## 语法与合同

`parts: ...enable<int32>` 是最后一个参数。调用传零个或多个独立值；函数内用 parts.length 与 parts[index] 读取归一后的 int32。每个源实参求值并按通道转换一次。包只在这次调用期间有效，不是可任意保存或扩容的 Array。

## 例 1：零个、一个、多个参数

[源码](../examples/intermediate/variadic-sum/main.ny) · [package.yaml](../examples/intermediate/variadic-sum/package.yaml) · [expected.txt](../examples/intermediate/variadic-sum/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func sum(parts: ...enable<int32>) -> int32 {
  var total: int32 = 0;
  for index in 0..parts.length {
    total = total + parts[index];
  }

  return total;
}

func main() -> int32 {
  Console.Println("empty={0}, one={1}, many={2}", sum(), sum(7), sum(10, 20, 12));

  return 0;
}
```

预期输出：

```text
empty=0, one=7, many=42
```

空包长度为 0，循环不执行，因此返回累计初值。没有调用处的特殊 spread 符号。

## 例 2：受约束转换，不是任意 as

[源码](../examples/intermediate/variadic-conversion/main.ny) · [package.yaml](../examples/intermediate/variadic-conversion/package.yaml) · [expected.txt](../examples/intermediate/variadic-conversion/expected.txt)

```nyra
import "stdlib:stdlib.ny";

struct Score {
  points: int32;
}

method(Score) ToInt32() -> int32 {
  return self.points;
}

func sum(parts: ...enable<int32>) -> int32 {
  var total: int32 = 0;
  for index in 0..parts.length {
    total = total + parts[index];
  }

  return total;
}

func main() -> int32 {
  let item: Score = Score{ points: 22 };
  Console.Println("total={0}", sum(20, item));

  return 0;
}
```

预期输出：

```text
total=42
```

Score 提供符合形状的实例 ToInt32。函数体看到两个 int32，不保留原始 Score 的动态类型。转换名不是任意由调用者猜测。

## 例 3：完整转发兼容的包

[源码](../examples/intermediate/variadic-forward/main.ny) · [package.yaml](../examples/intermediate/variadic-forward/package.yaml) · [expected.txt](../examples/intermediate/variadic-forward/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func log_line(format: ref string, parts: ...enable<string>) -> void {
  Console.Println(format, parts);
}

func main() -> int32 {
  log_line("value={0}, language={1}", 42, "Nyra");

  return 0;
}
```

预期输出：

```text
value=42, language=Nyra
```

将 parts 作为整个兼容变参部分转发，不写 parts...，也不在包后拼接其他参数。格式化里的整数由 string 通道归一。

## 常见错误与边界

不要写任意 ...T、混合动态类型提取或把 Array 当包展开。现有命名可选袋不能与变参包混用。包不能跨异步暂停点长期保存。C 的裸 ... 是另一种 ABI；规划中的 args<T> 不属于本课已发布语法。

## 练习

写 total_plus(base, parts)，先用 base 初始化总和，再累加变参。以 10、20、12 调用。

<details>
<summary>完整参考答案</summary>

[源码](../examples/intermediate/variadic-answer/main.ny) · [package.yaml](../examples/intermediate/variadic-answer/package.yaml) · [expected.txt](../examples/intermediate/variadic-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func total_plus(base: int32, parts: ...enable<int32>) -> int32 {
  var total: int32 = base;
  for index in 0..parts.length {
    total = total + parts[index];
  }

  return total;
}

func main() -> int32 {
  Console.Println("total={0}", total_plus(10, 20, 12));

  return 0;
}
```

预期输出：

```text
total=42
```

固定参数在前，唯一的变参在末尾。

</details>

[上一课](17-lambda.md) · [本阶段目录](README.md) · [下一课](19-iterators.md)
