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
  var cursor: Iterator<int32> = items.Enum();
  var total: int32 = 0;
  while cursor.MoveNext() {
    total = total + cursor.Current();
  }

  Console.Println("total={0}", total);

  return 0;
}
