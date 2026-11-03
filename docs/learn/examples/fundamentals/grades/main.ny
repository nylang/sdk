import "stdlib:stdlib.ny";

func main() -> int32 {
  let score: int32 = 85;
  if score >= 90 {
    Console.Println("excellent");
  } else if score >= 60 {
    Console.Println("pass");
  } else {
    Console.Println("retry");
  }

  return 0;
}
