import "stdlib:stdlib.ny";

func main() -> int32 {
  var value: int32 = 40;
  let address: *mut int32 = &mut value;
  unsafe {
    *address = *address + 2;
  }

  Console.Println("value={0}", value);

  return 0;
}
