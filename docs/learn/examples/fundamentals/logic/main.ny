import "stdlib:stdlib.ny";

func main() -> int32 {
  let age: int32 = 20;
  let has_ticket: bool = true;
  let cancelled: bool = false;

  if age >= 18 && has_ticket && !cancelled {
    Console.Println("admitted");
  }

  let divisor: int32 = 0;
  if divisor != 0 && 12 / divisor > 1 {
    Console.Println("large quotient");
  }

  return 0;
}
