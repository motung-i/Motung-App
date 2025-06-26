// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponse _$ProfileResponseFromJson(Map<String, dynamic> json) =>
    ProfileResponse(
      nickname: json['nickname'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$ProfileResponseToJson(ProfileResponse instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'role': _$UserRoleEnumMap[instance.role]!,
    };

const _$UserRoleEnumMap = {
  UserRole.ROLE_PENDING: 'ROLE_PENDING',
  UserRole.ROLE_USER: 'ROLE_USER',
  UserRole.ROLE_ADMIN: 'ROLE_ADMIN',
  UserRole.ROLE_REMOVED: 'ROLE_REMOVED',
};
