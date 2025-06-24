import 'package:flutter/material.dart';
import 'package:kutubu_app/screens/add_edit_book_screen.dart';
import '../db/book_database.dart';
import '../models/book.dart';
import '../widgets/book_item.dart'; // Kita pakai widget card dari sini nanti

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late Future<List<Book>> booksFuture;

  @override
  void initState() {
    super.initState();
    refreshBooks();
  }

  void refreshBooks() {
    booksFuture = BookDatabase.instance.readAllBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Buku Saya'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Book>>(
        future: booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi Kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada buku.'));
          } else {
            final books = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return BookItem(
                  book: book,
                  onRefresh: () {
                    setState(() {
                      refreshBooks();
                    });
                  },
                );
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
            setState(() {
              refreshBooks(); // Refresh setelah tambah/edit
            });
          }
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
