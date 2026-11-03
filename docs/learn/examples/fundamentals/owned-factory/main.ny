import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

factory(Point) Make(x: int32, y: int32) -> unique<Point> {
  return new unique<Point>{ x: x, y: y };
}

method(Point) Sum() -> int32 {
  return self.x + self.y;
}

func main() -> int32 {
  let point: unique<Point> = Point.Make(20, 22);
  Console.Println("sum={0}", point.Sum());

  return 0;
}
