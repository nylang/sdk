import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct Card implements Scored {
  points: int32;
}

method(Card) Score() -> int32 {
  return self.points;
}

func read_score<T: Scored>(value: T) -> int32 {
  return value.Score();
}

func main() -> int32 {
  let card: Card = Card{ points: 42 };
  Console.Println("score={0}", read_score(card));

  return 0;
}
