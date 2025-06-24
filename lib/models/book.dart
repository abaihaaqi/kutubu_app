class Book {
  int? id;
  String title;
  String author;
  int year;
  String category;
  String? cover; // Path atau base64 gambar cover (opsional)

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.category,
    this.cover,
  });

  // Konversi dari Map (database) ke object
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      year: map['year'],
      category: map['category'],
      cover: map['cover'],
    );
  }

  // Konversi dari object ke Map (untuk insert ke database)
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'author': author,
      'year': year,
      'category': category,
      'cover': cover,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
