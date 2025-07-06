import 'package:flutter/material.dart';
import 'package:kutubu_app/pages/book_form_page.dart';
import 'package:kutubu_app/pages/book_list_page.dart';
import 'package:kutubu_app/services/api_service.dart';
import '../models/book_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final baseUrl = dotenv.env['BASE_URL']!;

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final hasCover = book.coverUrl != null && book.coverUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SingleChildScrollView(
        // tambahkan scroll jika konten panjang
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child:
                  hasCover
                      ? Image.network(
                        "$baseUrl/${book.coverUrl!}",
                        errorBuilder:
                            (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 60),
                      )
                      : const Icon(Icons.book, size: 100),
            ),
            SizedBox(height: 24),
            Text('Judul:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(book.title),
            SizedBox(height: 16),
            Text('Penulis:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(book.author),
            SizedBox(height: 16),
            Text('Tahun:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(book.year.toString()),
            SizedBox(height: 16),
            Text('Kategori:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(book.category.isNotEmpty ? book.category : 'Lainnya'),
            SizedBox(height: 32),

            // Tambahkan tombol Edit dan Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text('Edit'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BookFormPage(
                              book: book,
                            ), // pastikan menerima `book`
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text('Hapus'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Hapus Buku'),
                            content: Text(
                              'Apakah kamu yakin ingin menghapus buku ini?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await ApiService().deleteBook(book.id);
                                  Navigator.pop(context); // tutup dialog
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const BookListPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
