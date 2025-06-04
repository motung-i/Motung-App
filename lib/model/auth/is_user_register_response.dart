import 'package:json_annotation/json_annotation.dart';

part 'is_user_register_response.g.dart';

@JsonSerializable()
class IsUserRegisterResponse {
  @JsonKey(name: 'is_user_registered')
  final bool isUserRegistered;

  IsUserRegisterResponse({
    required this.isUserRegistered,
  });

  factory IsUserRegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$IsUserRegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$IsUserRegisterResponseToJson(this);
}
