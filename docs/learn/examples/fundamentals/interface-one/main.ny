import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct Exam implements Scored {
  points: int32;
}

method(Exam) Score() -> int32 {
  return self.points;
}

func read_score(value: Scored) -> int32 {
  return value.Score();
}

func main() -> int32 {
  let exam: Exam = Exam{ points: 42 };
  Console.Println("score={0}", read_score(exam));

  return 0;
}
