import "stdlib:stdlib.ny";

func main() -> int32 {
  var total: int32 = 10;
  if total > 0 {
    let extra: int32 = 5;
    total = total + extra;
  }

  Console.Println("total={0}", total);

  return 0;
}
