class Book {
  int? id;
  String title;
  String author;
  int year;
  String category;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.category,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['ID'],
    title: json['title'],
    author: json['author'],
    year: json['year'],
    category: json['category'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'year': year,
    'category': category,
  };
}
