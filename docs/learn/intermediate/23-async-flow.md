# 23 · async* 与 Flow：异步序列及收集边界

[English](../en/intermediate/23-async-flow.md) · [上一课](22-future-errors.md) · [本阶段目录](README.md) · [下一课](../09-text-files.md)

## 本课目标

async 产生一个未来结果，async* 产生一串元素。先生成再 Collect，再在生产者中 await，最后处理序列失败。Flow 的元素序列不是文件 I/O 的字节 Stream。

## 语法与合同

async* 的 -> T 仍是元素类型，用户态调用得到 AsyncFlow<T>（Flow<T> 的具体实现）。同步入口通过 drive/executor 绑定生产链，Collect(executor) 返回未来数组。当前 SDK 使用有界物化／收集模型：不要宣称元素实时推送、背压、无限流或 await for 已经可用。Collect 的内存成本随元素总量增长。

## 例 1：生成并检查收集结果

[源码](../examples/intermediate/flow-collect/main.ny) · [package.yaml](../examples/intermediate/flow-collect/package.yaml) · [expected.txt](../examples/intermediate/flow-collect/expected.txt)

```nyra
import "stdlib:stdlib.ny";

async* func ticks(count: int32) -> int32 {
  for index in 0..count {
    yield index;
  }
}

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let flow: AsyncFlow<int32> = drive(executor) ticks(3);
  let collected: AsyncFuture<Array<int32>> = flow.Collect(executor);
  executor.RunUntilIdle();
  let result: Result<Array<int32>, AsyncError> = collected.GetResult();
  if result.IsErr() {
    return 1;
  }

  let values: Array<int32>? = result.get_if<Array<int32>>();
  if values == nil {
    return 2;
  }

  let items: Array<int32> = values as Array<int32>;
  for index in 0..items.Len() {
    let value: int32 = items.Get(index);
    Console.Println("{0}", value);
  }

  return 0;
}
```

预期输出：

```text
0
1
2
```

先检查 Collect 的 Result，再遍历成功数组。空序列应得到成功的空数组，不是“没有返回 Future”。

## 例 2：从已有数组建立有界 Flow

[源码](../examples/intermediate/flow-from-array/main.ny) · [package.yaml](../examples/intermediate/flow-from-array/package.yaml) · [expected.txt](../examples/intermediate/flow-from-array/expected.txt)

```nyra
import "stdlib:stdlib.ny";

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  var source: Array<int32> = Array<int32>{};
  source.Push(10);
  source.Push(32);
  let flow: AsyncFlow<int32> = AsyncFlow<int32>.FromArray(source);
  let collected: AsyncFuture<Array<int32>> = flow.Collect(executor);
  executor.RunUntilIdle();
  let result: Result<Array<int32>, AsyncError> = collected.GetResult();
  if result.IsErr() {
    return 1;
  }

  let values: Array<int32>? = result.get_if<Array<int32>>();
  if values == nil {
    return 2;
  }

  let items: Array<int32> = values as Array<int32>;
  for index in 0..items.Len() {
    let value: int32 = items.Get(index);
    Console.Println("{0}", value);
  }

  return 0;
}
```

预期输出：

```text
10
32
```

FromArray 明确给出有限数据源；Collect 仍返回 Future。不要因为数据已经存在就省略错误分支或混用字节 Stream。

## 协议补充：生产者内 await（SDK 限制）

**SDK 1.0.5 限制：** async* 内 await 是语言合同允许的形式，但该版本可能在 Core 降级时报出未处理的高层操作（tag 10）。下例保留完整合法源码与预期结果，用于理解合同和编译器修复验证，不能当成可直接运行的 1.0.5 例子。例 1、例 2、例 3 和本课练习不依赖这条故障路径。

[源码](../examples/intermediate/flow-await/main.ny) · [package.yaml](../examples/intermediate/flow-await/package.yaml) · [expected.txt](../examples/intermediate/flow-await/expected.txt)

```nyra
import "stdlib:stdlib.ny";

async func add_async(left: int32, right: int32) -> int32 {
  return left + right;
}

async* func adjusted(count: int32) -> int32 {
  for index in 0..count {
    let value: int32 = await add_async(index, 10);
    yield value;
  }
}

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let flow: AsyncFlow<int32> = drive(executor) adjusted(3);
  let collected: AsyncFuture<Array<int32>> = flow.Collect(executor);
  executor.RunUntilIdle();
  let result: Result<Array<int32>, AsyncError> = collected.GetResult();
  if result.IsErr() {
    return 1;
  }

  let values: Array<int32>? = result.get_if<Array<int32>>();
  if values == nil {
    return 2;
  }

  let items: Array<int32> = values as Array<int32>;
  for index in 0..items.Len() {
    let value: int32 = items.Get(index);
    Console.Println("{0}", value);
  }

  return 0;
}
```

预期输出：

```text
10
11
12
```

每次先等到单个值，再 yield 一项。生产者仍使用同一驱动链，不能据此保证跨线程并行。

## 例 3：失败不伪装为部分成功数组

[源码](../examples/intermediate/flow-error/main.ny) · [package.yaml](../examples/intermediate/flow-error/package.yaml) · [expected.txt](../examples/intermediate/flow-error/expected.txt)

```nyra
import "stdlib:stdlib.ny";

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let flow: AsyncFlow<int32> = AsyncFlow<int32>.Error(AsyncError.Other);
  let collected: AsyncFuture<Array<int32>> = flow.Collect(executor);
  executor.RunUntilIdle();
  let result: Result<Array<int32>, AsyncError> = collected.GetResult();
  if !result.IsErr() {
    return 1;
  }

  Console.Println("flow failed");

  return 0;
}
```

预期输出：

```text
flow failed
```

错误序列的 Collect 返回 Err。不要从错误结果中提取数组、丢掉错误，再当成成功但不完整的数据。

## 常见错误与边界

Flow<T> 是序列合同，AsyncFlow<T> 是当前用户态具体值；Future<T> 只代表一次结果。不要把普通 for 当 await for，也不要用当前 Collect 去消费没有结束条件的生产者。yield* 在 async* 中要求 Flow，不能随便混入同步 Iterable。

## 练习

在 ticks 前加一个包装 async*，先 yield* ticks(2)，然后 yield 42，再收集。

<details>
<summary>完整参考答案</summary>

[源码](../examples/intermediate/flow-answer/main.ny) · [package.yaml](../examples/intermediate/flow-answer/package.yaml) · [expected.txt](../examples/intermediate/flow-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

async* func ticks(count: int32) -> int32 {
  for index in 0..count {
    yield index;
  }
}

async* func with_tail() -> int32 {
  yield* ticks(2);
  yield 42;
}

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let flow: AsyncFlow<int32> = drive(executor) with_tail();
  let collected: AsyncFuture<Array<int32>> = flow.Collect(executor);
  executor.RunUntilIdle();
  let result: Result<Array<int32>, AsyncError> = collected.GetResult();
  if result.IsErr() {
    return 1;
  }

  let values: Array<int32>? = result.get_if<Array<int32>>();
  if values == nil {
    return 2;
  }

  let items: Array<int32> = values as Array<int32>;
  for index in 0..items.Len() {
    let value: int32 = items.Get(index);
    Console.Println("{0}", value);
  }

  return 0;
}
```

预期输出：

```text
0
1
42
```

转发的是子 Flow 的元素，最后再追加一项。

</details>

[上一课](22-future-errors.md) · [本阶段目录](README.md) · [下一课](../09-text-files.md)
