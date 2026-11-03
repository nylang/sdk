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
