import "stdlib:stdlib.ny";

interface Named {
  Name() -> string;
}

struct Book implements Named {
  title: string;
}

struct Person implements Named {
  name: string;
}

method(Book) Name() -> string {
  return self.title;
}

method(Person) Name() -> string {
  return self.name;
}

func print_name(value: Named) -> void {
  Console.Println("name={0}", value.Name());
}

func main() -> int32 {
  let book: Book = Book{ title: "Guide" };
  let person: Person = Person{ name: "Ada" };
  print_name(book);
  print_name(person);

  return 0;
}
