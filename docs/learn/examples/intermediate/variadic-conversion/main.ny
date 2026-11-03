import "stdlib:stdlib.ny";

struct Score {
  points: int32;
}

method(Score) ToInt32() -> int32 {
  return self.points;
}

func sum(parts: ...enable<int32>) -> int32 {
  var total: int32 = 0;
  for index in 0..parts.length {
    total = total + parts[index];
  }

  return total;
}

func main() -> int32 {
  let item: Score = Score{ points: 22 };
  Console.Println("total={0}", sum(20, item));

  return 0;
}
