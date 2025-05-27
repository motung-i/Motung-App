// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_oauth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleOAuthLoginResponse _$GoogleOAuthLoginResponseFromJson(
        Map<String, dynamic> json) =>
    GoogleOAuthLoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$GoogleOAuthLoginResponseToJson(
        GoogleOAuthLoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };
