import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context,
  String question,
) async {
  return showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(question),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("No, wait!"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Sure"),
            ),
          ],
        ),
  );
}
