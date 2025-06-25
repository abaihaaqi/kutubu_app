import 'package:flutter/material.dart';
import '../models/book.dart';
import '../api/book_api_service.dart';
import '../widgets/book_item.dart';
import 'add_edit_book_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _refreshBooks();
  }

  void _refreshBooks() {
    setState(() {
      _booksFuture = BookApiService.fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Buku'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada buku.'));
          } else {
            final books = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return BookItem(book: books[index], onRefresh: _refreshBooks);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditBookScreen()),
          );
          if (result == true) {
            _refreshBooks();
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
