import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message, {int duration = 2}) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: Duration(seconds: duration),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<bool?> askConfirmation(BuildContext context, String prompt) async {
  bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('확인'),
        content: Text(prompt),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('네'),
          ),
        ],
      );
    },
  );
  if (confirmed == null) {
    return false;
  } else {
    return confirmed;
  }
}

Color invertColor(Color color) => Color.fromARGB(color.alpha, 255 - color.red, 255 - color.green, 255 - color.blue);