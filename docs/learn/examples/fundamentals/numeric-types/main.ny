import "stdlib:stdlib.ny";

func main() -> int32 {
  let small: int32 = 42;
  let wide: int64 = small;
  let precise: float64 = 5.0 / 2.0;

  if precise == 2.5 {
    Console.Println("wide={0}, fraction=2.5", wide);
  }

  return 0;
}
