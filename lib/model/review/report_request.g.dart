// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportRequest _$ReportRequestFromJson(Map<String, dynamic> json) =>
    ReportRequest(
      reasons: (json['reasons'] as List<dynamic>)
          .map((e) => $enumDecode(_$ReportReasonEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$ReportRequestToJson(ReportRequest instance) =>
    <String, dynamic>{
      'reasons':
          instance.reasons.map((e) => _$ReportReasonEnumMap[e]!).toList(),
    };

const _$ReportReasonEnumMap = {
  ReportReason.PERSONAL_INFORMATION: 'PERSONAL_INFORMATION',
  ReportReason.PROMOTION: 'PROMOTION',
  ReportReason.ABUSE: 'ABUSE',
  ReportReason.SENSATIONALISM: 'SENSATIONALISM',
  ReportReason.ETC: 'ETC',
};
