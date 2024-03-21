import 'package:json_annotation/json_annotation.dart';
// Unused fields were purposefully unincluded.
part 'user_status.g.dart';

@JsonSerializable()
class UserStatus {
  int code;
  String message;
  Data data;

  UserStatus({required this.code, required this.message, required this.data});

  factory UserStatus.fromJson(Map<String, dynamic> json) => _$UserStatusFromJson(json);
}


@JsonSerializable()
class Data {
  MySeat? mySeat;
  Data({this.mySeat});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}

@JsonSerializable()
class MySeat {
  int idx;
  Seat seat;
  int confirmTime;
  int expireTime;
  int? outTime;
  int? inTime;
  int countDownTime;
  int state;
  String outType;
  dynamic outDoor;

  MySeat({
    required this.idx,
    required this.seat,
    required this.confirmTime,
    required this.expireTime,
    this.outTime,
    this.inTime,
    required this.countDownTime,
    required this.state,
    required this.outType,
  });

  factory MySeat.fromJson(Map<String, dynamic> json) => _$MySeatFromJson(json);
}

@JsonSerializable()
class Seat {
  int code;
  Group group;
  String name;

  Seat({required this.code, required this.group, required this.name});
  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);
}

@JsonSerializable()
class Group {
  int code;
  String name;
  String scCkYn; // Something about checking in...
  int scCkMi;

  Group({required this.code, required this.name, required this.scCkYn, required this.scCkMi});

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}