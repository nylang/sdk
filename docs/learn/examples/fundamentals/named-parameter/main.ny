import "stdlib:stdlib.ny";

func total_price(unit: int32, quantity: int32, {discount: int32 = 0}) -> int32 {
  return unit * quantity - discount;
}

func main() -> int32 {
  Console.Println("plain={0}, discounted={1}", total_price(12, 4), total_price(12, 4, discount: 6));

  return 0;
}
