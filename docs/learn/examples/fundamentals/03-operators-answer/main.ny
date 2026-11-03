import "stdlib:stdlib.ny";

func main() -> int32 {
  let total: int32 = 125;
  Console.Println("minutes={0}, seconds={1}", total / 60, total % 60);

  return 0;
}
