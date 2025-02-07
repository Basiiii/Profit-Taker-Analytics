import 'package:url_launcher/url_launcher.dart';

/// Launches a URL.
///
/// Parses the provided URL and checks if it can be launched.
/// If it can be launched, it does so. Otherwise, it throws an error.
void launchURL(String url) async {
  final Uri parsedUrl = Uri.parse(url);
  if (await canLaunchUrl(parsedUrl)) {
    await launchUrl(parsedUrl);
  } else {
    throw 'Could not launch $url';
  }
}
