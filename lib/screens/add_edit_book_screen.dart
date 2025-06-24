import 'package:flutter/material.dart';
import '../db/book_database.dart';
import '../models/book.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book; // Kalau null ➔ mode tambah, kalau ada ➔ mode edit

  const AddEditBookScreen({super.key, this.book});

  @override
  _AddEditBookScreenState createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late String title;
  late String author;
  late int year;
  late String category;

  @override
  void initState() {
    super.initState();
    title = widget.book?.title ?? '';
    author = widget.book?.author ?? '';
    year = widget.book?.year ?? DateTime.now().year;
    category = widget.book?.category ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Tambah Buku' : 'Edit Buku'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Judul Buku'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Judul harus diisi'
                            : null,
                onSaved: (value) => title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: author,
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Penulis harus diisi'
                            : null,
                onSaved: (value) => author = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: year.toString(),
                decoration: const InputDecoration(labelText: 'Tahun Terbit'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tahun harus diisi';
                  }
                  final number = int.tryParse(value);
                  if (number == null) return 'Tahun harus angka';
                  return null;
                },
                onSaved: (value) => year = int.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Kategori harus diisi'
                            : null,
                onSaved: (value) => category = value!,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: saveBook,
                child: const Text('Simpan', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: deleteBook,
                child: const Text('Hapus Buku', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveBook() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();

      final newBook = Book(
        id: widget.book?.id,
        title: title,
        author: author,
        year: year,
        category: category,
      );

      if (widget.book == null) {
        await BookDatabase.instance.create(newBook);
      } else {
        await BookDatabase.instance.update(newBook);
      }

      Navigator.of(context).pop(true); // Kembali dan refresh list
    }
  }

  Future<void> deleteBook() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah Anda yakin ingin menghapus buku ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await BookDatabase.instance.delete(widget.book!.id!);
      Navigator.of(context).pop(true); // Kembali dan refresh list
    }
  }
}
