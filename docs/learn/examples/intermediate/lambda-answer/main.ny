import "stdlib:stdlib.ny";

func add_one(value: int32) -> int32 {
  return value + 1;
}

func apply_twice(value: int32, transform: (int32) -> int32) -> int32 {
  return transform(transform(value));
}

func main() -> int32 {
  let step: int32 = 2;
  let transform: (int32) -> int32 = lambda [copy step] (value: int32) -> int32 {
    return value + step;
  };

  Console.Println("result={0}", apply_twice(38, transform));

  return 0;
}
