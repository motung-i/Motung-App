import 'package:json_annotation/json_annotation.dart';

part 'apple_oauth_request.g.dart';

@JsonSerializable()
class AppleOAuthLoginRequest {
  @JsonKey(name: 'id_token')
  final String identityToken;
  @JsonKey(name: 'device_token', includeIfNull: false)
  final String? deviceToken;

  AppleOAuthLoginRequest({
    required this.identityToken,
    this.deviceToken,
  });

  factory AppleOAuthLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$AppleOAuthLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AppleOAuthLoginRequestToJson(this);
}
