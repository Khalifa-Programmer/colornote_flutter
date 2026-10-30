import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('colornote_kitetech_merged.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id TEXT PRIMARY KEY,
        nameAr TEXT NOT NULL,
        nameEn TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        type INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL,
        note TEXT NOT NULL,
        checklist_json TEXT,
        drawing_json TEXT,
        images_json TEXT,
        folder_id TEXT DEFAULT 'important',
        color_index INTEGER NOT NULL DEFAULT 2,
        custom_color INTEGER,
        paper_tint REAL DEFAULT 0.84,
        style_json TEXT,
        created_date INTEGER NOT NULL,
        modified_date INTEGER NOT NULL,
        reminder_date INTEGER DEFAULT 0,
        checked INTEGER NOT NULL DEFAULT 0,
        locked INTEGER NOT NULL DEFAULT 0,
        status INTEGER NOT NULL DEFAULT 0,
        widget_pinned INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Seed default KiteTech folders
    final defaultFolders = [
      const FolderModel(id: 'book_list', nameAr: 'قائمة الكتب', nameEn: 'Book list'),
      const FolderModel(id: 'important', nameAr: 'هام', nameEn: 'Important'),
      const FolderModel(id: 'quotes', nameAr: 'اقتباسات', nameEn: 'Quotes'),
      const FolderModel(id: 'todo_lists', nameAr: 'قوائم المهام', nameEn: 'To do lists'),
      const FolderModel(id: 'travel', nameAr: 'السفر', nameEn: 'Travel'),
    ];
    for (final f in defaultFolders) {
      await db.insert('folders', f.toMap());
    }
  }

  Future<List<FolderModel>> fetchFolders() async {
    final db = await instance.database;
    final rows = await db.query('folders');
    return rows.map((r) => FolderModel.fromMap(r)).toList();
  }

  Future<void> insertFolder(FolderModel folder) async {
    final db = await instance.database;
    await db.insert('folders', folder.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertNote(NoteModel note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toSqlMap());
  }

  Future<List<NoteModel>> fetchAllNotes() async {
    final db = await instance.database;
    final maps = await db.query('notes', orderBy: 'modified_date DESC');
    return maps.map((e) => NoteModel.fromSqlMap(e)).toList();
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toSqlMap(),
      where: '_id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNotePermanently(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: '_id = ?', whereArgs: [id]);
  }
}
