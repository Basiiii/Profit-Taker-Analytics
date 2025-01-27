import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<bool> isAppIntegrityValid() async {
  // Get the path of the current executable
  var mainPath = Platform.resolvedExecutable;
  mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
  var exePath = "$mainPath\\profit_taker_analyzer.exe";

  // Read the .exe file
  final fileBytes = await File(exePath).readAsBytes();

  // Calculate the hash of the .exe file
  var digest = sha256.convert(fileBytes);
  final localHash = digest.toString();

  // Fetch the hash from the server
  final response =
      await http.get(Uri.parse('https://basi.is-a.dev/secure/verify.json'));
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data.containsKey('hashes') && data['hashes'] is List) {
      // Iterate over the list of hashes from the server
      for (var serverHashBase64 in data['hashes']) {
        // Ensure serverHashBase64 is a string before decoding
        if (serverHashBase64 is String) {
          Uint8List scrambledBytes = base64Decode(serverHashBase64);

          const key =
              '8dee0b852296008c1312713746b17916783e880f6f2f9fec902fb7c3cf5f9cbe';
          Uint8List originalBytes = descrambleHash(scrambledBytes, key);

          // Convert the original hash bytes to a hexadecimal string
          String originalHashHex = originalBytes
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join();

          // Compare the original hash hex with the local hash hex
          if (originalHashHex == localHash) {
            return true;
          }
        }
      }
      // If none of the hashes match, return false
      return false;
    } else {
      return false;
    }
  } else {
    // Handle the error (e.g., log it, show an error message, etc.)
    if (kDebugMode) {
      print('Failed to fetch hash: ${response.statusCode}');
    }
    return false;
  }
}

Uint8List descrambleHash(Uint8List scrambledBytes, String key) {
  List<int> keyBytes = utf8.encode(key);
  List<int> originalBytes = List<int>.generate(scrambledBytes.length, (i) {
    return scrambledBytes[i] ^ keyBytes[i % keyBytes.length];
  });
  return Uint8List.fromList(originalBytes);
}

Future<void> confirmVerification(bool verification) async {
  if (verification == true) {
    if (kDebugMode) {
      print("All good.");
    }
  } else {
    exit(0);
  }
}
