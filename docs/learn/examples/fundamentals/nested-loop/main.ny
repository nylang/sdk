import "stdlib:stdlib.ny";

func main() -> int32 {
  var count: int32 = 0;
  for row in 0..2 {
    for column in 0..3 {
      count = count + 1;
    }
  }

  Console.Println("cells={0}", count);

  return 0;
}
