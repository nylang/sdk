import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

func main() -> int32 {
  let first: Point = Point{ x: 3, y: 4 };
  let second: Point = Point{ x: 9 };

  Console.Println("first={0},{1}", first.x, first.y);
  Console.Println("second={0},{1}", second.x, second.y);

  return 0;
}
