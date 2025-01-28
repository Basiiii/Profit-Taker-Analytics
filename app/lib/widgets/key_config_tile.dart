import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class KeyConfigTile extends AbstractSettingsTile {
  final String title;
  final String keyLabel;
  final bool waitingForKey;
  final VoidCallback onStartListening;

  const KeyConfigTile({
    super.key,
    required this.title,
    required this.keyLabel,
    required this.waitingForKey,
    required this.onStartListening,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (waitingForKey)
            Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(5),
              child: const CircularProgressIndicator(
                backgroundColor: Color(0xFF86BCFC),
                color: Colors.grey,
                strokeWidth: 4,
              ),
            ),
          if (waitingForKey) const SizedBox(width: 10),
          Text(keyLabel),
        ],
      ),
      onPressed: (BuildContext context) => onStartListening(),
    );
  }
}
