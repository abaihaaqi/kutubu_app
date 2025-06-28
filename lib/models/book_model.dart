class Book {
  final int id;
  final String title;
  final String author;
  final int year;
  final String category;
  final String? coverUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.category,
    this.coverUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['ID'] as int,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      year:
          json['year'] is String
              ? int.tryParse(json['year']) ?? 0
              : json['year'] ?? 0,
      category: json['category'] ?? '',
      coverUrl: json['cover_image'], // nullable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'year': year,
      'category': category,
    };
  }
}
