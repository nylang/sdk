import "stdlib:stdlib.ny";

func main() -> int32 {
  let unit_price: int32 = 12;
  var quantity: int32 = 4;
  quantity = quantity + 2;

  Console.Println("quantity={0}, total={1}", quantity, unit_price * quantity);

  return 0;
}
