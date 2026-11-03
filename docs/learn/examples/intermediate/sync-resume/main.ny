import "stdlib:stdlib.ny";

sync* func count_to(limit: int32) -> int32 {
  var value: int32 = 1;
  while value <= limit {
    yield value;
    value = value + 1;
  }
}

func main() -> int32 {
  let sequence: Iterable<int32> = count_to(3);
  var cursor: Iterator<int32> = sequence.Enum();
  if !cursor.MoveNext() {
    return 1;
  }

  Console.Println("first={0}", cursor.Current());
  Console.Println("between");
  if !cursor.MoveNext() {
    return 2;
  }

  Console.Println("second={0}", cursor.Current());

  return 0;
}
