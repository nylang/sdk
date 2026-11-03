import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

struct Bounds {
  origin: Point;
  width: int32;
}

func main() -> int32 {
  var box: Bounds = Bounds{ origin: Point{ x: 1, y: 2 }, width: 6 };
  box.origin.x = 10;

  Console.Println("x={0}, width={1}", box.origin.x, box.width);

  return 0;
}
