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
