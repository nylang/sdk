import "stdlib:stdlib.ny";

func print_title(title: ref string) -> void {
  Console.Print("borrowed=");
  Console.Println(title);
}

func main() -> int32 {
  let title: string = "Nyra";
  print_title(title);
  Console.Println("still={0}", title);

  return 0;
}
