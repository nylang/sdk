import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

func main() -> int32 {
  let original: Point = Point{ x: 3, y: 4 };
  var changed: Point = original;
  changed.x = 10;

  Console.Println("original={0}, changed={1}", original.x, changed.x);

  return 0;
}
