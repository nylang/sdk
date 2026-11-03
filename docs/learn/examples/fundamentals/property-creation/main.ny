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

static method(Counter) StartingAt(initial: int32) -> Counter {
  var counter: Counter = Counter{ current: 0 };
  counter.value = initial;

  return counter;
}

func main() -> int32 {
  let counter: Counter = Counter.StartingAt(-10);
  Console.Println("initial={0}", counter.value);

  return 0;
}
