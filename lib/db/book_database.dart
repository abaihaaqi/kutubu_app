import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class BookDatabase {
  static final BookDatabase instance = BookDatabase._init();

  static Database? _database;

  BookDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE books (
      id $idType,
      title $textType,
      author $textType,
      year $intType,
      category $textType,
      cover TEXT
    )
    ''');
  }

  Future<void> initDB() async {
    await database;
  }

  Future<Book> create(Book book) async {
    final db = await instance.database;
    final id = await db.insert('books', book.toMap());
    return book..id = id;
  }

  Future<Book?> readBook(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'books',
      columns: ['id', 'title', 'author', 'year', 'category', 'cover'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Book>> readAllBooks() async {
    final db = await instance.database;

    final orderBy = 'title ASC';
    final result = await db.query('books', orderBy: orderBy);

    return result.map((map) => Book.fromMap(map)).toList();
  }

  Future<int> update(Book book) async {
    final db = await instance.database;

    return db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
