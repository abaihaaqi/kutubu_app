import 'package:flutter/material.dart';
import '../models/book.dart';
import '../api/book_api_service.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;

  const AddEditBookScreen({Key? key, this.book}) : super(key: key);

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
    final isEditing = widget.book != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Buku' : 'Tambah Buku'),
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
                  if (value == null || value.isEmpty)
                    return 'Tahun harus diisi';
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
                onPressed: _saveBook,
                child: const Text('Simpan', style: TextStyle(fontSize: 18)),
              ),
              if (isEditing) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _deleteBook,
                  child: const Text(
                    'Hapus Buku',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final book = Book(
        id: widget.book?.id,
        title: title,
        author: author,
        year: year,
        category: category,
      );

      try {
        if (widget.book == null) {
          await BookApiService.createBook(book);
        } else {
          await BookApiService.updateBook(book);
        }
        Navigator.of(context).pop(true);
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _deleteBook() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menghapus buku ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true && widget.book != null) {
      try {
        await BookApiService.deleteBook(widget.book!.id!);
        Navigator.of(context).pop(true);
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $message')));
  }
}
