// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_oauth_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleOAuthLoginRequest _$GoogleOAuthLoginRequestFromJson(
        Map<String, dynamic> json) =>
    GoogleOAuthLoginRequest(
      accessToken: json['access_token'] as String,
      deviceToken: json['device_token'] as String?,
    );

Map<String, dynamic> _$GoogleOAuthLoginRequestToJson(
        GoogleOAuthLoginRequest instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      if (instance.deviceToken case final value?) 'device_token': value,
    };
