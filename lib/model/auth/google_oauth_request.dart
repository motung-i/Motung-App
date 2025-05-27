import 'package:json_annotation/json_annotation.dart';

part 'google_oauth_request.g.dart';

@JsonSerializable()
class GoogleOAuthLoginRequest {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'device_token', includeIfNull: false)
  final String? deviceToken;

  GoogleOAuthLoginRequest({
    required this.accessToken,
    this.deviceToken,
  });

  factory GoogleOAuthLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$GoogleOAuthLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleOAuthLoginRequestToJson(this);
}
