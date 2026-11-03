# 22 · Futures, promises and asynchronous errors

[中文](../../intermediate/22-future-errors.md) · [Previous](21-async-await.md) · [Stage index](README.md) · [Next](23-async-flow.md)

## Goals

A future reads a result; a promise settles it once. Distinguish pending, success and failure, then propagate an awaited error to the synchronous boundary. Local Async types do not promise OS-thread safety.

## Syntax and contracts

GetResult returns Result<T, AsyncError>; pending means NotCompleted, not blocking. The first Complete/CompleteError settles the cell; later completion returns AlreadyCompleted. Handles share that cell and do not rerun work. Cross-thread use needs the Concurrent* contract.

## Example 1: pending, then successful

[Source](../../examples/intermediate/promise-state/main.ny) · [package.yaml](../../examples/intermediate/promise-state/package.yaml) · [expected.txt](../../examples/intermediate/promise-state/expected.txt)

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

Expected output:

```text
pending
value=42
```

The same handle observes the state transition. It neither spins nor treats NotCompleted as zero. Prefer await over busy polling in async code.

## Example 2: settle only once

[Source](../../examples/intermediate/promise-once/main.ny) · [package.yaml](../../examples/intermediate/promise-once/package.yaml) · [expected.txt](../../examples/intermediate/promise-once/expected.txt)

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

Expected output:

```text
second completion rejected
```

The second call does not replace the value with 99. Both successful and failed settlement consume the one completion opportunity.

## Example 3: propagate an awaited error

[Source](../../examples/intermediate/await-error/main.ny) · [package.yaml](../../examples/intermediate/await-error/package.yaml) · [expected.txt](../../examples/intermediate/await-error/expected.txt)

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

Expected output:

```text
failed at boundary
```

The outer future completes with error, skipping the normal continuation. No throw/catch syntax is invented; the synchronous caller checks Result.

## Common mistakes and boundaries

An Err may mean NotCompleted rather than terminal failure. Check settlement results and preserve local affinity; a shared handle is not itself a thread-safety guarantee.

## Exercise

Settle a promise with Cancelled and verify its future’s error.

<details>
<summary>Complete answer</summary>

[Source](../../examples/intermediate/future-error-answer/main.ny) · [package.yaml](../../examples/intermediate/future-error-answer/package.yaml) · [expected.txt](../../examples/intermediate/future-error-answer/expected.txt)

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

Expected output:

```text
cancelled
```

Failure occupies the error alternative, not an int32 success payload.

</details>

[Previous](21-async-await.md) · [Stage index](README.md) · [Next](23-async-flow.md)
