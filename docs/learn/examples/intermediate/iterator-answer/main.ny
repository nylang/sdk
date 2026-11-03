import "stdlib:stdlib.ny";

struct Countdown implements Iterator<int32> {
  next: int32;
  current: int32;
  valid: bool;
}

method(Countdown) MoveNext() -> bool {
  if self.next <= 0 {
    self.valid = false;
    return false;
  }

  self.current = self.next;
  self.next = self.next - 1;
  self.valid = true;

  return true;
}

method(Countdown) Current() -> int32 {
  assert(self.valid);

  return self.current;
}

func main() -> int32 {
  var cursor: Countdown = Countdown{ next: 5, current: 0, valid: false };
  var total: int32 = 0;
  while cursor.MoveNext() {
    total = total + cursor.Current();
  }

  Console.Println("total={0}", total);

  return 0;
}
