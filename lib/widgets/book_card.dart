import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onUploadCover;

  const BookCard({
    Key? key,
    required this.book,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onUploadCover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onTap,
        leading:
            book.coverUrl != null
                ? Image.network(
                  "http://localhost:5000${book.coverUrl!}",
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const Icon(Icons.broken_image, size: 60),
                )
                : const Icon(Icons.book, size: 60),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${book.author} • ${book.year}\n${book.category}'),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
              case 'upload':
                onUploadCover?.call();
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                const PopupMenuItem(
                  value: 'upload',
                  child: Text('Upload Cover'),
                ),
              ],
        ),
      ),
    );
  }
}
