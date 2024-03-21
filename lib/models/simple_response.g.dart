// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleResponse _$SimpleResponseFromJson(Map<String, dynamic> json) =>
    SimpleResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] as String,
    );

Map<String, dynamic> _$SimpleResponseToJson(SimpleResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
