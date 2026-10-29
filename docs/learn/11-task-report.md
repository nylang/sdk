# 11 · 综合练习：任务清单统计器

[上一课](10-tests-analyzer.md) · [教程目录](README.md) · [下一课](12-concurrency.md)

现在把前面学过的知识连起来：读取一个文件，解析每行，统计完成情况，生成报告。
先完成一个单文件版本，理解后再拆分。

## 1. 这次要做出什么

输入文件 `tasks.txt`：

```text
done: 学会变量
todo: 学会所有权
done: 跑通文件读写
```

约定每行用 `done:` 或 `todo:` 开头，空行忽略。
输出应包括：

```text
任务总数：3
已完成：2
待完成：1
```

同时把同样的报告保存成 `report.txt`。

## 2. 先准备输入

回到最早的练习包：

```sh
cd "$NYRA_WORK/playground"
```

用编辑器在这个目录新建 `tasks.txt`，复制上面的三行任务。
如果最后一行没有换行，程序也应能处理。

## 3. 完整程序

替换 `playground/main.ny`：

```nyra
import "stdlib:stdlib.ny";

struct TaskCounts {
  done: int32;
  todo: int32;
  invalid: int32;
}

func count_line(line: ref string, counts: ref mut TaskCounts) -> void {
  let text: string = line.Trim();
  if text.length == 0 { return; }
  if text.StartsWith("done:") {
    counts.done = counts.done + 1;
  } else if text.StartsWith("todo:") {
    counts.todo = counts.todo + 1;
  } else {
    counts.invalid = counts.invalid + 1;
  }
}

func count_tasks(source: ref string) -> TaskCounts {
  var counts: TaskCounts = TaskCounts { done: 0, todo: 0, invalid: 0 };
  var start: int32 = 0;
  var index: int32 = 0;
  while index < source.length {
    if source[index] == '\n' {
      let line: string = source.View(start, index - start);
      count_line(line, counts);
      start = index + 1;
    }
    index = index + 1;
  }
  if start < source.length {
    let line: string = source.View(start, source.length - start);
    count_line(line, counts);
  }
  return counts;
}

func make_report(counts: ref TaskCounts) -> string {
  var buffer: StringBuffer = StringBuffer.NewWithCapacity(128);
  buffer.Append(string.Format("任务总数：{0}\n", counts.done + counts.todo));
  buffer.Append(string.Format("已完成：{0}\n", counts.done));
  buffer.Append(string.Format("待完成：{0}\n", counts.todo));
  buffer.Append(string.Format("无法识别的行：{0}\n", counts.invalid));
  return buffer.Take();
}

func main() -> int32 {
  let loaded: Result<string, IoError> = File.New("tasks.txt").ReadAsString();
  if loaded.IsErr() {
    Console.Eprintln("无法读取 tasks.txt，请检查当前目录和文件名");
    return 1;
  }
  let source: string? = loaded.get_if<string>();
  if source == nil { return 2; }
  let text: string = source as string;
  if !Text.IsValidUtf8(text) {
    Console.Eprintln("tasks.txt 需要使用有效 UTF-8 编码");
    return 3;
  }

  let counts: TaskCounts = count_tasks(text);
  let report: string = make_report(counts);
  Console.WriteStdout(report);
  let written: Result<Unit, IoError> = File.New("report.txt").WriteAsString(report);
  if written.IsErr() {
    Console.Eprintln("报告已经显示，但写入 report.txt 失败");
    return 4;
  }
  return 0;
}
```

运行：

```sh
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/task-report"
```

这个程序会写入当前练习目录的 `report.txt`。
正常示例的最后一行报告为 `无法识别的行：0`。

## 4. 一步一步读懂它

1. `File.ReadAsString()` 读整份输入，并检查失败。
2. `Text.IsValidUtf8()` 检查文字编码。
3. `count_tasks` 扫描换行字节，把每行作为原文的视图传下去。
4. `count_line` 只判断行首标记，不复制整行内容。
5. `TaskCounts` 保存数字，不保留输入的切片。
6. `StringBuffer` 累积输出，最后 `Take()` 得到完整报告。

这里按字节寻找 ASCII 换行符是可以的。它没有把任意字节下标当成一个完整汉字。
Windows 风格的 `\r\n` 行尾也会经过 `Trim()` 去掉两端空白。

## 5. 手动检查边界情况

每次只改一项，再运行：

- 文件为空：各项计数为零。
- 只有 `done: 一件事` 且末尾没有换行：已完成为 1。
- 中间加空行：不增加任务数量。
- 加一行 `later: 以后再说`：无法识别的行为 1。
- 把 `tasks.txt` 改名：应走读取失败分支。

当前小工具只按前缀分类，`done:` 后面为空也会计数。
这是本课明确采用的简化规则，不是一个已经验证标题、日期和所有格式的任务管理器。

## 6. 下一次改进怎么做

按顺序挑战：

1. 检查冒号后面的任务标题不能为空。
2. 增加 `doing:` 分类。
3. 把计数函数搬到独立的 `counts.ny`，只公开需要的入口。
4. 给纯计数逻辑写小测试，文件读取仍放在入口处理。
5. 用第 09 课的 `JsonWriter` 输出机器可读报告。

第 1 项的思路：先取出 `done:` 或 `todo:` 后面的视图，`Trim()` 后检查 `length`。
不要在每个分支重新读取整份文件。

做到这里，你已经完成了一个包含输入、处理、输出、错误路径的小程序。
