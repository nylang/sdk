import "stdlib:stdlib.ny";

func larger<T: num>(left: T, right: T) -> T {
  if left > right {
    return left;
  }

  return right;
}

func main() -> int32 {
  let first: int32 = larger<int32>(20, 42);
  let second: int32 = larger(30, 12);

  Console.Println("first={0}, second={1}", first, second);

  return 0;
}
