import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/book.dart';
import '../api/book_api_service.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;

  const AddEditBookScreen({Key? key, this.book}) : super(key: key);

  @override
  _AddEditBookScreenState createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String author;
  late int year;
  late String category;
  
  late AnimationController _animationController;
  late List<AnimationController> _bookAnimationControllers;
  late List<Animation<Offset>> _bookAnimations;

  @override
  void initState() {
    super.initState();
    title = widget.book?.title ?? '';
    author = widget.book?.author ?? '';
    year = widget.book?.year ?? DateTime.now().year;
    category = widget.book?.category ?? '';
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    // Create multiple floating books with different animations
    _bookAnimationControllers = List.generate(
      6,
      (index) => AnimationController(
        duration: Duration(seconds: 12 + (index * 4)),
        vsync: this,
      )..repeat(),
    );

    _bookAnimations = _bookAnimationControllers.asMap().entries.map((entry) {
      int index = entry.key;
      AnimationController controller = entry.value;
      
      return Tween<Offset>(
        begin: Offset(-0.3, 0.1 + (index * 0.12)),
        end: Offset(1.3, 0.15 + (index * 0.08)),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));
    }).toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _bookAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.book != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1810), // Dark brown
              Color(0xFF4A2C2A), // Medium brown
              Color(0xFF6B4423), // Light brown
            ],
          ),
        ),
        child: Stack(
          children: [
            // Enhanced animated floating books background with more variety
            ...List.generate(
              8, // More books for better effect
              (index) => AnimatedBuilder(
                animation: _bookAnimations[index % _bookAnimations.length],
                builder: (context, child) {
                  double animationValue = _bookAnimations[index % _bookAnimations.length].value.dx;
                  double yOffset = _bookAnimations[index % _bookAnimations.length].value.dy;
                  
                  // Create floating effect
                  double floatingOffset = math.sin((_animationController.value + index) * 2 * math.pi) * 15;
                  
                  return Positioned(
                    left: MediaQuery.of(context).size.width * animationValue,
                    top: (MediaQuery.of(context).size.height * yOffset) + floatingOffset,
                    child: Transform.rotate(
                      angle: (_animationController.value + index * 0.4) * 2 * math.pi * 0.08,
                      child: Opacity(
                        opacity: 0.12 + (index * 0.02),
                        child: Icon(
                          _getBookIcon(index),
                          size: 25 + (index * 6).toDouble(),
                          color: _getBookColor(index),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Additional decorative elements
            Positioned(
              top: 120,
              left: 40,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      12 * math.sin(_animationController.value * 2 * math.pi * 0.3),
                      8 * math.cos(_animationController.value * 2 * math.pi * 0.5),
                    ),
                    child: Icon(
                      Icons.edit_note,
                      size: 35,
                      color: Colors.amber.withOpacity(0.15),
                    ),
                  );
                },
              ),
            ),
            
            Positioned(
              bottom: 200,
              right: 30,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      -8 * math.sin(_animationController.value * 2 * math.pi * 0.6),
                      12 * math.cos(_animationController.value * 2 * math.pi * 0.4),
                    ),
                    child: Icon(
                      Icons.create,
                      size: 40,
                      color: Colors.brown.withOpacity(0.12),
                    ),
                  );
                },
              ),
            ),
            
            // Main content
            Column(
              children: [
                // Custom App Bar
                Container(
                  padding: const EdgeInsets.only(
                    top: 50,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          isEditing ? 'Edit Buku' : 'Tambah Buku Baru',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black54,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit : Icons.add,
                          color: Colors.amber,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Form Content - Made more compact
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              // Welcome text
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isEditing ? Icons.edit_note : Icons.library_add,
                                      color: Colors.amber.shade700,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        isEditing 
                                          ? 'Perbarui informasi buku'
                                          : 'Tambahkan buku baru ke koleksi',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.amber.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              _buildFormField(
                                initialValue: title,
                                label: 'Judul Buku',
                                icon: Icons.title,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Judul harus diisi'
                                        : null,
                                onSaved: (value) => title = value!,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              _buildFormField(
                                initialValue: author,
                                label: 'Penulis',
                                icon: Icons.person,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Penulis harus diisi'
                                        : null,
                                onSaved: (value) => author = value!,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              _buildFormField(
                                initialValue: year.toString(),
                                label: 'Tahun Terbit',
                                icon: Icons.calendar_today,
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
                              
                              _buildFormField(
                                initialValue: category,
                                label: 'Kategori',
                                icon: Icons.category,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Kategori harus diisi'
                                        : null,
                                onSaved: (value) => category = value!,
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Save Button
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFFB347),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: _saveBook,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isEditing ? Icons.update : Icons.save,
                                        color: const Color(0xFF6B4423),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isEditing ? 'Perbarui' : 'Simpan',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6B4423),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              if (isEditing) ...[
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.withOpacity(0.1),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: _deleteBook,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.delete_forever,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Hapus Buku',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String initialValue,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF6B4423),
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2C1810),
        ),
      ),
    );
  }

  IconData _getBookIcon(int index) {
    List<IconData> bookIcons = [
      Icons.menu_book,
      Icons.book,
      Icons.auto_stories,
      Icons.library_books,
      Icons.bookmark,
      Icons.book_online,
      Icons.chrome_reader_mode,
      Icons.article,
    ];
    return bookIcons[index % bookIcons.length];
  }
  
  Color _getBookColor(int index) {
    List<Color> bookColors = [
      Colors.amber.withOpacity(0.25),
      Colors.brown.withOpacity(0.18),
      Colors.orange.withOpacity(0.22),
      Colors.deepOrange.withOpacity(0.18),
      Colors.yellow.withOpacity(0.25),
      Colors.red.withOpacity(0.18),
      Colors.pink.withOpacity(0.22),
      Colors.purple.withOpacity(0.18),
    ];
    return bookColors[index % bookColors.length];
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              'Konfirmasi Hapus',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1810),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus buku ini dari koleksi? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4A2C2A),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Terjadi kesalahan: $message',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}