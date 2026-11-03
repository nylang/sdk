import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  var count: int32 = 0;
  for value in count_to(0) {
    count = count + 1;
  }

  Console.Println("count={0}", count);

  return 0;
}
