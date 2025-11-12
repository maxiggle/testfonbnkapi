import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

class AuthenticationRepository {
  AuthenticationRepository({
    required String clientId,
    required String clientSecret,
  }) : _clientId = clientId,
       _clientSecret = clientSecret,
       _logger = Logger();
  final Logger _logger;
  final String _clientId;
  final String _clientSecret;

  String generateFonBnkCredentials({
    required String timestamp,
    required String endpoint,
  }) {
    _logger.i('Generating HMAC signature for $endpoint');

    final List<int> secretKey = lenientBase64Decode(_clientSecret);
    Hmac hmacSha256 = Hmac(sha256, secretKey);
    String data = '$timestamp:$endpoint';
    Digest digest = hmacSha256.convert(utf8.encode(data));

    final String signature = base64Encode(digest.bytes);
    _logger.i('Generated HMAC signature for $endpoint: $signature');
    return signature;
  }

  Map<String, String> generateHeaders({required String endpoint}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = generateFonBnkCredentials(
      timestamp: timestamp,
      endpoint: endpoint,
    );

    return {
      'Content-Type': 'application/json',
      'x-client-id': _clientId,
      'x-timestamp': timestamp,
      'x-signature': signature,
    };
  }

  String get clientId => _clientId;

  List<int> lenientBase64Decode(String input) {
    const String base64Chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    String sanitizedInput = input.replaceAll(RegExp(r'[^A-Za-z0-9+/]'), '');
    List<int> buffer = [];
    int bits = 0;
    int bitsCount = 0;

    for (int i = 0; i < sanitizedInput.length; i++) {
      int val = base64Chars.indexOf(sanitizedInput[i]);
      if (val < 0) {
        continue;
      }
      bits = (bits << 6) | val;
      bitsCount += 6;
      if (bitsCount >= 8) {
        bitsCount -= 8;
        int byte = (bits >> bitsCount) & 0xFF;
        buffer.add(byte);
      }
    }

    return buffer;
  }
}
