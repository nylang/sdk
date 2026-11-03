import "stdlib:stdlib.ny";

func main() -> int32 {
  var total: int32 = 0;
  for number in 1..11 {
    if number % 2 == 0 {
      total = total + number;
    }
  }

  Console.Println("total={0}", total);

  return 0;
}
