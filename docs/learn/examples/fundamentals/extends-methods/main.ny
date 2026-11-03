import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

method(Point) MoveX(amount: int32) -> void {
  self.x = self.x + amount;
}

method(Point) Sum() -> int32 {
  return self.x + self.y;
}

struct ColoredPoint extends Point {
  color: int32;
}

func main() -> int32 {
  var point: ColoredPoint = ColoredPoint{ x: 20, y: 22, color: 7 };
  point.MoveX(1);

  Console.Println("sum={0}, color={1}", point.Sum(), point.color);

  return 0;
}
