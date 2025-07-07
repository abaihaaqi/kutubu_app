import 'package:flutter/material.dart';
import 'package:kutubu_app/pages/book_form_page.dart';
import 'package:kutubu_app/pages/book_list_page.dart';
import 'package:kutubu_app/services/api_service.dart';
import '../models/book_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final baseUrl = dotenv.env['BASE_URL']!;

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book; // simpan book ke dalam state
  }

  void goToEditBook() async {
    final updatedBook = await Navigator.push<Book>(
      context,
      MaterialPageRoute(builder: (context) => BookFormPage(book: _book)),
    );

    if (updatedBook != null) {
      setState(() {
        _book = updatedBook; // update state agar UI berubah
      });
    }
  }

  void deleteSuccess() {
    Navigator.pop(context); // kembali ke BookListPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BookListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCover = _book.coverUrl != null && _book.coverUrl!.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, true); // Trigger refresh di BookListPage
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_book.title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      hasCover
                          ? Image.network(
                            "$baseUrl/${_book.coverUrl!}",
                            width: 200,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 60),
                          )
                          : const Icon(Icons.book, size: 100),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Judul:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_book.title),
              const SizedBox(height: 16),
              const Text(
                'Penulis:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_book.author),
              const SizedBox(height: 16),
              const Text(
                'Tahun:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_book.year.toString()),
              const SizedBox(height: 16),
              const Text(
                'Kategori:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_book.category.isNotEmpty ? _book.category : 'Lainnya'),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: goToEditBook,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Hapus Buku'),
                              content: const Text(
                                'Apakah kamu yakin ingin menghapus buku ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await ApiService().deleteBook(_book.id);
                                    deleteSuccess();
                                  },
                                  child: const Text(
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
      ),
    );
  }
}
