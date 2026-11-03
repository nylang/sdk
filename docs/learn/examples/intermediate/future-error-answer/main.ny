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
