# AsyncFlow<T>.Collect

**Owner:** stdlib, hosted generic AsyncFlow instance method. **Reference:** SDK 1.0.5.
Import `stdlib:stdlib.ny`; read the exported `public/async/flow.ny` recipe.

```nyra
pub method(AsyncFlow<T>) Collect(exec: Executor) -> AsyncFuture<Array<T>>;
```

The Flow<T> interface declares the corresponding contract as
`Collect(exec: Executor) -> Future<Array<T>>`. Concrete and interface result names
must not be treated as interchangeable source declarations.

Collect gathers elements in emission order. Successful completion produces the
whole Array<T>; empty success produces an empty array. Failure produces
AsyncError, **not** a partial successful array. Pending and failed futures remain
different states. Inspect GetResult before extracting the array.

The executor is explicit; this API does not select an ambient event loop. The
reference SDK uses a materialized hosted representation rather than a live
cross-thread emitter. Collection requires storage proportional to element count
and copies elements according to their type contracts. It does not promise deep
cloning of arbitrary payload object graphs. No unbounded-source/backpressure or
await-for guarantee follows from the Flow name.

The returned future/array follows ordinary ownership and cleanup. Borrowed
collection element results need their owner's lifetime; Array.Get in this SDK
returns `ref mut T`. To format an integer element, first bind it as an int32 value
rather than pack a ref-mut argument into the string-enable channel.

For a complete producer/collect/error example and downloadable packages, follow
[async generators and Flow](../../learn/intermediate/23-async-flow.md).
For manual future-state handling, read
[Future and Promise](../../learn/intermediate/22-future-errors.md).
Do not assume RunUntilIdle alone completes arbitrary external I/O or that local
AsyncFlow/Future values are safe to mutate from unrelated OS threads.
