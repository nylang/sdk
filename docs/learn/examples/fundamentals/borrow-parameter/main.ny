import "stdlib:stdlib.ny";

func add_two(value: ref mut int32) -> void {
  value = value + 2;
}

func main() -> int32 {
  var count: int32 = 40;
  add_two(count);

  Console.Println("count={0}", count);

  return 0;
}
