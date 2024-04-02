import 'package:sqflite/sqflite.dart'; // sqflite kirjasto tietokannan käyttöön
import 'package:path/path.dart'; // path kirjasto
import 'package:scatter_brain/oliot/task_model.dart'; // task luokka

class DatabaseHelper { // tietokannan apuluokka
  static const int _version = 1; // tietokannan versio
  static const String _dbName = 'tasks.db'; // tietokannan nimi

  static Future<Database> _getDB() async { // hae tietokanta funktio sqlitestä
    return openDatabase(join(await getDatabasesPath(), _dbName), // avaa tietokanta
      onCreate: (db, version) async => // kun luodaan tietokanta
      await db.execute("CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT NOT NULL, done BOOLEAN)"), // luodaan taulu
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

    static Future<int> deleteTask(Task task) async { // poista tehtävä funktio
    final db = await _getDB(); 
    return await db.delete('Task', // poista tehtävä
    where: 'id = ?', 
    whereArgs: [task.id],);
  }

  static Future<List<Task>?> getTasks() async { // hae tehtävät funktio
    final db = await _getDB(); // hae tietokanta
    
    final List<Map<String, dynamic>> maps = await db.query('Task'); // hae tehtävät

    if(maps.isEmpty) return null; // jos tehtävät on tyhjät palauta null

    else {
      return List.generate(maps.length, (index) => Task.fromJson(maps[index])); // muodosta lista tehtävistä
    }

  }
}