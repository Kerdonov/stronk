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
    print("init database");
    final databaseDirPath = await getDatabasesPath();
    deleteDatabase(
      join(databaseDirPath, "stronk_db.db"),
    ); // remove after testing
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

  Future<List<Exercise>> getExercises(String mainTarget) async {
    final db = await database;
    final data = await db.rawQuery('''
      SELECT e.id, e.name, g2.name as "secTarget"
      FROM Exercises e
      JOIN MuscleGroups g1 ON e.mainTarget=g1.id
      JOIN MuscleGroups g2 ON e.secondaryTarget=g2.id
      WHERE g1.name='$mainTarget';
    ''');
    List<Exercise> exercises =
        data
            .map(
              (e) => Exercise(
                id: e['id'] as int,
                name: e['name'] as String,
                secondaryTarget: e['secTarget'] as String,
              ),
            )
            .toList();
    return exercises;
  }

  Future<List<Workout>> getAllExerciseWorkouts(String exercise) async {
    final db = await database;
    final data = await db.rawQuery('''
      SELECT w.id, w.day, s.weight, s.reps
      FROM Sets s
      JOIN Workouts w ON w.id=s.workout_id
      JOIN Exercises e ON e.id=w.exercise_id
      WHERE e.name='$exercise';
    ''');
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
            date: s['day'] as String,
            sets: List.from([(s['weight'] as num, s['reps'] as int)]),
          ),
        );
      }
    }
    return workouts;
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
      name TEXT NOT NULL UNIQUE,
      mainTarget INTEGER NOT NULL,
      secondaryTarget INTEGER,
    FOREIGN KEY(mainTarget) REFERENCES MuscleGroups(id),
    FOREIGN KEY(secondaryTarget) REFERENCES MuscleGroups(id)
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
      day TEXT NOT NULL,
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

  for (var name in [
    "Chest",
    "Triceps",
    "Biceps",
    "Shoulders",
    "Back",
    "Glutes",
    "Legs",
    "Core",
  ]) {
    await db.execute("INSERT INTO MuscleGroups(name) VALUES('$name');");
  }

  Map<String, int> groupIds = Map();
  final groupIdsData = await db.rawQuery("SELECT * FROM MuscleGroups");
  for (var q in groupIdsData) {
    groupIds.addAll({q['name'] as String: q['id'] as int});
  }

  for (var (exercise, sec) in [
    ("Bench press", "Triceps"),
    ("Chest press machine", "Shoulders"),
  ]) {
    await db.execute('''
      INSERT INTO Exercises(name, mainTarget, secondaryTarget)
      VALUES('$exercise', ${groupIds['Chest']}, ${groupIds[sec]});
    ''');
  }

  print(groupIds);

  Map<String, int> exerciseIds = Map();
  final exerciseIdsData = await db.rawQuery("SELECT * FROM Exercises");
  for (var q in exerciseIdsData) {
    exerciseIds.addAll({q['name'] as String: q['id'] as int});
  }

  print(exerciseIds);

  for (int i in [1, 2, 3, 4, 5]) {
    await db.execute('''
      INSERT INTO Workouts(id, exercise_id, day)
      VALUES($i, ${exerciseIds['Bench press']}, '0$i-04-2025');
    ''');

    for (var (r, w) in [(6, 35.0), (5, 35.0), (1, 40.0)]) {
      await db.execute('''
        INSERT INTO Sets(weight, reps, workout_id)
        VALUES($w, $r, $i);
      ''');
    }
  }

  print(await db.rawQuery("SELECT * FROM Workouts"));
}
