import 'package:flutter/material.dart';
import 'package:stronk_app/models/group.dart';
import 'package:stronk_app/pages/exercises.dart';
import 'package:stronk_app/services/db_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stronk")),
      body: groupList(),
    );
  }

  Widget groupList() {
    return FutureBuilder(
      future: _databaseService.getGroups(),
      builder:
          (context, snapshot) => ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              Group group = snapshot.data![index];
              return TextButton(
                child: ListTile(title: Text(group.name)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExercisePage(groupName: group.name),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
