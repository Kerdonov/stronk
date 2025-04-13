import 'package:flutter/material.dart';

void showPostDialog(
  BuildContext context,
  String title,
  String hint,
  Function onSubmit,
  FormFieldValidator<String?> validatorFunction,
) {
  showDialog(
    context: context,
    builder:
        (BuildContext context) => StatefulBuilder(
          builder: (context, setState) {
            final inputController = TextEditingController();
            final fieldKey = GlobalKey<FormState>();

            return SimpleDialog(
              title: Text(title),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: fieldKey,
                    child: TextFormField(
                      controller: inputController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: const OutlineInputBorder(),
                      ),
                      validator: validatorFunction,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                ),
                TextButton(
                  child: const Text("Add"),
                  onPressed: () {
                    if (fieldKey.currentState!.validate()) {
                      onSubmit(inputController.text);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        ),
  );
}
