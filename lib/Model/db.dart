// // import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DatabaseModel {
//   static final DatabaseModel databaseModel = DatabaseModel._internal();
//   static Database? _database;

//   DatabaseModel._internal();
//   factory DatabaseModel() => databaseModel;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDb();
//     return _database!;
//   }

//   Future<Database> _initDb() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'app_data.db');
//     print("Path is: $path");

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE if not exists pdf (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             courseId TEXT,
//             path TEXT,
//             createdAt TEXT
//           )
//         ''');
//       },
//     );
//   }

//   Future<void> insertPdf(dynamic pdf) async {
//     final db = await database;
//     await db.insert(
//       'pdf',
//       pdf,
//       conflictAlgorithm: ConflictAlgorithm.abort,
//     );
//   }

//   Future<dynamic> viewPdf() async {
//     final db = await database;
//     return await db.query('pdf');
//   }
// }
