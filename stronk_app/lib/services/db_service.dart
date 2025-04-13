import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stronk_app/models/exercise.dart';
import 'package:stronk_app/models/group.dart';
import 'package:stronk_app/models/workout.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  static Future<Database> _initDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    // deleteDatabase(
    //   join(databaseDirPath, "stronk_db.db"),
    // ); // remove after testing
    final databasePath = join(databaseDirPath, "stronk_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: createDatabase,
    );
    return database;
  }

  // -----------
  // GET METHODS
  // -----------
  Future<List<Group>> getGroups() async {
    final db = await database;
    final data = await db.rawQuery("SELECT * FROM MuscleGroups");
    List<Group> groups =
        data
            .map((e) => Group(id: e['id'] as int, name: e['name'] as String))
            .toList();
    return groups;
  }

  Future<List<Exercise>> getExercises(String target) async {
    final db = await database;
    final data = await db.rawQuery(
      '''
      SELECT e.id, e.name
      FROM Exercises e
      JOIN MuscleGroups g ON e.target=g.id
      WHERE g.name=?;
    ''',
      [target],
    );
    List<Exercise> exercises =
        data
            .map((e) => Exercise(id: e['id'] as int, name: e['name'] as String))
            .toList();
    return exercises;
  }

  Future<List<Workout>> getAllExerciseWorkouts(String exercise) async {
    final db = await database;
    final data = await db.rawQuery(
      '''
      SELECT w.id, w.timestamp, s.weight, s.reps
      FROM Sets s
      JOIN Workouts w ON w.id=s.workout_id
      JOIN Exercises e ON e.id=w.exercise_id
      WHERE e.name=?;
    ''',
      [exercise],
    );
    List<Workout> workouts = List.from([]);
    int workoutIndex;

    for (Map<String, Object?> s in data) {
      workoutIndex = workouts.indexWhere((w) => w.id == s['id'] as int);
      if (workoutIndex != -1) {
        workouts[workoutIndex].sets.add((s['weight'] as num, s['reps'] as int));
      } else {
        workouts.add(
          Workout(
            id: s['id'] as int,
            timestamp: s['timestamp'] as int,
            sets: List.from([(s['weight'] as num, s['reps'] as int)]),
          ),
        );
      }
    }
    return workouts;
  }

  // -----------
  // SET METHODS
  // -----------
  Future<bool> newGroup(String groupName) async {
    RegExp exp = RegExp(r'^[A-Z][a-z]*$');
    if (!exp.hasMatch(groupName)) {
      throw "Must be capitalized with latin letters";
    }
    if (groupName.length > 16) {
      throw "Cannot be more than 16 characters";
    }
    // Group name is suitable
    final Database db = await database;
    return await db.rawInsert(
          '''
      INSERT INTO MuscleGroups(name)
      VALUES(?);
    ''',
          [groupName],
        ) !=
        0;
  }

  Future<bool> newExercise(String groupName, String exerciseName) async {
    if (exerciseName.length > 30) {
      throw "Cannot be more than 30 characters";
    }
    // Exercise name is suitable
    final Database db = await database;
    final groupIdData = await db.rawQuery(
      '''
      SELECT id FROM MuscleGroups
      WHERE name = ?;
    ''',
      [groupName],
    );
    int groupId = groupIdData[0]['id'] as int;
    return await db.rawInsert(
          '''
      INSERT INTO Exercises(name, target)
      VALUES(?, ?);
    ''',
          [exerciseName, groupId],
        ) !=
        0;
  }

  Future<bool> newWorkout(String exercise, List<(num, int)> sets) async {
    if (sets.isEmpty) {
      return false;
    }
    final Database db = await database;
    final exerciseIdData = await db.rawQuery(
      '''
      SELECT id FROM Exercises
      WHERE name=?;
    ''',
      [exercise],
    );
    if (exerciseIdData.length != 1) {
      return false;
    }
    // Can add new workout
    int exerciseId = exerciseIdData[0]['id'] as int;
    int timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    try {
      db.transaction((txn) async {
        int workoutId = await txn.rawInsert(
          '''
          INSERT INTO Workouts (exercise_id, timestamp)
          VALUES(?, ?);
        ''',
          [exerciseId, timestamp],
        );
        if (workoutId == 0) {
          throw "Insert failed";
        }
        for (var (weight, reps) in sets) {
          txn.rawInsert(
            '''
            INSERT INTO Sets (weight, reps, workout_id)
            VALUES(?, ?, ?);
          ''',
            [weight, reps, workoutId],
          );
        }
      });
    } catch (e) {
      return false;
    }

    return true;
  }

  // --------------
  // DELETE METHODS
  // --------------
  Future<bool> removeWorkout(int id) async {
    final db = await database;
    try {
      db.transaction((txn) async {
        txn.rawDelete(
          '''
          DELETE FROM Workouts
          WHERE id = ?;
        ''',
          [id],
        );
      });
    } catch (e) {
      return false;
    }
    return true;
  }
}

