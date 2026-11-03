import "stdlib:stdlib.ny";

interface ValueView {
  get value -> int32;
  set value(next: int32) -> void;
}

struct Counter implements ValueView {
  current: int32;
}

method(Counter) get value -> int32 {
  return self.current;
}

method(Counter) set value(next: int32) {
  self.current = next;
}

func read_value(view: ValueView) -> int32 {
  return view.value;
}

func main() -> int32 {
  var counter: Counter = Counter{ current: 42 };
  Console.Println("value={0}", read_value(counter));

  return 0;
}
