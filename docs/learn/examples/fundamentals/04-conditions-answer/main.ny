import "stdlib:stdlib.ny";

func show_temperature(temperature: int32) -> void {
  if temperature < 0 {
    Console.Println("freezing");
  } else if temperature < 20 {
    Console.Println("cool");
  } else {
    Console.Println("warm");
  }
}

func main() -> int32 {
  show_temperature(-1);
  show_temperature(0);
  show_temperature(19);
  show_temperature(20);

  return 0;
}
