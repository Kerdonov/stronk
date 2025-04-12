import 'package:flutter/material.dart';
import 'package:stronk_app/models/group.dart';
import 'package:stronk_app/pages/exercises.dart';
import 'package:stronk_app/services/db_service.dart';
import 'package:stronk_app/widgetbuilders/dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final fieldKey = GlobalKey<FormState>();

  final DatabaseService _databaseService = DatabaseService.instance;
  late Widget groupList;

  @override
  void initState() {
    super.initState();
    groupList = buildGroupList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stronk")),
      body: groupList,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showPostDialog(
            context,
            "New exercise group",
            "Group name",
            (groupName) {
              _databaseService.newGroup(groupName);
              setState(() {
                groupList = buildGroupList();
              });
            },
            (name) {
              RegExp exp = RegExp(r'^[A-Z][a-z]*$');
              if (!exp.hasMatch(name ?? "")) {
                return "Must be capitalized with latin letters";
              }
              if ((name ?? "").length > 16) {
                return "Cannot be more than 16 characters";
              }
              return null;
            },
          );
        },
        child: const Text("+", style: TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget buildGroupList() {
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
