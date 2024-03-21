import 'package:json_annotation/json_annotation.dart';

part 'simple_response.g.dart';

@JsonSerializable()
class SimpleResponse {
  int code;
  String message;
  String data;
  SimpleResponse({required this.code, required this.message, required this.data});

  factory SimpleResponse.fromJson(Map<String, dynamic> json) => _$SimpleResponseFromJson(json);
}
