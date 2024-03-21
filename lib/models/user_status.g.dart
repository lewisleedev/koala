// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStatus _$UserStatusFromJson(Map<String, dynamic> json) => UserStatus(
      code: json['code'] as int,
      message: json['message'] as String,
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserStatusToJson(UserStatus instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      mySeat: json['mySeat'] == null
          ? null
          : MySeat.fromJson(json['mySeat'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'mySeat': instance.mySeat,
    };

MySeat _$MySeatFromJson(Map<String, dynamic> json) => MySeat(
      idx: json['idx'] as int,
      seat: Seat.fromJson(json['seat'] as Map<String, dynamic>),
      confirmTime: json['confirmTime'] as int,
      expireTime: json['expireTime'] as int,
      outTime: json['outTime'] as int?,
      inTime: json['inTime'] as int?,
      countDownTime: json['countDownTime'] as int,
      state: json['state'] as int,
      outType: json['outType'] as String,
    )..outDoor = json['outDoor'];

Map<String, dynamic> _$MySeatToJson(MySeat instance) => <String, dynamic>{
      'idx': instance.idx,
      'seat': instance.seat,
      'confirmTime': instance.confirmTime,
      'expireTime': instance.expireTime,
      'outTime': instance.outTime,
      'inTime': instance.inTime,
      'countDownTime': instance.countDownTime,
      'state': instance.state,
      'outType': instance.outType,
      'outDoor': instance.outDoor,
    };

Seat _$SeatFromJson(Map<String, dynamic> json) => Seat(
      code: json['code'] as int,
      group: Group.fromJson(json['group'] as Map<String, dynamic>),
      name: json['name'] as String,
    );

Map<String, dynamic> _$SeatToJson(Seat instance) => <String, dynamic>{
      'code': instance.code,
      'group': instance.group,
      'name': instance.name,
    };

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      code: json['code'] as int,
      name: json['name'] as String,
      scCkYn: json['scCkYn'] as String,
      scCkMi: json['scCkMi'] as int,
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'scCkYn': instance.scCkYn,
      'scCkMi': instance.scCkMi,
    };