// ----------------
// HELPER FUNCTIONS
// ----------------
Future<void> createDatabase(Database db, int version) async {
  print("create database");
  await db.execute('''
    CREATE TABLE IF NOT EXISTS Exercises(
      id integer primary key NOT NULL UNIQUE,
      name TEXT NOT NULL,
      target INTEGER NOT NULL,
    FOREIGN KEY(target) REFERENCES MuscleGroups(id)
    );
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS Sets(
      id integer primary key NOT NULL UNIQUE,
      weight REAL,
      reps INTEGER NOT NULL,
      workout_id INTEGER NOT NULL,
    FOREIGN KEY(workout_id) REFERENCES Workouts(id)
    );
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS Workouts(
      id integer primary key NOT NULL UNIQUE,
      exercise_id INTEGER NOT NULL,
      timestamp integer NOT NULL,
    FOREIGN KEY(exercise_id) REFERENCES Exercises(id)
    );
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS MuscleGroups(
      id integer primary key NOT NULL UNIQUE,
      name TEXT NOT NULL
    );
  ''');

  // REMOVE AFTER TESTING
  // .........

  // for (var name in ["Chest", "Triceps", "Biceps", "Shoulders"]) {
  //   await db.rawInsert("INSERT INTO MuscleGroups(name) VALUES(?);", [name]);
  // }

  // Map<String, int> groupIds = {};
  // final groupIdsData = await db.rawQuery("SELECT * FROM MuscleGroups");
  // for (var q in groupIdsData) {
  //   groupIds.addAll({q['name'] as String: q['id'] as int});
  // }

  // for (var exercise in ["Bench press", "Chest press machine"]) {
  //   await db.rawInsert(
  //     '''
  //     INSERT INTO Exercises(name, target)
  //     VALUES(?, ?);
  //   ''',
  //     [exercise, groupIds['Chest']],
  //   );
  // }

  // Map<String, int> exerciseIds = {};
  // final exerciseIdsData = await db.rawQuery("SELECT * FROM Exercises");
  // for (var q in exerciseIdsData) {
  //   exerciseIds.addAll({q['name'] as String: q['id'] as int});
  // }

  // for (int i in [1, 2, 3, 4, 5]) {
  //   int timestamp =
  //       (DateTime.parse("2025-04-0$i").millisecondsSinceEpoch / 1000).round();
  //   await db.rawInsert(
  //     '''
  //     INSERT INTO Workouts(id, exercise_id, timestamp)
  //     VALUES(?, ?, ?);
  //   ''',
  //     [i, exerciseIds['Bench press'], timestamp],
  //   );

  //   for (var (r, w) in [(6, 35.0), (5, 35.0), (1, 40.0)]) {
  //     await db.rawInsert(
  //       '''
  //       INSERT INTO Sets(weight, reps, workout_id)
  //       VALUES(?, ?, ?);
  //     ''',
  //       [w, r, i],
  //     );
  //   }
  // }
}
