import 'package:json_annotation/json_annotation.dart';

part 'google_oauth_response.g.dart';

@JsonSerializable()
class GoogleOAuthLoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  GoogleOAuthLoginResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory GoogleOAuthLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$GoogleOAuthLoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleOAuthLoginResponseToJson(this);
}
