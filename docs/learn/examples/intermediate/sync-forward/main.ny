import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

sync* func with_tail(limit: int32) -> int32 {
  yield* count_to(limit);
  yield 42;
}

func main() -> int32 {
  for value in with_tail(2) {
    Console.Println("{0}", value);
  }

  return 0;
}
