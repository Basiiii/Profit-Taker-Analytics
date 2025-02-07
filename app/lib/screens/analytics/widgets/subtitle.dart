import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_subtitle.dart';

class AnalyticsSubTitle extends StatelessWidget {
  const AnalyticsSubTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return HeaderSubtitle(
      text: FlutterI18n.translate(context, "analytics.title"),
    );
  }
}
