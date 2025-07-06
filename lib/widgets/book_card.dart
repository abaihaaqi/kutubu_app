import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final baseUrl = dotenv.env['BASE_URL']!;

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({Key? key, required this.book, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasCover = book.coverUrl != null && book.coverUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              hasCover
                  ? Image.network(
                    "$baseUrl/${book.coverUrl!}",
                    errorBuilder:
                        (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 60),
                  )
                  : const Icon(Icons.book, size: 40),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${book.author} • ${book.year}\n${book.category.isNotEmpty ? book.category : 'Lainnya'}',
        ),
      ),
    );
  }
}
