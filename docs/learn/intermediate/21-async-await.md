# 21 · async/await：单个结果与显式执行器

[English](../en/intermediate/21-async-await.md) · [上一课](20-sync-generators.md) · [本阶段目录](README.md) · [下一课](22-future-errors.md)

## 本课目标

async 函数最终得到一个结果，await 允许当前异步计算等它，而不是自动启动一条线程。先看完整同步边界，再看嵌套 await，最后用顺序打印解释继续执行的位置。

## 语法与合同

异步声明 -> T 写的是函数体成功返回的值类型；调用方得到 Future<T> 合同，用户态默认具体类型为 AsyncFuture<T>。同步入口声明 @driven(具体执行器)，通过 drive(executor) 启动。内部异步调用继承驱动器，不再重复 drive。await 的错误会传播为外层 Future 的错误。

## 例 1：完整启动、驱动、检查与取值

[源码](../examples/intermediate/async-boundary/main.ny) · [package.yaml](../examples/intermediate/async-boundary/package.yaml) · [expected.txt](../examples/intermediate/async-boundary/expected.txt)

```nyra
import "stdlib:stdlib.ny";

async func add_async(left: int32, right: int32) -> int32 {
  return left + right;
}

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let future: AsyncFuture<int32> = drive(executor) add_async(20, 22);
  executor.RunUntilIdle();
  let result: Result<int32, AsyncError> = future.GetResult();
  if result.IsErr() {
    return 1;
  }

  let value: int32? = result.get_if<int32>();
  if value == nil {
    return 2;
  }

  Console.Println("value={0}", value as int32);

  return 0;
}
```

预期输出：

```text
value=42
```

RunUntilIdle 处理当前可运行任务；本例无外部等待，足以完成。先检查错误和可空提取，再取得值。真实 I/O 还需要让外部事件持续驱动。

## 例 2：嵌套调用共享驱动器

[源码](../examples/intermediate/async-nested/main.ny) · [package.yaml](../examples/intermediate/async-nested/package.yaml) · [expected.txt](../examples/intermediate/async-nested/expected.txt)

```nyra
import "stdlib:stdlib.ny";

async func add_async(left: int32, right: int32) -> int32 {
  return left + right;
}

async func calculate() -> int32 {
  let first: int32 = await add_async(20, 1);
  return await add_async(first, 21);
}

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let future: AsyncFuture<int32> = drive(executor) calculate();
  executor.RunUntilIdle();
  let result: Result<int32, AsyncError> = future.GetResult();
  if result.IsErr() {
    return 1;
  }

  let value: int32? = result.get_if<int32>();
  if value == nil {
    return 2;
  }

  Console.Println("value={0}", value as int32);

  return 0;
}
```

预期输出：

```text
value=42
```

第一次 await 给出 21，第二次返回 42。不是把 Future 当 int32 相加，也不在 calculate 中再建另一个执行器。

## 例 3：await 后的代码是继续执行的部分

[源码](../examples/intermediate/async-order/main.ny) · [package.yaml](../examples/intermediate/async-order/package.yaml) · [expected.txt](../examples/intermediate/async-order/expected.txt)

```nyra
import "stdlib:stdlib.ny";

async func add_async(left: int32, right: int32) -> int32 {
  return left + right;
}

async func trace() -> int32 {
  Console.Println("before");
  let value: int32 = await add_async(40, 2);
  Console.Println("after");

  return value;
}

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let future: AsyncFuture<int32> = drive(executor) trace();
  executor.RunUntilIdle();
  let result: Result<int32, AsyncError> = future.GetResult();
  if result.IsErr() {
    return 1;
  }

  let value: int32? = result.get_if<int32>();
  if value == nil {
    return 2;
  }

  Console.Println("value={0}", value as int32);

  return 0;
}
```

预期输出：

```text
before
after
value=42
```

本例只规定异步函数内部 before、after 的顺序和最后消费结果；不推断 drive 返回前后的一般线程调度时序。

## 常见错误与边界

普通 main 中不能直接 await。drive 前缀作用于调用，不是任意代码块。执行器空闲不等于所有任务完成；Future 没完成时 GetResult 不能当成功值读取。async 与 async* 也不是同一种结果。

## 练习

异步计算先加 10+11，再把结果乘 2，输出 42。

<details>
<summary>完整参考答案</summary>

[源码](../examples/intermediate/async-answer/main.ny) · [package.yaml](../examples/intermediate/async-answer/package.yaml) · [expected.txt](../examples/intermediate/async-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

async func add_async(left: int32, right: int32) -> int32 {
  return left + right;
}

async func doubled_sum() -> int32 {
  let value: int32 = await add_async(10, 11);
  return value * 2;
}

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let future: AsyncFuture<int32> = drive(executor) doubled_sum();
  executor.RunUntilIdle();
  let result: Result<int32, AsyncError> = future.GetResult();
  if result.IsErr() {
    return 1;
  }

  let value: int32? = result.get_if<int32>();
  if value == nil {
    return 2;
  }

  Console.Println("value={0}", value as int32);

  return 0;
}
```

预期输出：

```text
value=42
```

await 先取得整数，再进行同步算术。

</details>

[上一课](20-sync-generators.md) · [本阶段目录](README.md) · [下一课](22-future-errors.md)
