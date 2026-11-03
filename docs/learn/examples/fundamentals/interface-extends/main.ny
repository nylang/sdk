import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

interface Ranked extends Scored {
  Rank() -> int32;
}

struct ResultCard implements Ranked {
  points: int32;
}

method(ResultCard) Score() -> int32 {
  return self.points;
}

method(ResultCard) Rank() -> int32 {
  return 1;
}

func ranked_total(card: Ranked) -> int32 {
  return card.Score() + card.Rank();
}

func main() -> int32 {
  let card: ResultCard = ResultCard{ points: 41 };
  Console.Println("total={0}", ranked_total(card));

  return 0;
}
