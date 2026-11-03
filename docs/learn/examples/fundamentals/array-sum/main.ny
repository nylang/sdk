import "stdlib:stdlib.ny";

func main() -> int32 {
  let values: <int32>[] = { 10, 20, 12 };
  var total: int32 = 0;
  for index in 0..3 {
    total = total + values[index];
  }

  Console.Println("total={0}", total);

  return 0;
}
