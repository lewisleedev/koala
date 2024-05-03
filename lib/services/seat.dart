import 'package:dio/dio.dart';
import 'package:koala/services/login.dart';
import 'package:koala/services/notification.dart';
import 'package:koala/services/status.dart';
import 'package:koala/services/utils.dart';
import 'package:mobx/mobx.dart';

import '../models/error_extension.dart';

Future<bool> leaveSeat(KoalaClient client, UserStatus status) async {
  int code = status.seat!.seatCode;
  final libStatusRes = await client.dio.post(
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
    NotifService().cancelUsageTimeNotif(); // No need to check for settings.
    return true;
  } else {
    return false;
  }
}

Future<List<Map<String, dynamic>>> fetchSeats(int roomCode) async {
  KoalaClient client = await newDioClient();
  final response = await client.dio
      .get('https://libseat.khu.ac.kr/libraries/seats/$roomCode');

  if (response.statusCode == 200) {
    List<Map<String, dynamic>> seats =
        List<Map<String, dynamic>>.from(response.data['data']);
    return seats;
  } else {
    throw Exception('Failed to load seats');
  }
}

Future<bool> tryExtendSeat(
    ObservableFuture<UserStatus>? status,
    ObservableFuture<List<dynamic>>? libraryStatus,
    ObservableMap<dynamic, dynamic> settings) async {
  try {
    UserStatus currentStatus = status?.result;
    List<dynamic> currLibStatus = libraryStatus?.result;
    KoalaClient client = await newDioClient();

    if (currentStatus.seat == null) {
      throw Exception("좌석 사용중이 아닙니다");
    }

    int? seatCode = currentStatus.seat?.seatCode;
    int? groupCode = currentStatus.seat?.groupCode;
    Map<dynamic, dynamic> myRoom = currLibStatus
        .firstWhere((item) => item["code"] == currentStatus.seat?.groupCode);
    int extndTime =
        calculateMaxReservationTimeFromNow(myRoom["startTm"], myRoom["endTm"], true);

    Map<String, dynamic> requestData = {
      "code": seatCode,
      "time": extndTime,
      "groupCode": groupCode,
      "beacon": [
        {"major": 1, "minor": 1}
      ]
    };

    final res = await client.dio.post(
      "https://libseat.khu.ac.kr/libraries/seat-extension",
      data: requestData,
    );

    if (res.data['data'] != 1) {
      throw extndErrorFromCode(res.data['data']);
    } else {
      if (settings['useNotif'] && extndTime == 240) {
        NotifService().cancelUsageTimeNotif();
        NotifService()
            .scheduleUsageTimeNotif(); // it overrides existing notification since it shares the same id
      }
      return true;
    }
  } catch (e) {
    rethrow;
  }
}
