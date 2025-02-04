import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> editRunNameDialog(
  BuildContext context,
  TextEditingController controller,
  String hintText,
  String changeRunNameText,
  String cancelText,
  String okText,
  Function(String) updateCallback,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(changeRunNameText),
        content: TextField(
          controller: controller,
          maxLength: 20,
          maxLengthEnforcement:
              MaxLengthEnforcement.truncateAfterCompositionEnds,
          decoration: InputDecoration(hintText: hintText),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(cancelText),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(okText),
            onPressed: () {
              String newName = controller.text;
              updateCallback(newName);
              if (!context.mounted) return;
              Navigator.pop(context);
              controller.clear();
            },
          ),
        ],
      );
    },
  );
}
