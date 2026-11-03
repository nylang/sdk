import "stdlib:stdlib.ny";

func main() -> int32 {
  let values: <int32>[] = { 3, 1, 4, 2 };
  var maximum: int32 = values[0];
  for index in 1..4 {
    if values[index] > maximum {
      maximum = values[index];
    }
  }

  Console.Println("maximum={0}", maximum);

  return 0;
}
