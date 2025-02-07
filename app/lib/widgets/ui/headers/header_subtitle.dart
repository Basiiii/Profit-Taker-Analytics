import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/utils/text/text_utils.dart';

// TODO: document
class HeaderSubtitle extends StatelessWidget {
  final String text;

  const HeaderSubtitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return buildSubtitle(text);
  }
}
