import 'package:sqflite/sqflite.dart'; // sqflite kirjasto tietokannan käyttöön
import 'package:path/path.dart'; // path kirjasto
import 'package:scatter_brain/database/task_model.dart'; // task luokka

class DatabaseHelper { // tietokannan apuluokka
  static const int _version = 1; // tietokannan versio
  static const String _dbName = 'Task.db'; // tietokannan nimi

  static Future<Database> _getDB() async { // hae tietokanta funktio sqlitestä
    return openDatabase(join(await getDatabasesPath(), _dbName), // avaa tietokanta
      onCreate: (db, version) async => // kun luodaan tietokanta
      await db.execute("CREATE TABLE Task(id INTEGER PRIMARY KEY, title TEXT NOT NULL, done INTEGER NOT NULL)"), // luodaan taulu
      version: _version // versio
    );
  }

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
    
    final List<Map<String, dynamic>> maps = await db.query('Task', orderBy: 'id DESC'); // hae tehtävät tietokannasta ja järjestä id:n mukaan laskevasti

    if(maps.isEmpty) return null; // jos tehtävät ovat tyhjiä, palauta null

    return List.generate(maps.length, (index) => Task.fromJson(maps[index])); // palauta tehtävät listana
  }

  static Future<void> deleteSelectedTasks() async { // poista valitut tehtävät funktio
    final db = await _getDB();
    await db.delete('Task', where: 'done = ?', whereArgs: [1]); // SQLite käyttää 1 true arvona eli poistetaan tehtävät joissa done on 1
  }

}