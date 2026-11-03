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
