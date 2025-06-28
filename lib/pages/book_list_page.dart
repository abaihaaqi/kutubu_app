import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';
import '../widgets/book_card.dart';
import 'login_page.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  List<Book> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService().getBooks();
      setState(() {
        books = data.map((e) => Book.fromJson(e)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat buku: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> showBookDialog({Book? book}) async {
    final titleCtrl = TextEditingController(text: book?.title);
    final authorCtrl = TextEditingController(text: book?.author);
    final yearCtrl = TextEditingController(text: book?.year.toString());
    final categoryCtrl = TextEditingController(text: book?.category);

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(book == null ? 'Tambah Buku' : 'Edit Buku'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Judul'),
                  ),
                  TextField(
                    controller: authorCtrl,
                    decoration: const InputDecoration(labelText: 'Penulis'),
                  ),
                  TextField(
                    controller: yearCtrl,
                    decoration: const InputDecoration(labelText: 'Tahun'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: categoryCtrl,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final payload = {
                    'title': titleCtrl.text.trim(),
                    'author': authorCtrl.text.trim(),
                    'year': int.tryParse(yearCtrl.text.trim()) ?? 0,
                    'category': categoryCtrl.text.trim(),
                  };

                  if (book == null) {
                    await ApiService().createBook(payload);
                  } else {
                    await ApiService().updateBook(book.id, payload);
                  }

                  Navigator.pop(ctx);
                  fetchBooks();
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  Future<void> confirmDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Hapus Buku'),
            content: const Text('Apakah kamu yakin ingin menghapus buku ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await ApiService().deleteBook(id);
      fetchBooks();
    }
  }

  Future<void> pickAndUploadCover(int bookId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await ApiService().uploadCover(bookId, File(picked.path));
      fetchBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchBooks),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBookDialog(),
        child: const Icon(Icons.add),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : books.isEmpty
              ? const Center(child: Text('Tidak ada buku'))
              : ListView.builder(
                itemCount: books.length,
                itemBuilder:
                    (ctx, i) => BookCard(
                      book: books[i],
                      onEdit: () => showBookDialog(book: books[i]),
                      onDelete: () => confirmDelete(books[i].id),
                      onUploadCover: () => pickAndUploadCover(books[i].id),
                    ),
              ),
    );
  }
}
