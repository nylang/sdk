import "stdlib:stdlib.ny";

struct Counter {
  current: int32;
}

method(Counter) get value -> int32 {
  return self.current;
}

method(Counter) set value(next: int32) {
  if next < 0 {
    self.current = 0;
    return;
  }

  self.current = next;
}

func main() -> int32 {
  var counter: Counter = Counter{ current: 0 };
  counter.value = -5;
  Console.Println("clamped={0}", counter.value);
  counter.value = 42;
  Console.Println("valid={0}", counter.value);

  return 0;
}
