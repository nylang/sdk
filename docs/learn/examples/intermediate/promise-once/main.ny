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
