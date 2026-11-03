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
