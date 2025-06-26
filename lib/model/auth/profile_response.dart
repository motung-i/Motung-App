import 'package:json_annotation/json_annotation.dart';
import 'package:motunge/model/auth/enum/user_role.dart';
part 'profile_response.g.dart';

@JsonSerializable()
class ProfileResponse {
  @JsonKey(name: 'nickname')
  final String nickname;
  @JsonKey(name: 'role')
  final UserRole role;

  ProfileResponse({
    required this.nickname,
    required this.role,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}
