# 22 · Future、Promise 与异步错误

[English](../en/intermediate/22-future-errors.md) · [上一课](21-async-await.md) · [本阶段目录](README.md) · [下一课](23-async-flow.md)

## 本课目标

Future 是读取结果的一侧，Promise 是完成一次的一侧。分清待完成、成功、失败，再看 await 如何把错误传到同步边界。这里的本地 Async 类型不承诺跨 OS 线程安全。

## 语法与合同

GetResult 返回 Result<T, AsyncError>；待完成时是 NotCompleted，不是阻塞等待。Promise.Complete/CompleteError 第一次完成后，第二次返回 AlreadyCompleted。句柄共享同一个完成状态；读取不是重新执行计算。需要跨线程的场合另选 Concurrent* 合同。

## 例 1：先待完成，再成功

[源码](../examples/intermediate/promise-state/main.ny) · [package.yaml](../examples/intermediate/promise-state/package.yaml) · [expected.txt](../examples/intermediate/promise-state/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var promise: AsyncPromise<int32> = AsyncPromise<int32>.New();
  let future: AsyncFuture<int32> = promise.FutureHandle();
  let pending: Result<int32, AsyncError> = future.GetResult();
  if !pending.IsErr() {
    return 1;
  }

  Console.Println("pending");
  let completed: Result<Unit, AsyncError> = promise.Complete(42);
  if completed.IsErr() {
    return 2;
  }

  let result: Result<int32, AsyncError> = future.GetResult();
  let value: int32? = result.get_if<int32>();
  if value == nil {
    return 3;
  }

  Console.Println("value={0}", value as int32);

  return 0;
}
```

预期输出：

```text
pending
value=42
```

同一个 future 在完成前后读出不同状态。没有等待循环，也没有把 NotCompleted 当 0。真实异步代码通常 await，而不是忙等轮询。

## 例 2：完成只能发生一次

[源码](../examples/intermediate/promise-once/main.ny) · [package.yaml](../examples/intermediate/promise-once/package.yaml) · [expected.txt](../examples/intermediate/promise-once/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var promise: AsyncPromise<int32> = AsyncPromise<int32>.New();
  let first: Result<Unit, AsyncError> = promise.Complete(42);
  let second: Result<Unit, AsyncError> = promise.Complete(99);
  if first.IsErr() || !second.IsErr() {
    return 1;
  }

  let error: AsyncError? = second.get_if<AsyncError>();
  if error == nil {
    return 2;
  }

  if (error as AsyncError) != AsyncError.AlreadyCompleted {
    return 3;
  }

  Console.Println("second completion rejected");

  return 0;
}
```

预期输出：

```text
second completion rejected
```

第二次调用不会把结果替换成 99；返回错误不是忽略结果继续执行的理由。成功和失败都消耗这次完成机会。

## 例 3：await 传播失败

[源码](../examples/intermediate/await-error/main.ny) · [package.yaml](../examples/intermediate/await-error/package.yaml) · [expected.txt](../examples/intermediate/await-error/expected.txt)

```nyra
import "stdlib:stdlib.ny";

async func failing() -> int32 {
  let source: AsyncFuture<int32> = AsyncFuture<int32>.Error(AsyncError.Other);
  let value: int32 = await source;
  Console.Println("unreachable");

  return value;
}

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let future: AsyncFuture<int32> = drive(executor) failing();
  executor.RunUntilIdle();
  let result: Result<int32, AsyncError> = future.GetResult();
  if !result.IsErr() {
    return 1;
  }

  Console.Println("failed at boundary");

  return 0;
}
```

预期输出：

```text
failed at boundary
```

失败使外层 Future 完成错误，await 后的正常路径不执行。没有发明 throw/catch；同步调用者检查 Result。

## 常见错误与边界

不能把 GetResult 的 Err 一律叫“已经失败”，其中也可能是 NotCompleted。不要对同一 Promise 重复完成并忽略返回值。AsyncPromise/AsyncFuture 的本地亲和性不能因为内部有共享句柄就当成线程安全。

## 练习

用 CompleteError(AsyncError.Cancelled) 完成 Promise，并检查对应 Future 的错误。

<details>
<summary>完整参考答案</summary>

[源码](../examples/intermediate/future-error-answer/main.ny) · [package.yaml](../examples/intermediate/future-error-answer/package.yaml) · [expected.txt](../examples/intermediate/future-error-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var promise: AsyncPromise<int32> = AsyncPromise<int32>.New();
  let future: AsyncFuture<int32> = promise.FutureHandle();
  let completed: Result<Unit, AsyncError> = promise.CompleteError(AsyncError.Cancelled);
  if completed.IsErr() {
    return 1;
  }

  let result: Result<int32, AsyncError> = future.GetResult();
  let error: AsyncError? = result.get_if<AsyncError>();
  if error == nil {
    return 2;
  }

  if (error as AsyncError) != AsyncError.Cancelled {
    return 3;
  }

  Console.Println("cancelled");

  return 0;
}
```

预期输出：

```text
cancelled
```

失败由错误分支表达，不能提取为成功的 int32。

</details>

[上一课](21-async-await.md) · [本阶段目录](README.md) · [下一课](23-async-flow.md)
