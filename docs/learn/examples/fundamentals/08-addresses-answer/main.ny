import "stdlib:stdlib.ny";

func add_two(value: ref mut int32) -> void {
  value = value + 2;
}

func main() -> int32 {
  var value: int32 = 10;
  add_two(value);
  add_two(value);

  Console.Println("value={0}", value);

  return 0;
}
