import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookApiService {
  static const String baseUrl = 'http://localhost:5000';

  static Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  static Future<void> createBook(Book book) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(book.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create book');
    }
  }

  static Future<void> updateBook(Book book) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/${book.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(book.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update book');
    }
  }

  static Future<void> deleteBook(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/books/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete book');
    }
  }
}
