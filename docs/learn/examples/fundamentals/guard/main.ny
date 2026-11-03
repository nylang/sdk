import "stdlib:stdlib.ny";

func admitted_count(count: int32) -> int32 {
  if count < 0 {
    return 0;
  }

  return count;
}

func main() -> int32 {
  Console.Println("bad={0}, good={1}", admitted_count(-1), admitted_count(3));

  return 0;
}
