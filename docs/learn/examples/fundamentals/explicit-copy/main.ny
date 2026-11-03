import "stdlib:stdlib.ny";

func main() -> int32 {
  let original: string = "Nyra".Concat(" language");
  let saved: string = copy(original);

  Console.Println("original={0}", original);
  Console.Println("saved={0}", saved);

  return 0;
}
