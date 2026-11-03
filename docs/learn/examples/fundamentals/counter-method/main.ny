import "stdlib:stdlib.ny";

struct Counter {
  value: int32;
}

method(Counter) Add(amount: int32) -> void {
  self.value = self.value + amount;
}

func main() -> int32 {
  var first: Counter = Counter{ value: 0 };
  var second: Counter = Counter{ value: 10 };
  first.Add(2);
  first.Add(3);

  Console.Println("first={0}, second={1}", first.value, second.value);

  return 0;
}
