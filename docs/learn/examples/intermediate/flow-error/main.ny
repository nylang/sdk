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
