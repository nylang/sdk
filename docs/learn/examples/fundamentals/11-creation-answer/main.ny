import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

static method(Rectangle) Unit() -> Rectangle {
  return Rectangle{ width: 1, height: 1 };
}

struct Point {
  x: int32;
  y: int32;
}

factory(Point) OnXAxis(x: int32) -> unique<Point> {
  return new unique<Point>{ x: x, y: 0 };
}

func main() -> int32 {
  let rectangle: Rectangle = Rectangle.Unit();
  let point: unique<Point> = Point.OnXAxis(42);

  Console.Println("area={0}, x={1}, y={2}", rectangle.width * rectangle.height, point.x, point.y);

  return 0;
}
