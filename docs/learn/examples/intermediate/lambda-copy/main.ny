import "stdlib:stdlib.ny";

func add_one(value: int32) -> int32 {
  return value + 1;
}

func apply_twice(value: int32, transform: (int32) -> int32) -> int32 {
  return transform(transform(value));
}

func main() -> int32 {
  var step: int32 = 1;
  let transform: (int32) -> int32 = lambda [copy step] (value: int32) -> int32 {
    return value + step;
  };
  step = 100;

  Console.Println("result={0}, outer={1}", apply_twice(40, transform), step);

  return 0;
}
