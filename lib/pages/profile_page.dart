import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  final int totalBooks;
  final int totalCategories;

  const ProfilePage({
    super.key,
    required this.username,
    required this.totalBooks,
    required this.totalCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👤 Username: $username',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '📚 Total Buku: $totalBooks',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              '🏷️ Kategori Tersimpan: $totalCategories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
