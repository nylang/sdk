import "stdlib:stdlib.ny";

func plus_two(value: int32) -> int32 {
  return value + 2;
}

func main() -> int32 {
  let original: int32 = 20;
  let result: int32 = plus_two(original);

  Console.Println("original={0}, result={1}", original, result);

  return 0;
}
