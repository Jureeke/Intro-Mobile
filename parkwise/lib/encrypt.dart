import 'dart:convert';

import 'package:crypto/crypto.dart';

class Encrypter{

  static const String salt = "tUlI!6xW_^NQ";

  static String encrypt(String password){
    final key = utf8.encode(password);
    final bytes = utf8.encode(salt);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }
}