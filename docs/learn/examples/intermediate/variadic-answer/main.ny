import "stdlib:stdlib.ny";

func total_plus(base: int32, parts: ...enable<int32>) -> int32 {
  var total: int32 = base;
  for index in 0..parts.length {
    total = total + parts[index];
  }

  return total;
}

func main() -> int32 {
  Console.Println("total={0}", total_plus(10, 20, 12));

  return 0;
}
