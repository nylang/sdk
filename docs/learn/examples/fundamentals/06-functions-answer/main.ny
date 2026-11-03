import "stdlib:stdlib.ny";

func clamp_score(value: int32) -> int32 {
  if value < 0 {
    return 0;
  }

  if value > 100 {
    return 100;
  }

  return value;
}

func main() -> int32 {
  Console.Println("{0},{1},{2}", clamp_score(-1), clamp_score(42), clamp_score(101));

  return 0;
}
