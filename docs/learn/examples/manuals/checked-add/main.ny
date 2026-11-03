import "kernel:kernel.ny";

func main() -> int32 {
  let base: uint64 = 40u64;
  var result: uint64 = 7u64;
  if !base.TryAdd(2u64, result) {
    return 1;
  }

  if result != 42u64 {
    return 2;
  }

  let maximum: uint64 = 0xffffffffffffffffu64;
  if maximum.TryAdd(1u64, result) {
    return 3;
  }

  if result != 42u64 {
    return 4;
  }

  return 0;
}
