import "stdlib:stdlib.ny";

async func add_async(left: int32, right: int32) -> int32 {
  return left + right;
}

async* func adjusted(count: int32) -> int32 {
  for index in 0..count {
    let value: int32 = await add_async(index, 10);
    yield value;
  }
}

@driven(SingleThreadExecutor)
func main() -> int32 {
  var executor: SingleThreadExecutor = SingleThreadExecutor.New();
  let flow: AsyncFlow<int32> = drive(executor) adjusted(3);
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
