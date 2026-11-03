import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

method(Rectangle) Area() -> int32 {
  return self.width * self.height;
}

method(Rectangle) DoubleArea() -> int32 {
  return self.Area() * 2;
}

func main() -> int32 {
  let rectangle: Rectangle = Rectangle{ width: 6, height: 7 };
  Console.Println("area={0}, doubled={1}", rectangle.Area(), rectangle.DoubleArea());

  return 0;
}
