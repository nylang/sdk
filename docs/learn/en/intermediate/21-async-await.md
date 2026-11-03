# 21 · Async/await: one result and an explicit executor

[中文](../../intermediate/21-async-await.md) · [Previous](20-sync-generators.md) · [Stage index](README.md) · [Next](22-future-errors.md)

## Goals

An async function eventually yields one result. Await waits within the async computation; it does not automatically start a thread. Begin at the synchronous boundary, then nest awaits and trace continuation order.

## Syntax and contracts

The declaration’s T is the successful body result; a caller receives the Future<T> contract, concretely AsyncFuture<T> by default in hosted code. A synchronous entry pins its executor with @driven and starts via drive. Nested async calls inherit it. Await propagates errors through the enclosing future.

## Example 1: start, drive, check and extract

[Source](../../examples/intermediate/async-boundary/main.ny) · [package.yaml](../../examples/intermediate/async-boundary/package.yaml) · [expected.txt](../../examples/intermediate/async-boundary/expected.txt)

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

Expected output:

```text
value=42
```

RunUntilIdle handles ready work and suffices for this immediately completable example. Check errors/presence before extracting. External I/O needs its own ongoing event progress.

## Example 2: nested calls inherit the driver

[Source](../../examples/intermediate/async-nested/main.ny) · [package.yaml](../../examples/intermediate/async-nested/package.yaml) · [expected.txt](../../examples/intermediate/async-nested/expected.txt)

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

Expected output:

```text
value=42
```

The first await produces 21, the second 42. Do not add future handles as integers or create another driver inside calculate.

## Example 3: code after await is a continuation

[Source](../../examples/intermediate/async-order/main.ny) · [package.yaml](../../examples/intermediate/async-order/package.yaml) · [expected.txt](../../examples/intermediate/async-order/expected.txt)

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

Expected output:

```text
before
after
value=42
```

The example establishes order inside the async body and final result consumption, not a universal scheduling order around drive.

## Common mistakes and boundaries

Ordinary main cannot await. Drive prefixes a call, not an arbitrary block. An idle executor does not imply every task is complete; check GetResult. Async and async* have different result shapes.

## Exercise

Await 10+11, then multiply by 2, producing 42.

<details>
<summary>Complete answer</summary>

[Source](../../examples/intermediate/async-answer/main.ny) · [package.yaml](../../examples/intermediate/async-answer/package.yaml) · [expected.txt](../../examples/intermediate/async-answer/expected.txt)

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

Expected output:

```text
value=42
```

Await obtains the scalar before ordinary arithmetic.

</details>

[Previous](20-sync-generators.md) · [Stage index](README.md) · [Next](22-future-errors.md)
