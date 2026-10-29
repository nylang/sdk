# 09 · 中文文本、文件、JSON 和 YAML

[上一课](08-generics.md) · [教程目录](README.md) · [下一课](10-tests-analyzer.md)

这一课开始和程序外面的数据打交道。仍使用第 00 课生成的配置，里面已经包含 JSON 和 YAML 包。

## 1. 逐个读取 Unicode 标量

完整程序：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let text: string = "A中";
  var offset: int32 = 0;
  while offset < text.length {
    let decoded: UtfDecodeResult = Text.DecodeUtf8(text, offset);
    if !decoded.valid {
      Console.Eprintln("无效 UTF-8，位置：{0}", offset);
      return 1;
    }
    Console.Println("位置：{0}，编码值：{1}，占用字节：{2}",
      offset, decoded.scalar, decoded.byte_len);
    offset = offset + decoded.byte_len;
  }
  return 0;
}
```

预期 `A` 在偏移 0，占 1 字节；`中` 在偏移 1，占 3 字节。
逐个解码后再增加偏移，就不会误从中文 UTF-8 字节的中间开始读取。

## 2. 和需要 UTF-16 的接口交换数据

局部片段，放进 `main`：

```nyra
let input: string = "你好，Nyra";
let units: Array<uint16>? = Text.Utf8ToUtf16(input, UtfErrorPolicy.Strict);
if units == nil {
  Console.Eprintln("输入不是有效 UTF-8");
  return 1;
}
let utf16: Array<uint16> = units as Array<uint16>;
let output: string? = Text.Utf16ToUtf8(utf16, UtfErrorPolicy.Strict);
if output == nil { return 2; }
Console.Println(output as string);
```

`Strict` 遇到无效编码就失败。`Replace` 会按接口约定替换无效部分。
UTF-8 字节偏移、UTF-16 代码单元偏移和显示位置不是同一种单位，不能直接混着用。

## 3. 写入并读取一个文件

先在终端回到练习包目录，让相对文件路径可预测：

```sh
cd "$NYRA_WORK/playground"
```

完整程序：

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let file: File = File.New("note.txt");
  let written: Result<Unit, IoError> = file.WriteAsString("第一行\n第二行\n");
  if written.IsErr() {
    Console.Eprintln("写入 note.txt 失败");
    return 1;
  }

  let loaded: Result<string, IoError> = file.ReadAsString();
  if loaded.IsErr() {
    Console.Eprintln("读取 note.txt 失败");
    return 2;
  }
  let text: string? = loaded.get_if<string>();
  if text == nil { return 3; }
  Console.WriteStdout(text as string);
  return 0;
}
```

运行后，练习目录里会有 `note.txt`，终端显示两行文字。
这个例子会写入该文件，不要改成存着重要资料的现有文件路径。

`Console.WriteStdout` 直接输出原文，不把内容中的 `{0}` 当格式占位符。
读取整份文件适合小文件；大文件应考虑分块读取和缓冲接口。

## 4. 解析 JSON

完整程序：

```nyra
import "stdlib:stdlib.ny";
import "json:json.ny";

func main() -> int32 {
  let durable: Allocator = CreateAllocator(0i64, 8i64);
  let scratch: Allocator = CreateAllocator(0i64, 8i64);
  let parsed: Result<JsonDocument, JsonError> =
    JsonDocument.Parse("{\"title\":\"学习 Nyra\",\"done\":false}", durable, scratch);
  if parsed.IsErr() {
    Console.Eprintln("JSON 格式错误");
    return 1;
  }
  let document: JsonDocument? = parsed.get_if<JsonDocument>();
  if document == nil { return 2; }
  let value: JsonDocument = document as JsonDocument;
  let text: string = JsonWriter.Emit(value.Root());
  Console.WriteStdout(text);
  Console.Println("");
  return 0;
}
```

JSON 文本里面的双引号写成 `\"`，避免结束外层 Nyra 字符串。
输出可能与输入的空白排版不同，但内容应一致。

先把两个 `Allocator` 理解成“库申请内存的入口”：

- `durable` 用于需要保留下来的文档内容。
- `scratch` 用于解析中的临时工作。

这个入门例子两者都使用普通进程堆，不自行重置内存。
第 13 课再讨论如何用不同生命周期的分配器。

## 5. 解析 YAML

完整程序：

```nyra
import "stdlib:stdlib.ny";
import "yaml:yaml.ny";

func main() -> int32 {
  let durable: Allocator = CreateAllocator(0i64, 8i64);
  let scratch: Allocator = CreateAllocator(0i64, 8i64);
  let parsed: Result<YamlDocument, YamlError> =
    YamlDocument.Parse("title: Nyra\ndone: false\n", durable, scratch);
  if parsed.IsErr() {
    Console.Eprintln("YAML 格式错误");
    return 1;
  }
  let document: YamlDocument? = parsed.get_if<YamlDocument>();
  if document == nil { return 2; }
  let value: YamlDocument = document as YamlDocument;
  Console.WriteStdout(YamlWriter.Emit(value.Root()));
  Console.Println("");
  return 0;
}
```

JSON 和 YAML 是独立的包，都需要在 `package.yaml` 中配置，不能只写一个 `import` 就假定自动下载。

公开 SDK 不自带 JSON/YAML 包。先阅读[包依赖说明](../package-management.md)，
配置独立生态包；SDK 1.0.3 的 portable Git lock 已知问题需要更正后的工具支持。
本课的生态例子不能仅凭安装基础 SDK 就假定已经可运行。

## 练习与参考结果

1. 把文件例子的内容改成三行，再读取它。
2. 把 JSON 中的 `false` 改成 `true`，观察输出。
3. 故意删掉 JSON 的右花括号，观察错误分支。

参考结果：前两项正常输出；第三项显示“JSON 格式错误”，并返回状态码 1。
重点是程序主动处理坏数据，没有继续把失败的解析结果当成文档。
