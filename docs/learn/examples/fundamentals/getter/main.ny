import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

method(Rectangle) get area -> int32 {
  return self.width * self.height;
}

func main() -> int32 {
  let rectangle: Rectangle = Rectangle{ width: 6, height: 7 };
  Console.Println("area={0}", rectangle.area);

  return 0;
}
