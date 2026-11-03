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
