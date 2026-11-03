import "stdlib:stdlib.ny";

struct Box<T> {
  value: T;
}

method(Box<T>) Get() -> T {
  return self.value;
}

func main() -> int32 {
  let number: Box<int32> = Box<int32>{ value: 42 };
  let word: Box<string> = Box<string>{ value: "Nyra" };

  Console.Println("{0}={1}", word.Get(), number.Get());

  return 0;
}
