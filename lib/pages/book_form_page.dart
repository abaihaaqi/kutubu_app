import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final baseUrl = dotenv.env['BASE_URL']!;

class BookFormPage extends StatefulWidget {
  final Book? book;

  const BookFormPage({super.key, this.book});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  String? _existingImageUrl = "";
  bool _isLoading = false;
  File? _coverImage;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleCtrl.text = widget.book!.title;
      _authorCtrl.text = widget.book!.author;
      _yearCtrl.text = widget.book!.year.toString();
      _categoryCtrl.text = widget.book!.category;
      _categoryCtrl.text = widget.book!.category;
      _existingImageUrl = widget.book!.coverUrl;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _coverImage = File(pickedFile.path));
    }
  }

  void createSuccess() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Buku berhasil ditambahkan')));
  }

  void updateSuccess() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Buku berhasil diperbarui')));
  }

  void submitFail(e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      'title': _titleCtrl.text.trim(),
      'author': _authorCtrl.text.trim(),
      'year': int.tryParse(_yearCtrl.text.trim()) ?? 0,
      'category': _categoryCtrl.text.trim(),
    };

    try {
      if (widget.book == null) {
        await ApiService().createBook(payload, _coverImage);
        createSuccess();
      } else {
        await ApiService().updateBook(widget.book!.id, payload, _coverImage);
        updateSuccess();
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      submitFail(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.book != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Buku' : 'Tambah Buku')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator:
                    (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorCtrl,
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator:
                    (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearCtrl,
                decoration: const InputDecoration(labelText: 'Tahun'),
                keyboardType: TextInputType.number,
                validator:
                    (val) =>
                        val == null || int.tryParse(val) == null
                            ? 'Harus angka'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator:
                    (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              const Text(
                'Cover Buku',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _coverImage != null
                  ? Image.file(_coverImage!, height: 150)
                  : (_existingImageUrl != ""
                      ? Image.network(
                        "$baseUrl/${_existingImageUrl!}",
                        height: 150,
                      )
                      : const Text('Belum ada gambar yang dipilih')),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Text(isEdit ? 'Perbarui' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
