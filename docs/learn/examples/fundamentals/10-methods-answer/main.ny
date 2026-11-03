import "stdlib:stdlib.ny";

struct Counter {
  value: int32;
}

method(Counter) Add(amount: int32) -> void {
  self.value = self.value + amount;
}

method(Counter) Reset() -> void {
  self.value = 0;
}

func main() -> int32 {
  var counter: Counter = Counter{ value: 0 };
  counter.Add(5);
  counter.Reset();
  counter.Add(2);

  Console.Println("value={0}", counter.value);

  return 0;
}
