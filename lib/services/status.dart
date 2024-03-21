import 'package:dio/dio.dart';
import 'package:koala/models/user_status.dart';
import 'package:koala/services/login.dart';

Future<UserStatus> getStatus(Dio dio) async {
  const String statusUrl = "https://libseat.khu.ac.kr/user/my-status";

  try {
    final response = await dio.get(statusUrl);
    UserStatus result = UserStatus.fromJson(response.data);
    return result;
  } catch (e){
    throw Exception("Incorrect status: check student id");
  }
}

Future<UserStatus> statusHandler() async {
  Dio dio = await getSessionClient();
  UserStatus res = await getStatus(dio);
  return res;
}