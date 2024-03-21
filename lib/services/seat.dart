import 'dart:math';

import 'package:dio/dio.dart';
import 'package:june/june.dart';
import 'package:koala/main.dart';
import 'package:koala/models/user_status.dart';
import 'package:koala/services/status.dart';
import 'package:koala/services/utils.dart';
import 'package:koala/widgets/user_status_widget.dart';

import 'login.dart';

Future<List<Map<String, dynamic>>> fetchSeats(int roomCode) async {
  var session = June.getState(KoalaSessionVM());
  Dio dio = session.dio;

  final response =
      await dio.get('https://libseat.khu.ac.kr/libraries/seats/$roomCode');

  session.setState();
  if (response.statusCode == 200) {
    List<Map<String, dynamic>> seats =
        List<Map<String, dynamic>>.from(response.data['data']);
    return seats;
  } else {
    throw Exception('Failed to load seats');
  }
}

Future<bool> setSeat(int seatCode, int roomCode) async {
  var session = June.getState(KoalaSessionVM());
  await session.refreshSession();
  Dio dio = session.dio;

  int useTime = 0;

  if (roomCode == 1) {
    useTime = 240;
  } else {
    useTime = min(minutesUntilMidnight(), 240);
  }

  var seatData = {"seatId": seatCode, "time": useTime};

  final res = await dio.post(
    "https://libseat.khu.ac.kr/libraries/seat",
    data: seatData,
  );

  if (res.statusCode == 200) {
    if (res.data["data"] != 1) {
      return false;
    } else {
      return true;
    }
  } else {
    throw Exception("Setting failed");
  }
}

Future<bool> extendSeat() async {
  var session = June.getState(KoalaSessionVM());
  var userStatus = June.getState(UserStatusVM());
  await session.refreshSession();
  Dio dio = session.dio;

  var statusRes = userStatus.status;
  int extndTime = 0;
  if (statusRes?.data.mySeat == null) {
    throw Exception("Not using any seat");
  }
  int? seatCode = statusRes?.data.mySeat?.seat.code;
  int? groupCode = statusRes?.data.mySeat?.seat.group.code;

  if (groupCode == 1) {
    extndTime = 240;
  } else {
    extndTime = min(minutesUntilMidnight(), 240);
  }

  Map<String, dynamic> requestData = {
    "code": seatCode,
    "time": extndTime,
    "groupCode": groupCode,
    "beacon": [
      {"major": 1, "minor": 1}
    ]
  };
  final res = await dio.post(
    "https://libseat.khu.ac.kr/libraries/seat-extension",
    data: requestData,
  );

  if (res.data['data'] != 1) {
    throw Exception("Something went wrong: ${res.data['data']}");
  } else {
    return true;
  }
}

Future<bool> leaveSeat() async {
  var session = June.getState(KoalaSessionVM());
  var userStatus = June.getState(UserStatusVM());
  UserStatus? status = userStatus.status;
  var code = status?.data.mySeat?.seat.code.toString();
  final libStatusRes = await session.dio.post(
    "https://libseat.khu.ac.kr/libraries/leave/$code",
    options: Options(
      followRedirects: false,
      validateStatus: (status) => status == 200,
    ),
  );
  if (libStatusRes.data['code'] != 1) {
    throw Exception("Error while leaving seat");
  }

  if (libStatusRes.data['message'] == "SUCCESS") {
    return true;
  } else {
    return false;
  }
}
