import 'package:flutter/material.dart';
import 'screens/book_list_screen.dart';
import 'db/book_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BookDatabase.instance.initDB(); // Pastikan DB siap sebelum app jalan

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyBookShelf',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const BookListScreen(),
    );
  }
}
