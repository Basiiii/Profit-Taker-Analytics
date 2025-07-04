import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepLinkService {
  static Future<void> handleCommandLineArgs(List<String> args) async {
    _logToFile('DeepLinkService: Received ${args.length} command line arguments');
    if (kDebugMode) {
      print('DeepLinkService: Received ${args.length} command line arguments');
      for (int i = 0; i < args.length; i++) {
        print('DeepLinkService: arg[$i] = "${args[i]}"');
      }
    }
    
    if (args.isNotEmpty && args[0].startsWith('pta://')) {
      _logToFile('DeepLinkService: Found pta:// URL in arguments');
      if (kDebugMode) {
        print('DeepLinkService: Found pta:// URL in arguments');
      }
      await _handleDeepLink(args[0]);
    } else {
      _logToFile('DeepLinkService: No pta:// URL found in arguments');
      if (kDebugMode) {
        print('DeepLinkService: No pta:// URL found in arguments');
      }
    }
  }

  static Future<void> _handleDeepLink(String url) async {
    _logToFile('DeepLinkService: Handling deep link: $url');
    if (kDebugMode) {
      print('DeepLinkService: Handling deep link: $url');
    }

    final uri = Uri.parse(url);
    final deepLinkCode = uri.queryParameters['code'];
    
    _logToFile('DeepLinkService: Parsed URI: $uri');
    _logToFile('DeepLinkService: Code parameter: $deepLinkCode');
    if (kDebugMode) {
      print('DeepLinkService: Parsed URI: $uri');
      print('DeepLinkService: Code parameter: $deepLinkCode');
    }
    
    if (deepLinkCode != null) {
      await _handleOAuthCallback(uri);
    } else {
      _logToFile('DeepLinkService: No code parameter found in URL');
      if (kDebugMode) {
        print('DeepLinkService: No code parameter found in URL');
      }
    }
  }

  static Future<void> _handleOAuthCallback(Uri uri) async {
    _logToFile('DeepLinkService: Handling OAuth callback with Supabase');
    if (kDebugMode) {
      print('DeepLinkService: Handling OAuth callback with Supabase');
    }
    
    try {
      // Extract the code from the URI
      final code = uri.queryParameters['code'];
      if (code == null) {
        _logToFile('DeepLinkService: No code found in OAuth callback');
        return;
      }

      // Use the exchangeCodeForSession method which handles PKCE properly
      final response = await Supabase.instance.client.auth.exchangeCodeForSession(code);
      
      _logToFile('DeepLinkService: Exchange code result: ${response.session != null ? 'Session created' : 'No session created'}');
      if (kDebugMode) {
        print('DeepLinkService: Exchange code result: ${response.session != null ? 'Session created' : 'No session created'}');
      }
      
      if (response.session != null) {
        _logToFile('DeepLinkService: Login successful!');
        if (kDebugMode) {
          print('DeepLinkService: Login successful!');
        }
      } else {
        _logToFile('DeepLinkService: No session created from OAuth callback');
        if (kDebugMode) {
          print('DeepLinkService: No session created from OAuth callback');
        }
      }
    } catch (e) {
      _logToFile('DeepLinkService: Error handling OAuth callback: ${e.toString()}');
      if (kDebugMode) {
        print('DeepLinkService: Error handling OAuth callback: ${e.toString()}');
      }
    }
  }

  static void _logToFile(String message) {
    try {
      final logFile = File('/tmp/pta_deep_link.log');
      final timestamp = DateTime.now().toIso8601String();
      logFile.writeAsStringSync('[$timestamp] $message\n', mode: FileMode.append);
    } catch (e) {
      // Ignore logging errors
    }
  }
} 