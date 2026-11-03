import "stdlib:stdlib.ny";

struct Point {
  x: int32;
  y: int32;
}

method(Point) Sum() -> int32 {
  return self.x + self.y;
}

struct Marker {
  position: Point;
  color: int32;
}

func main() -> int32 {
  let marker: Marker = Marker{ position: Point{ x: 20, y: 22 }, color: 7 };
  Console.Println("sum={0}", marker.position.Sum());

  return 0;
}
