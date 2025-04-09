class Workout {
  final int id;
  List<(num, int)> sets = List.empty();
  final String date;

  Workout({required this.id, required this.date, required this.sets});
}
