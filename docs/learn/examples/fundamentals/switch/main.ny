import "stdlib:stdlib.ny";

func main() -> int32 {
  let command: int32 = 2;
  switch command {
    case 1:
      Console.Println("start");
    case 2:
      Console.Println("stop");
    default:
      Console.Println("unknown");
  }

  return 0;
}
