import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

static method(Rectangle) Square(side: int32) -> Rectangle {
  return Rectangle{ width: side, height: side };
}

static method(Rectangle) WithSize(width: int32, height: int32) -> Rectangle {
  return Rectangle{ width: width, height: height };
}

method(Rectangle) Area() -> int32 {
  return self.width * self.height;
}

func main() -> int32 {
  let square: Rectangle = Rectangle.Square(6);
  let wide: Rectangle = Rectangle.WithSize(6, 7);

  Console.Println("square={0}, wide={1}", square.Area(), wide.Area());

  return 0;
}
