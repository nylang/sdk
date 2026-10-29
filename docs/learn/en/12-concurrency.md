# 12: Async functions, generators and threads

[中文](../12-concurrency.md) · [Course index](README.md) · [Previous](11-task-report.md) · [Next](13-systems.md)

These are optional advanced topics. A generator yields one value at a time.
Async work can suspend and resume. A thread is an OS-scheduled execution path
that can run concurrently. An async function does not automatically create a
new thread.

## 1. A synchronous generator

Complete program:

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

Expect 1, 2 and 3 on separate lines. yield supplies one element; a later iteration
resumes after that point. The declared int32 is the yielded element type.

## 2. A minimal async call

Complete program:

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

Expected result: 42. Create an executor, declare its type with @driven on the
synchronous entry, start work with drive, obtain an AsyncFuture, run available
tasks and check GetResult before extracting the integer.

RunUntilIdle suffices for this immediately completing computation. In general,
an idle executor does not imply completion of tasks waiting on external I/O.
await belongs inside async functions; synchronous main starts the chain through
drive and must retain its @driven declaration.

## 3. An asynchronous sequence

Separate complete program:

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

Collect produces the elements 0, 1 and 2. An async sequence and a file byte stream
are different contracts even if both are described informally as streams.

## 4. Start an OS thread

Complete program:

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

Join waits for completion. This example has no shared mutable user state.
Multiple threads changing an array, counter or object need a synchronization
contract beyond reference counting.

## Exercises

Change count_to(3) to count_to(5). Change add_async(20,21) to add_async(30,11);
the result remains 42. Do not add @profile to async/generator functions here:
the current probe rejects these functions spanning suspension points.
