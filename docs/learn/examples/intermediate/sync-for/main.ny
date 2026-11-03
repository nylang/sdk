import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  for value in count_to(3) {
    Console.Println("{0}", value);
  }

  return 0;
}
