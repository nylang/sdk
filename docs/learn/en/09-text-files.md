# 09: Unicode, files, JSON and YAML

[中文](../09-text-files.md) · [Course index](README.md) · [Previous](08-generics.md) · [Next](10-tests-analyzer.md)

Start exchanging data outside the program. File/text examples use SDK facilities;
JSON and YAML need separately configured ecosystem packages. Lesson 00 does not
install those packages. Read the [dependency guide](../../package-management.en.md)
and the [1.0.3 lock limitation](../../../RELEASE-1.0.3.md) before ecosystem examples.

## 1. Decode Unicode scalars

Complete program:

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

A is at byte zero and occupies one byte; the Chinese character is at byte one
and occupies three. Advance by the decoded width rather than starting inside
its multibyte UTF-8 representation.

## 2. Exchange UTF-16 data

Fragment in main:

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

Strict reports invalid encoding; Replace follows the API's replacement policy.
UTF-8 byte offsets, UTF-16 code units and display positions are different units.

## 3. Write and read a file

Return to the practice directory so relative paths are predictable:

```sh
cd "$NYRA_WORK/playground"
```

Complete program:

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

It creates note.txt and prints two lines. Keep the example path separate from
important existing data. WriteStdout emits literal content rather than treating
its braces as format placeholders. Whole-file reads suit small files; large
inputs may require buffered/chunked I/O.

## 4. Parse JSON

Complete program, after configuring the json package:

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

The JSON quotes are escaped inside a Nyra string. Emitted whitespace may differ
while the data remains equivalent. durable and scratch are allocator entry
points for retained document data and temporary parsing work respectively.
This example uses the process heap for both; lesson 13 explains shorter lifetimes.

## 5. Parse YAML

Complete program, after configuring the yaml package:

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

An import does not fetch a dependency. These packages are not bundled libraries,
and their version-specific requirements must be satisfied before compilation.
The frozen 1.0.3 Git-lock issue needs corrected tools; do not infer compatibility
for every ecosystem package from installing the base SDK.

## Exercises

Write/read three lines instead of two, change the JSON false to true, then remove
its closing brace. The malformed case should take the error branch and return
status 1, rather than treating a failed parse as a document.
