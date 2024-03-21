import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:june/june.dart';
import 'package:koala/main.dart';
import 'package:koala/models/user_status.dart';
import 'package:koala/services/data.dart';
import 'package:koala/services/status.dart';
import 'utils.dart';
import 'package:dio/dio.dart';

const String loginPageUrl = "https://lib.khu.ac.kr/login";
const String libSeatUrl = "https://libseat.khu.ac.kr";
const String libSeatLoginUrl = "$libSeatUrl/login_library";

Future<Map<String, dynamic>> requestLogin(String username, String password, String studentId, Dio dio, CookieJar cookieJar) async {
  try {
    final result = await checkLoginOrFetchKey(dio);
    if (result['alreadyLoggedIn']) {
      await copyCookie(cookieJar);
      await loginLibSeat(studentId, dio);
      return {"result": 2, "msg": "already logged in"};
    }

    final loginResult = await attemptLogin(dio, username, password, result['encryptionKey']);
    if (loginResult['result'] == 1) {
      await copyCookie(cookieJar);
      await loginLibSeat(studentId, dio);
    }
    return loginResult;
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    return {'result': 0, 'msg': "Failed to authenticate"};
  }
}

Future<void> copyCookie(CookieJar cookieJar) async {
  List<Cookie> jSessionIdCookie = await cookieJar.loadForRequest(Uri.parse(loginPageUrl));
  await cookieJar.saveFromResponse(Uri.parse(libSeatUrl), jSessionIdCookie);
}

Future<Map<String, dynamic>> checkLoginOrFetchKey(Dio dio) async {
  final response = await dio.get(loginPageUrl, options: Options(followRedirects: false, validateStatus: (status) => status! < 400));
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

Future<Map<String, dynamic>> loginHandler(String username, String password, String studentId) async {
  var session = June.getState(KoalaSessionVM());
  Dio dio = session.dio;
  CookieJar cookieJar = session.cookieJar;
  var box = await openSafeBox();
  try {
    final Map<String, dynamic> _ = await requestLogin(username, password, studentId, dio, cookieJar);
    await copyCookie(cookieJar);
    final UserStatus statusResult = await getStatus(dio);
    if (statusResult.data != null) {
      box.put("credentials", {
        "username": username,
        "password": password,
        "studentId": studentId
      });
      return {'result': 1, 'msg': "Login and status check successful", 'status': statusResult};
    } else {
      return {'result': 0, 'msg': "Login successful but status check failed", 'status': statusResult};
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    return {'result': -1, 'msg': "Failed to authenticate or status check", 'error': e.toString()};
  }
}

Future<int> refreshLogin() async {
  /// Returns less than 0 when login was successful.
  /// Returns 2 if there is no credentials provided
  var session = June.getState(KoalaSessionVM());
  session.initialize();
  Dio dio = session.dio;

  final result = await checkLoginOrFetchKey(dio);
  if (result['alreadyLoggedIn']) {
    return -1;
  }
  var credentials = session.box.get('credentials');
  if (credentials == null) {
    return 2;
  }
  var res = await loginHandler(credentials["username"], credentials["password"], credentials["studentId"]);
  session.setState();
  if (res['result'] != 1) {
    return 1;
  } else {
    return 0;
  }
}

Future<Dio> getSessionClient() async {
  var session = June.getState(KoalaSessionVM());
  final Dio dio = session.dio;
  return dio;
}