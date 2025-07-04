import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepLinkService {
  static Future<void> handleCommandLineArgs(List<String> args) async {
    if (kDebugMode) {
      print('DeepLinkService: Received ${args.length} command line arguments');
      for (int i = 0; i < args.length; i++) {
        print('DeepLinkService: arg[$i] = "${args[i]}"');
      }
    }
    
    if (args.isNotEmpty && args[0].startsWith('pta://')) {
      if (kDebugMode) {
        print('DeepLinkService: Found pta:// URL in arguments');
      }
      await _handleDeepLink(args[0]);
    } else {
      if (kDebugMode) {
        print('DeepLinkService: No pta:// URL found in arguments');
      }
    }
  }

  static Future<void> _handleDeepLink(String url) async {
    if (kDebugMode) {
      print('DeepLinkService: Handling deep link: $url');
    }

    final uri = Uri.parse(url);
    final deepLinkCode = uri.queryParameters['code'];
    
    if (kDebugMode) {
      print('DeepLinkService: Parsed URI: $uri');
      print('DeepLinkService: Code parameter: $deepLinkCode');
    }
    
    if (deepLinkCode != null) {
      await _handleOAuthCallback(uri);
    } else {
      if (kDebugMode) {
        print('DeepLinkService: No code parameter found in URL');
      }
    }
  }

  static Future<void> _handleOAuthCallback(Uri uri) async {
    if (kDebugMode) {
      print('DeepLinkService: Handling OAuth callback with Supabase');
    }
    
    try {
      // Extract the code from the URI
      final code = uri.queryParameters['code'];
      if (code == null) {
        if (kDebugMode) {
          print('DeepLinkService: No code found in OAuth callback');
        }
        return;
      }

      // Use the exchangeCodeForSession method which handles PKCE properly
      final response = await Supabase.instance.client.auth.exchangeCodeForSession(code);
      
      if (kDebugMode) {
        print('DeepLinkService: Exchange code result: ${response.session != null ? 'Session created' : 'No session created'}');
      }
      
      if (response.session != null) {
        if (kDebugMode) {
          print('DeepLinkService: Login successful!');
        }
      } else {
        if (kDebugMode) {
          print('DeepLinkService: No session created from OAuth callback');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('DeepLinkService: Error handling OAuth callback: ${e.toString()}');
      }
    }
  }
} 