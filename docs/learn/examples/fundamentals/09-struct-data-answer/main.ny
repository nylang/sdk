import "stdlib:stdlib.ny";

struct Rectangle {
  width: int32;
  height: int32;
}

func main() -> int32 {
  let full: Rectangle = Rectangle{ width: 6, height: 7 };
  let partial: Rectangle = Rectangle{ width: 6 };

  Console.Println("full={0}, partial={1}", full.width * full.height, partial.width * partial.height);

  return 0;
}
