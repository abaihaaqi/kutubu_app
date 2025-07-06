import 'package:flutter/material.dart';
import 'package:kutubu_app/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';
import '../widgets/book_card.dart';
import 'login_page.dart';
import 'book_form_page.dart';
import 'book_detail_page.dart';

Future<String?> getUsername() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('username');
}

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  String _username = "";
  List<Book> books = [];
  List<Book> filteredBooks = [];
  bool isLoading = true;
  String searchQuery = '';
  Map<String, List<Book>> groupedBooks = {};

  @override
  void initState() {
    super.initState();
    getUsername().then((value) {
      setState(() {
        _username = value ?? 'Guest';
      });
    });
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService().getBooks();
      setState(() {
        books = data.map((e) => Book.fromJson(e)).toList();
        filterBooks(); // Apply search filter
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat buku: $e')));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterBooks() {
    final filtered =
        books.where((book) {
          final query = searchQuery.toLowerCase();
          return book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query);
        }).toList();

    // Kelompokkan berdasarkan kategori
    final Map<String, List<Book>> grouped = {};
    for (var book in filtered) {
      final category = book.category != "" ? book.category : 'Lainnya';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(book);
    }

    setState(() {
      groupedBooks = grouped;
    });
  }

  Future<void> openBookForm({Book? book}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookFormPage(book: book)),
    );

    if (result == true) {
      fetchBooks();
    }
  }

  void logoutSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchBooks),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProfilePage(
                        username: _username,
                        totalBooks: books.length,
                        totalCategories: groupedBooks.length,
                      ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              logoutSuccess();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openBookForm(),
        child: const Icon(Icons.add),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Cari buku...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                        filterBooks();
                      },
                    ),
                  ),
                  Expanded(
                    child:
                        groupedBooks.isEmpty
                            ? const Center(child: Text('Tidak ada buku'))
                            : ListView(
                              children:
                                  groupedBooks.entries.map((entry) {
                                    final category = entry.key;
                                    final booksInCategory = entry.value;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            category,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ...booksInCategory.map(
                                          (book) => BookCard(
                                            book: book,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) => BookDetailPage(
                                                        book: book,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                  ),
                ],
              ),
    );
  }
}
