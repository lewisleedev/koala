import 'package:koala/services/login.dart';

class UserStatus {
  bool isUsing;
  UserSeat? seat;

  UserStatus({required this.isUsing, this.seat});
}

class UserSeat {
  int idx;
  int seatCode;
  String seatName;
  int groupCode;
  String groupName;
  int confirmTime;
  int expireTime;
  int? outTime;
  int? inTime;
  int countDownTime;
  int state;

  UserSeat(
      {required this.idx,
      required this.seatCode,
      required this.seatName,
      required this.groupName,
      required this.groupCode,
      required this.confirmTime,
      required this.expireTime,
      this.outTime,
      this.inTime,
      required this.countDownTime,
      required this.state});
}

Future<UserStatus> getStatus() async {
  KoalaClient client = await newDioClient();
  const String statusUrl = "https://libseat.khu.ac.kr/user/my-status";

  try {
    final response = await client.dio.get(statusUrl);
    if (response.data["data"]["mySeat"] != null) {
      Map<dynamic, dynamic> data = response.data["data"]["mySeat"];
      return UserStatus(isUsing: true, seat: UserSeat(
        idx: data["idx"],
        confirmTime: data["confirmTime"],
        expireTime: data["expireTime"],
        outTime: data["outTime"],
        inTime: data["inTime"],
        countDownTime: data["countDownTime"],
        state: data["state"],
        seatCode: data["seat"]["code"],
        seatName: data["seat"]["name"],
        groupCode: data["seat"]["group"]["code"],
        groupName: data["seat"]["group"]["name"]
      ));
    } else {
      return UserStatus(isUsing: false);
    }
  } catch (e) {
    rethrow;
  }
}
