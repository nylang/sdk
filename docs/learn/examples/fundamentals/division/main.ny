import "stdlib:stdlib.ny";

func main() -> int32 {
  let value: int32 = 17;
  let divisor: int32 = 5;

  Console.Println("quotient={0}, remainder={1}", value / divisor, value % divisor);
  Console.Println("grouped={0}", (2 + 3) * 4);

  return 0;
}
