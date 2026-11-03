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
