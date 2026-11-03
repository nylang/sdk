import "stdlib:stdlib.ny";

func main() -> int32 {
  let prefix: string = "Hello";
  let message: string = prefix.Concat(", Nyra");
  Console.Println("{0}", message);
  Console.Println("{0}", prefix);

  return 0;
}
