import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/book.dart';
import '../api/book_api_service.dart';
import '../widgets/book_item.dart';
import 'add_edit_book_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen>
    with TickerProviderStateMixin {
  late Future<List<Book>> _booksFuture;
  late AnimationController _animationController;
  late List<AnimationController> _bookAnimationControllers;
  late List<Animation<Offset>> _bookAnimations;

  @override
  void initState() {
    super.initState();
    _refreshBooks();
    _initializeAnimations();
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
      Colors.amber.withOpacity(0.3),
      Colors.brown.withOpacity(0.2),
      Colors.orange.withOpacity(0.25),
      Colors.deepOrange.withOpacity(0.2),
      Colors.yellow.withOpacity(0.3),
      Colors.red.withOpacity(0.2),
      Colors.pink.withOpacity(0.25),
      Colors.purple.withOpacity(0.2),
    ];
    return bookColors[index % bookColors.length];
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Create multiple floating books with different animations
    _bookAnimationControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: Duration(seconds: 15 + (index * 3)),
        vsync: this,
      )..repeat(),
    );

    _bookAnimations = _bookAnimationControllers.asMap().entries.map((entry) {
      int index = entry.key;
      AnimationController controller = entry.value;
      
      return Tween<Offset>(
        begin: Offset(-0.5, 0.2 + (index * 0.15)),
        end: Offset(1.5, 0.3 + (index * 0.1)),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));
    }).toList();
  }

  void _refreshBooks() {
    setState(() {
      _booksFuture = BookApiService.fetchBooks();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _bookAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildBookCard(Book book, int index) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.amber.withOpacity(0.05),
            ],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle book tap
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Icon/Cover
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getBookColor(index),
                        _getBookColor(index).withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getBookIcon(index),
                    color: Colors.brown.shade700,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Book Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1810),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Author
                      Text(
                        'oleh ${book.author}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.brown.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      
                      
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () async {
                              // Edit book
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddEditBookScreen(book: book),
                                ),
                              );
                              if (result == true) {
                                _refreshBooks();
                              }
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.amber.shade700,
                              size: 20,
                            ),
                            tooltip: 'Edit Buku',
                          ),
                          IconButton(
                            onPressed: () {
                              _showDeleteConfirmation(book);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            tooltip: 'Hapus Buku',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              const Text('Konfirmasi Hapus'),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus buku "${book.title}"?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Delete book logic here
                // await BookApiService.deleteBook(book.id);
                _refreshBooks();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  double floatingOffset = math.sin((_animationController.value + index) * 2 * math.pi) * 20;
                  
                  return Positioned(
                    left: MediaQuery.of(context).size.width * animationValue,
                    top: (MediaQuery.of(context).size.height * yOffset) + floatingOffset,
                    child: Transform.rotate(
                      angle: (_animationController.value + index * 0.3) * 2 * math.pi * 0.1,
                      child: Opacity(
                        opacity: 0.15 + (index * 0.03),
                        child: Icon(
                          _getBookIcon(index),
                          size: 30 + (index * 8).toDouble(),
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
              top: 100,
              left: 30,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      15 * math.sin(_animationController.value * 2 * math.pi * 0.5),
                      10 * math.cos(_animationController.value * 2 * math.pi * 0.3),
                    ),
                    child: Icon(
                      Icons.bookmark,
                      size: 40,
                      color: Colors.amber.withOpacity(0.2),
                    ),
                  );
                },
              ),
            ),
            
            Positioned(
              bottom: 150,
              right: 40,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      -10 * math.sin(_animationController.value * 2 * math.pi * 0.4),
                      15 * math.cos(_animationController.value * 2 * math.pi * 0.6),
                    ),
                    child: Icon(
                      Icons.library_books,
                      size: 50,
                      color: Colors.brown.withOpacity(0.15),
                    ),
                  );
                },
              ),
            ),
            
            // Decorative library elements
            Positioned(
              top: 50,
              right: 20,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      10 * math.sin(_animationController.value * 2 * math.pi),
                      5 * math.cos(_animationController.value * 2 * math.pi),
                    ),
                    child: Icon(
                      Icons.auto_stories,
                      size: 60,
                      color: Colors.amber.withOpacity(0.2),
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
                        child: const Icon(
                          Icons.local_library,
                          color: Colors.amber,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          'Katalog Perpustakaan',
                          style: TextStyle(
                            fontSize: 24,
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
                    ],
                  ),
                ),
                
                // Book Card List Content
                Expanded(
                  child: FutureBuilder<List<Book>>(
                    future: _booksFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF6B4423),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Memuat koleksi buku...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF6B4423),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Card(
                            margin: const EdgeInsets.all(20),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'Gagal memuat data',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${snapshot.error}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Card(
                            margin: const EdgeInsets.all(20),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.library_books_outlined,
                                    size: 64,
                                    color: Colors.amber.shade700,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Perpustakaan Kosong',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Belum ada koleksi buku.\nTambahkan buku pertama Anda!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.amber.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        final books = snapshot.data!;
                        return ListView.builder(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 100,
                          ),
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            return _buildBookCard(books[index], index);
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddEditBookScreen(),
              ),
            );
            if (result == true) {
              _refreshBooks();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Color(0xFF6B4423),
            size: 28,
          ),
        ),
      ),
    );
  }
}