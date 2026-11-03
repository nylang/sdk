import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  var total: int32 = 0;
  for value in count_to(0) {
    total = total + value;
  }

  Console.Println("empty={0}", total);
  for value in count_to(3) {
    total = total + value;
  }

  Console.Println("total={0}", total);

  return 0;
}
