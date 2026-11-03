import "stdlib:stdlib.ny";

func main() -> int32 {
  let greeting: string = "Hello";
  let message: string = greeting.Concat(", Nyra");

  Console.Println("{0}", message);
  Console.Println("ascii-bytes={0}", greeting.length);

  return 0;
}
