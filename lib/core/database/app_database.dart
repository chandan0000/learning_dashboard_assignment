import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  const AppDatabase._();

  static const _fileName = 'learning_dashboard.db';
  static const _version = 1;

  static const coursesTable = 'courses';
  static const lessonsTable = 'lessons';

  static Future<Database> open({DatabaseFactory? factory, String? path}) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath =
        path ?? p.join(await dbFactory.getDatabasesPath(), _fileName);

    return dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) => _createSchema(db),
      ),
    );
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE $coursesTable (
        id         INTEGER PRIMARY KEY,
        title      TEXT    NOT NULL,
        instructor TEXT    NOT NULL,
        position   INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $lessonsTable (
        id           INTEGER NOT NULL,
        course_id    INTEGER NOT NULL
                     REFERENCES $coursesTable(id) ON DELETE CASCADE,
        title        TEXT    NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        position     INTEGER NOT NULL,
        PRIMARY KEY (course_id, id)
      )
    ''');
  }
}
