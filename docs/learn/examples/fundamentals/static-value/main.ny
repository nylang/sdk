import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

static method(Point) Origin() -> Point {
  return Point{ x: 0, y: 0 };
}

func main() -> int32 {
  let point: Point = Point.Origin();
  Console.Println("x={0}, y={1}", point.x, point.y);

  return 0;
}
