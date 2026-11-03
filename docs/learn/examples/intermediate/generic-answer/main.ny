import "stdlib:stdlib.ny";

func smaller<T: num>(left: T, right: T) -> T {
  if left < right {
    return left;
  }

  return right;
}

func main() -> int32 {
  Console.Println("smaller={0}", smaller<int32>(20, 42));

  return 0;
}
