import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

String extractPublicKey(String jsCode) {
  RegExp pattern = RegExp(r"encrypt\.setPublicKey\('(.*)'\);");
  var matches = pattern.firstMatch(jsCode);
  if (matches == null) {
    throw Exception("Public key not found");
  }
  return matches.group(1)!;
}

String getMidUserID(String text) {
  RegExp pattern = RegExp(r'name="mid_user_id" value="([^"]+)"');
  var match = pattern.firstMatch(text);
  if (match == null) {
    throw Exception("mid_user_id not found");
  }
  return match.group(1)!;
}

String extractQRText(String code) {
  RegExp pattern = RegExp(r'text: "([^"]+)"');
  var match = pattern.firstMatch(code);
  if (match == null) {
    throw Exception("QR text not found");
  }
  return match.group(1)!;
}

String bakeCookie(String rawCookie) {
  int index = rawCookie.indexOf(';');
  var cookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
  return cookie;
}

Future<Map<String, dynamic>> encryptCred(String pubKey, String username, String password) async {
  final String pubKeyFormatted =
      "-----BEGIN PUBLIC KEY-----\n$pubKey\n-----END PUBLIC KEY-----";

  final byteId = utf8.encode(username);
  final bytePw = utf8.encode(password);
  final encId = await RSA.encryptPKCS1v15Bytes(byteId, pubKeyFormatted);
  final encPw = await RSA.encryptPKCS1v15Bytes(bytePw, pubKeyFormatted);

  final loginData = {
    "encId": base64Encode(encId),
    "encPw": base64Encode(encPw),
    "autoLoginChk": "N",
  };

  return loginData;
}

Future<Dio> newDioClient() async {
  Dio dio = Dio();
  dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
    final HttpClient client =
    HttpClient(context: SecurityContext(withTrustedRoots: false));
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  });
  return dio;
}

Future<CookieJar> setupCookieManager(Dio dio, {bool clean=false}) async {
  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  var cookieJar = PersistCookieJar(storage: FileStorage("${appDocumentsDir.path}/cookie"));
  if (clean) {
    await cookieJar.deleteAll();
  }
  dio.interceptors.add(CookieManager(cookieJar));
  return cookieJar;
}

void showSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

int minutesUntilMidnight() {
  DateTime now = DateTime.now();
  DateTime midnight = DateTime(now.year, now.month, now.day + 1);
  Duration difference = midnight.difference(now);
  return difference.inMinutes;
}
