import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'utils.dart';

const String loginPageUrl = "https://lib.khu.ac.kr/login";
const String libSeatUrl = "https://libseat.khu.ac.kr";
const String libSeatLoginUrl = "$libSeatUrl/login_library";

class KoalaClient {
  final Dio dio;
  final CookieJar cookieJar;
  KoalaClient({required this.dio, required this.cookieJar});
}

Future<KoalaClient> newDioClient() async {
  Dio dio = Dio();
  dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
    final HttpClient client =
    HttpClient(context: SecurityContext(withTrustedRoots: false));
    client.badCertificateCallback = (cert, host, port) => true; // Sorry I still have to do this
    return client;
  });
  CookieJar cookieJar = await setCookieJar(dio);
  return KoalaClient(dio: dio, cookieJar: cookieJar);
}

Future<Map<String, dynamic>> requestLogin(String username, String password, String studentId, KoalaClient client) async {
  try {
    final result = await checkLoginOrFetchKey(client.dio);
    if (result['alreadyLoggedIn']) {
      await copyCookie(client.cookieJar);
      await loginLibSeat(studentId, client.dio);
      return {"result": 2, "msg": "already logged in"};
    }
    final loginResult = await attemptLogin(client.dio, username, password, result['encryptionKey']);
    if (loginResult['result'] == 1 || loginResult["result"] == 2) {
      await copyCookie(client.cookieJar);
      await loginLibSeat(studentId, client.dio);
    }
    return loginResult;
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    rethrow;
  }
}

Future<void> copyCookie(CookieJar cookieJar) async {
  List<Cookie> jSessionIdCookie = await cookieJar.loadForRequest(Uri.parse(loginPageUrl));
  await cookieJar.saveFromResponse(Uri.parse(libSeatUrl), jSessionIdCookie);
}

Future<Map<String, dynamic>> checkLoginOrFetchKey(Dio dio) async {
  late Response response;
  try {
    response = await dio.get(loginPageUrl, options: Options(followRedirects: false, validateStatus: (status) => status! < 400));
  } catch (e) {
    rethrow;
  }
  if (response.statusCode == 302) {
    return {'alreadyLoggedIn': true};
  } else if (response.statusCode == 200) {
    String encryptionKey = extractPublicKey(response.data); // Restored original function call
    return {'alreadyLoggedIn': false, 'encryptionKey': encryptionKey};
  } else {
    throw Exception('Error fetching login page or encryption key');
  }
}

Future<Map<String, dynamic>> attemptLogin(Dio dio, String username, String password, String encryptionKey) async {
  Map<String, dynamic> loginData = await encryptCred(encryptionKey, username, password); // Restored original function call
  try {
    final loginResponse = await dio.post(
      loginPageUrl,
      options: Options(followRedirects: true, validateStatus: (status) => status! < 400),
      data: FormData.fromMap(loginData),
    );
    if (loginResponse.statusCode == 302) {
      return {"result": 1, "msg": "login successful"};
    } else {
      throw Exception('Login failed');
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> loginLibSeat(String studentId, Dio dio) async {
  final formData = {"STD_ID": studentId};
  final loginResponse = await dio.post(
    libSeatLoginUrl,
    options: Options(followRedirects: false, validateStatus: (status) => status! < 400),
    data: FormData.fromMap(formData),
  );

  if (loginResponse.statusCode != 302 || loginResponse.headers['set-cookie'] == null) {
    throw Exception("libseat login failed or CLI_SID not found");
  }
}