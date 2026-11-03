import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct ScoreCard implements Scored {
  points: int32;
}

method(ScoreCard) Score() -> int32 {
  return self.points;
}

struct ScorePanel {
  card: ScoreCard;
  delegate card : Scored;
}

func read_score(value: Scored) -> int32 {
  return value.Score();
}

func main() -> int32 {
  let panel: ScorePanel = ScorePanel{ card: ScoreCard{ points: 42 } };
  Console.Println("score={0}", read_score(panel));

  return 0;
}
