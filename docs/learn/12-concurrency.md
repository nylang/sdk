# 12 · 异步、生成器和线程

[上一课](11-task-report.md) · [教程目录](README.md) · [下一课](13-systems.md)

从这里开始是可选进阶。先区分三个词：

- 生成器：每次产生一个值，不必一次生成整个数组。
- 异步：一项工作可以暂停等待，之后继续。
- 线程：操作系统调度的一条执行路径，可以和其他线程并行。

异步函数不等于自动创建新线程。

## 1. 同步生成器

完整程序：

```nyra
import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  for value in count_to(3) {
    Console.Println("{0}", value);
  }
  return 0;
}
```

预期分三行输出 1、2、3。
`yield` 交出本次的一个值；之后继续迭代时，从后面接着运行。
函数声明里的 `int32` 表示每次产生的元素类型。

## 2. 最小异步例子

完整程序：

```nyra
import "stdlib:stdlib.ny";

async func add_async(left: int32, right: int32) -> int32 {
  return left + right;
}

async func calculate_async() -> int32 {
  let value: int32 = await add_async(20, 21);
  return value + 1;
}

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let future: AsyncFuture<int32> = drive(executor) calculate_async();
  executor.RunUntilIdle();
  let result: Result<int32, AsyncError> = future.GetResult();
  if result.IsErr() {
    Console.Eprintln("异步计算失败");
    return 1;
  }
  let value: int32? = result.get_if<int32>();
  if value == nil { return 2; }
  Console.Println("结果：{0}", value as int32);
  return 0;
}
```

预期结果 42。这个例子没有外部等待，目的是先看清完整调用步骤：

1. 创建执行器 `executor`，负责安排任务继续运行。
2. 在同步入口写 `@driven(SingleThreadExecutor)`，明确执行器类型。
3. `drive(executor)` 把异步调用交给这个执行器。
4. 得到 `AsyncFuture<int32>`，代表之后可以取得的结果。
5. `RunUntilIdle()` 驱动当前可运行任务。
6. 检查 `GetResult()` 是否成功，再取出数值。

一般程序中，“执行器暂时空闲”不保证所有依赖外部事件的任务都已经完成。
本例只有立即可完成的计算，所以足够；真实 I/O 需要相应事件驱动。

`await` 用在异步函数里面。同步入口通过 `drive` 启动调用链，不能直接把 `await` 塞进普通 `main`。
也不要遗漏入口的 `@driven`。

## 3. 异步序列

下面是可以单独替换 `main.ny` 的完整程序：

```nyra
import "stdlib:stdlib.ny";

async* func ticks(count: int32) -> int32 {
  var index: int32 = 0;
  while index < count {
    yield index;
    index = index + 1;
  }
}

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let flow: AsyncFlow<int32> = drive(executor) ticks(3);
  let collected: AsyncFuture<Array<int32>> = flow.Collect(executor);
  executor.RunUntilIdle();
  let result: Result<Array<int32>, AsyncError> = collected.GetResult();
  if result.IsErr() { return 1; }
  let values: Array<int32>? = result.get_if<Array<int32>>();
  if values == nil { return 2; }
  let items: Array<int32> = values as Array<int32>;
  for index in 0..items.Len() {
    Console.Println("{0}", items.Get(index));
  }
  return 0;
}
```

`Collect` 把异步序列收集成数组。成功收集的元素是 0、1、2。
异步序列和文件字节流不是同一个概念，不要因为两者都叫“流”就混用接口。

## 4. 真正启动一个线程

完整程序：

```nyra
import "stdlib:stdlib.ny";

func worker() -> void {
  Console.Println("工作线程正在执行");
}

func main() -> int32 {
  let started: Result<Thread, ThreadError> = Thread.Spawn(worker);
  if started.IsErr() {
    Console.Eprintln("线程创建失败");
    return 1;
  }
  let thread_value: Thread? = started.get_if<Thread>();
  if thread_value == nil { return 2; }
  var thread: Thread = thread_value as Thread;
  let joined: Result<Unit, ThreadError> = thread.Join();
  if joined.IsErr() {
    Console.Eprintln("等待线程失败");
    return 3;
  }
  Console.Println("工作线程已结束");
  return 0;
}
```

`Join()` 等待该线程结束。这个例子没有跨线程共享可修改的用户数据，所以先不涉及锁。
如果多个线程修改同一份数组、计数或对象字段，需要额外设计同步。

## 练习

先把 `count_to(3)` 改成 `count_to(5)`。
再把 `add_async(20, 21)` 改成 `add_async(30, 11)`，结果应该仍然为 42。

暂时不要给异步或生成器函数添加 `@profile`：当前探针拒绝这两种跨暂停点的函数。
