# 11: Project: a task report

[中文](../11-task-report.md) · [Course index](README.md) · [Previous](10-tests-analyzer.md) · [Next](12-concurrency.md)

Combine file input, line parsing, counting and report output. Begin in one file,
then extract responsibilities once you understand the behavior.

## 1. Define the input and result

Create tasks.txt containing:

```text
done: 学会变量
todo: 学会所有权
done: 跑通文件读写
```

Each nonblank line starts with done: or todo:. Expected report:

```text
任务总数：3
已完成：2
待完成：1
```

Save the same report in report.txt as well as printing it.

## 2. Prepare the input directory

```sh
cd "$NYRA_WORK/playground"
```

Create tasks.txt there with the editor. The last line need not end in a newline.

## 3. Complete program

Replace playground/main.ny:

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

Run:

```sh
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/task-report"
```

This writes report.txt in the practice directory. The valid sample reports zero
unrecognized lines in its final line.

## 4. Trace the responsibilities

ReadAsString checks input failure. Text.IsValidUtf8 validates encoding.
count_tasks finds newline bytes; count_line receives a view and examines the
prefix without copying a whole line. TaskCounts retains counts, not text views.
StringBuffer accumulates output and Take produces the owned report.

Finding an ASCII newline by byte is valid; it does not treat an arbitrary byte
as a whole Unicode character. Trim handles whitespace including CRLF endings.

## 5. Exercise boundaries manually

An empty file gives zero counts. A single done line without final newline counts
once. Blank lines add nothing; a later: prefix counts as unrecognized. Renaming
the input file should take the read-failure branch. In this simple format even
an empty title after done: counts; title/date validation is not implemented.

## 6. Extend the tool

Require nonempty trimmed titles, add a doing category, extract counts.ny with a
small public surface, and test counting independently of file access. Later,
produce machine-readable output with JsonWriter. Check the title by slicing
after the prefix, trimming and inspecting length; do not reread the whole file
in each branch. Keep input/output orchestration distinct from counting logic.
