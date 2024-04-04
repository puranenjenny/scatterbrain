import 'package:scatter_brain/database/daily_model.dart'; // daily luokka
import 'package:scatter_brain/database/task_model.dart'; // task luokka
import 'package:sqflite/sqflite.dart'; // sqflite kirjasto tietokannan käyttöön
import 'package:path/path.dart'; // path kirjasto


class DatabaseHelper { // tietokannan apuluokka
  static const int _version = 1; // tietokannan versio
  static const String _dbName = 'Task.db'; // tietokannan nimi

  static Future<Database> _getDB() async { // hae tietokanta funktio sqlitestä
    return openDatabase(join(await getDatabasesPath(), _dbName), // avaa tietokanta
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE Task(id INTEGER PRIMARY KEY, title TEXT NOT NULL, done INTEGER NOT NULL)",
        );
        await db.execute(
          "CREATE TABLE DailyTasks(id INTEGER PRIMARY KEY, title TEXT NOT NULL, done INTEGER NOT NULL, timeOfDay TEXT NOT NULL)",
        );
      },
      version: _version // versio
    );
  }

//task taulun funktiot

  static Future<int> addTask(Task task) async { // lisää tehtävä funktio
    final db = await _getDB(); // hae tietokanta
    return await db.insert('Task', task.toJson(), // lisää uusi tehtävä, json muodossa
    conflictAlgorithm: ConflictAlgorithm.replace); // huolehtii konflikteista
  }

  static Future<int> updateTask(Task task) async { // päivitä tehtävä funktio
    final db = await _getDB(); // hae tietokanta
    return await db.update('Task', task.toJson(), // päivitä tehtävä
    where: 'id = ?', // missä id on sama
    whereArgs: [task.id], // whereArgs sisältää task id:n, ei oteta suoraan injektioita
    conflictAlgorithm: ConflictAlgorithm.replace); // huolehtii konflikteista
  }

  static Future<int> deleteTask(int id) async { // poista tehtävä funktio
    final db = await _getDB(); // hae tietokanta
    return await db.delete( // poista tehtävä
      'Task', // taululta
      where: 'id = ?', // missä id on sama
      whereArgs: [id], 
    );
  }

  static Future<List<Task>?> getTasks() async { // hae tehtävät funktio
    final db = await _getDB(); // hae tietokanta
    
    final List<Map<String, dynamic>> maps = await db.query('Task', orderBy: 'id DESC'); // hae tehtävät tietokannasta ja järjestä id:n mukaan laskevasti eli uusin ylös

    if(maps.isEmpty) return null; // jos tehtävät ovat tyhjiä, palauta null

    return List.generate(maps.length, (index) => Task.fromJson(maps[index])); // palauta tehtävät listana
  }

  static Future<void> deleteSelectedTasks() async { // poista valitut tehtävät funktio
    final db = await _getDB();
    await db.delete('Task', where: 'done = ?', whereArgs: [1]); // SQLite käyttää 1 true arvona eli poistetaan tehtävät joissa done on 1
  }

//daily taulun funktiot

static Future<int> addDailyTask(Daily daily) async {
  final db = await _getDB();
  return await db.insert('DailyTasks', daily.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace);
}

static Future<int> updateDailyTask(Daily daily) async {
  final db = await _getDB();
  return await db.update('DailyTasks', daily.toJson(),
    where: 'id = ?', whereArgs: [daily.id],
    conflictAlgorithm: ConflictAlgorithm.replace);
}

static Future<int> deleteDailyTask(int id) async {
  final db = await _getDB();
  return await db.delete(
    'DailyTasks', where: 'id = ?', whereArgs: [id]);
}

static Future<List<Daily>?> getDailyTasks() async { // hae kaikki daily tehtävät
  final db = await _getDB();
  final List<Map<String, dynamic>> maps = await db.query('DailyTasks');

  if (maps.isEmpty) return null;

  return List.generate(maps.length, (index) {
    return Daily.fromJson(maps[index]);
  });
}

// daily tehtävien nollaus ja tarkistus

static Future<void> resetAllDailysToNotDone() async { // nollaa kaikki tehtävät joka päivä klo 5
  final Database db = await _getDB();
  await db.execute("UPDATE DailyTasks SET done = 0");
}

static Future<bool> areAllTasksDone() async { // tarkista onko kaikki tehtävät tehty, jotta voidaan päivittää kissakuvaa daily sivulla
  final Database db = await _getDB();
  final List<Map<String, dynamic>> tasks = await db.query('DailyTasks', where: 'done = 0');
  return tasks.isEmpty;
}

}