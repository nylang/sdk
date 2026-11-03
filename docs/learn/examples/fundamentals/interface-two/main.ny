import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct Exam implements Scored {
  points: int32;
}

struct Bonus implements Scored {
  base: int32;
  extra: int32;
}

method(Exam) Score() -> int32 {
  return self.points;
}

method(Bonus) Score() -> int32 {
  return self.base + self.extra;
}

func read_score(value: Scored) -> int32 {
  return value.Score();
}

func main() -> int32 {
  let exam: Exam = Exam{ points: 40 };
  let bonus: Bonus = Bonus{ base: 20, extra: 2 };

  Console.Println("exam={0}, bonus={1}", read_score(exam), read_score(bonus));

  return 0;
}
