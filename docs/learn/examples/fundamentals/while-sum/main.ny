import "stdlib:stdlib.ny";

func main() -> int32 {
  var number: int32 = 1;
  var total: int32 = 0;
  while number <= 5 {
    total = total + number;
    number = number + 1;
  }

  Console.Println("sum={0}, next={1}", total, number);

  return 0;
}
