# 23 · Async generators and Flow: sequences and collection boundaries

[中文](../../intermediate/23-async-flow.md) · [Previous](22-future-errors.md) · [Stage index](README.md) · [Next](../09-text-files.md)

## Goals

Async produces one future result; async* produces a sequence. Generate and collect, await inside the producer, then handle flow failure. A Flow is distinct from a byte-oriented I/O Stream.

## Syntax and contracts

The declaration’s T is an element; hosted calls produce AsyncFlow<T>, implementing Flow<T>. Drive binds the producer chain and Collect returns a future array. This SDK uses bounded materialization/collection: do not promise live streaming, backpressure, infinite flows or await-for. Collection memory grows with the sequence.

## Example 1: generate and check collection

[Source](../../examples/intermediate/flow-collect/main.ny) · [package.yaml](../../examples/intermediate/flow-collect/package.yaml) · [expected.txt](../../examples/intermediate/flow-collect/expected.txt)

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

Expected output:

```text
0
1
2
```

Check the collection result before traversing. An empty sequence yields a successful empty array, not the absence of a future.

## Example 2: a bounded Flow from an existing array

[Source](../../examples/intermediate/flow-from-array/main.ny) · [package.yaml](../../examples/intermediate/flow-from-array/package.yaml) · [expected.txt](../../examples/intermediate/flow-from-array/expected.txt)

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

Expected output:

```text
10
32
```

FromArray supplies a finite source; Collect still returns a future. Existing data does not remove the error contract or turn Flow into an I/O Stream.

## Protocol reference: await inside the producer (SDK limitation)

**SDK 1.0.5 limitation:** await inside async* is legal, but this compiler can leave a high-level operation unlowered (tag 10). The complete source and expected result document the contract and serve repair verification; this is not a directly runnable 1.0.5 example. Examples 1/2/3 and the exercise avoid this failing operation.

[Source](../../examples/intermediate/flow-await/main.ny) · [package.yaml](../../examples/intermediate/flow-await/package.yaml) · [expected.txt](../../examples/intermediate/flow-await/expected.txt)

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

Expected output:

```text
10
11
12
```

Each iteration awaits one result and then emits one element on the same driver chain, without a cross-thread parallelism promise.

## Example 3: failure is not partial success

[Source](../../examples/intermediate/flow-error/main.ny) · [package.yaml](../../examples/intermediate/flow-error/package.yaml) · [expected.txt](../../examples/intermediate/flow-error/expected.txt)

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

Expected output:

```text
flow failed
```

Collect propagates the error rather than yielding a partial successful array. Do not discard that error and extract a success payload.

## Common mistakes and boundaries

Flow is the contract and AsyncFlow the hosted concrete value; a Future represents one result. For is not await-for. Do not collect an unbounded producer. Async yield* requires Flow, not an arbitrary synchronous Iterable.

## Exercise

Wrap ticks(2) with async yield*, emit 42 afterward, and collect.

<details>
<summary>Complete answer</summary>

[Source](../../examples/intermediate/flow-answer/main.ny) · [package.yaml](../../examples/intermediate/flow-answer/package.yaml) · [expected.txt](../../examples/intermediate/flow-answer/expected.txt)

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

Expected output:

```text
0
1
42
```

Forward the child Flow’s elements, then emit the final element.

</details>

[Previous](22-future-errors.md) · [Stage index](README.md) · [Next](../09-text-files.md)
