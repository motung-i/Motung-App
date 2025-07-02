// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apple_oauth_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppleOAuthLoginRequest _$AppleOAuthLoginRequestFromJson(
        Map<String, dynamic> json) =>
    AppleOAuthLoginRequest(
      identityToken: json['id_token'] as String,
      deviceToken: json['device_token'] as String?,
    );

Map<String, dynamic> _$AppleOAuthLoginRequestToJson(
        AppleOAuthLoginRequest instance) =>
    <String, dynamic>{
      'id_token': instance.identityToken,
      if (instance.deviceToken case final value?) 'device_token': value,
    };
