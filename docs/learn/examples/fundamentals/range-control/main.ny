import "stdlib:stdlib.ny";

func main() -> int32 {
  for number in 0..10 {
    if number == 7 {
      break;
    }

    if number % 2 != 0 {
      continue;
    }

    Console.Println("{0}", number);
  }

  return 0;
}
