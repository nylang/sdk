import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

method(Rectangle) get perimeter -> int32 {
  return 2 * (self.width + self.height);
}

func main() -> int32 {
  var rectangle: Rectangle = Rectangle{ width: 6, height: 7 };
  Console.Println("before={0}", rectangle.perimeter);
  rectangle.width = 10;
  Console.Println("after={0}", rectangle.perimeter);

  return 0;
}
