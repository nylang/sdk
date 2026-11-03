import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

struct ColoredPoint extends Point {
  color: int32;
}

func main() -> int32 {
  let point: ColoredPoint = ColoredPoint{ x: 20, y: 22, color: 7 };
  Console.Println("x={0}, y={1}, color={2}", point.x, point.y, point.color);

  return 0;
}
