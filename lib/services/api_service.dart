import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kutubu_app/models/book_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final baseUrl = dotenv.env['BASE_URL']!;

class ApiService {
  Future<void> register(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode != 201) throw Exception('Register failed');
  }

  Future<void> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', body['token']);
      await prefs.setString('username', username);
    } else {
      throw Exception('Login failed');
    }
  }

  Future<List<dynamic>> getBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await http.get(
      Uri.parse('$baseUrl/books'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(res.body);
  }

  Future<void> createBook(Map<String, dynamic> book, [File? coverImage]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/books'))
      ..headers['Authorization'] = 'Bearer $token';

    // Tambahkan semua field sebagai string
    book.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (coverImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('cover_image', coverImage.path),
      );
    }

    final response = await request.send();
    if (response.statusCode != 201) {
      final resBody = await response.stream.bytesToString();
      throw Exception('Gagal menambahkan buku: $resBody');
    }
  }

  Future<Book> updateBook(
    int id,
    Map<String, dynamic> book, [
    File? coverImage,
  ]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/books/$id'))
      ..headers['Authorization'] = 'Bearer $token';

    book.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (coverImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('cover_image', coverImage.path),
      );
    }

    final response = await request.send();

    final resBody = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui buku: $resBody');
    }

    // ✨ Ubah respons JSON menjadi objek Book
    final data = jsonDecode(resBody);
    return Book.fromJson(data);
  }

  Future<void> deleteBook(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    await http.delete(
      Uri.parse('$baseUrl/books/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
