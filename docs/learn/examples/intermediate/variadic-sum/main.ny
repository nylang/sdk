import "stdlib:stdlib.ny";

func sum(parts: ...enable<int32>) -> int32 {
  var total: int32 = 0;
  for index in 0..parts.length {
    total = total + parts[index];
  }

  return total;
}

func main() -> int32 {
  Console.Println("empty={0}, one={1}, many={2}", sum(), sum(7), sum(10, 20, 12));

  return 0;
}
