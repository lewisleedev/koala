import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

Future<CookieJar> setCookieJar(Dio dio) async {
  final Directory cacheDir = await getApplicationCacheDirectory();
  var cookieJar = PersistCookieJar(storage: FileStorage("${cacheDir.path}/cookie"));
  dio.interceptors.add(CookieManager(cookieJar));

  return cookieJar;
}

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

DateTime convertEpochTime(int epochTime) {
  return DateTime.fromMillisecondsSinceEpoch(epochTime);
}

String dtToString(DateTime dt, {int type = 0}) {
  switch (type) {
    // Original plan was to make user decide how the datetime gets rendered but that's for later I guess...
    case 0:
      return "${dt.hour.toString().padLeft(2, '0')}시 ${dt.minute.toString().padLeft(2, '0')}분";
    default:
      return "${dt.hour.toString().padLeft(2, '0')}시 ${dt.minute.toString().padLeft(2, '0')}분";
  }
}

int calculateMaxReservationTimeFromNow(String startTm, String endTime, bool isExtension) {
  // This is the trickiest part of the code that I yet understand properly. I've tried my best to test as many edge cases as possible but probably failed to do so.
  // If you have some idea how it actually should work, please let me know :)

  DateTime now = DateTime.now();
  int currentHour = now.hour;
  int currentMinute = now.minute;

  if (isExtension) {
    // Somehow extension and reservation works differently.
    currentMinute = (currentMinute ~/ 30) * 30;
  } else {
    if (currentMinute % 30 != 0) {
      currentMinute = ((currentMinute ~/ 30) + 1) * 30;
      if (currentMinute >= 60) {
        currentMinute -= 60;
        currentHour += 1;
      }
    }
  }
  if (startTm == "0000" && endTime == "0000") {
    return 240; // Return the maximum allowed duration of 240 minutes
  }
  int endHour = endTime == "0000" ? 24 : int.parse(endTime.substring(0, 2));
  int endMinute = endTime == "0000" ? 0 : int.parse(endTime.substring(2, 4));
  int endTimeInMinutes = endHour * 60 + endMinute;
  int currentTimeInMinutes = currentHour * 60 + currentMinute;
  int duration = endTimeInMinutes - currentTimeInMinutes;
  if (duration < 0) {
    duration += 24 * 60; // Adjust for passing midnight
  }
  int maxDuration = 240;
  int allowedDuration = duration > maxDuration ? maxDuration : duration;
  int result = max((allowedDuration ~/ 30) * 30, 30);
  return result;
}

String parseImagePath(String path) {
  List<String> parts = path.split('/');
  return parts.last;
}

bool containsKeyValue(List<dynamic> list, String key, dynamic value) {
  return list.any((map) => map[key] == value);
}