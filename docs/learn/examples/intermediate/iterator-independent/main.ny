import "stdlib:stdlib.ny";

func numbers() -> Array<int32> {
  var items: Array<int32> = Array<int32>{};
  items.Push(10);
  items.Push(20);
  items.Push(12);

  return items;
}

func main() -> int32 {
  let items: Array<int32> = numbers();
  var first: Iterator<int32> = items.Enum();
  var second: Iterator<int32> = items.Enum();
  if !first.MoveNext() || !second.MoveNext() {
    return 1;
  }

  Console.Println("first={0}, second={1}", first.Current(), second.Current());
  if !first.MoveNext() {
    return 2;
  }

  Console.Println("next={0}, other={1}", first.Current(), second.Current());

  return 0;
}
