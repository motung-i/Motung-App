import 'package:json_annotation/json_annotation.dart';

part 'oauth_response.g.dart';

@JsonSerializable()
class OAuthLoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  OAuthLoginResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory OAuthLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$OAuthLoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OAuthLoginResponseToJson(this);
}
