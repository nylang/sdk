import "stdlib:stdlib.ny";

func main() -> int32 {
  let read_flag: uint32 = 1u;
  let write_flag: uint32 = 2u;
  let flags: uint32 = read_flag | write_flag;

  Console.Println("flags={0}, shifted={1}", flags, 1u << 3u);
  if (flags & read_flag) != 0u {
    Console.Println("read enabled");
  }

  return 0;
}
