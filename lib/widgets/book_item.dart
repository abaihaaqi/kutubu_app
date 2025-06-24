import 'package:flutter/material.dart';
import 'package:kutubu_app/screens/add_edit_book_screen.dart';
import '../models/book.dart';

class BookItem extends StatelessWidget {
  final Book book;
  final VoidCallback? onRefresh;

  const BookItem({super.key, required this.book, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.teal,
          child: Text(
            book.title.isNotEmpty ? book.title[0].toUpperCase() : '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${book.author} • ${book.year}'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditBookScreen(book: book),
            ),
          );
          if (result == true) {
            onRefresh!();
          }
        },
      ),
    );
  }
}
