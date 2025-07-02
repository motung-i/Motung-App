import 'package:json_annotation/json_annotation.dart';
import 'package:motunge/model/review/enum/report_reason.dart';

part 'report_request.g.dart';

@JsonSerializable()
class ReportRequest {
  final List<ReportReason> reasons;

  ReportRequest({
    required this.reasons,
  });

  factory ReportRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReportRequestToJson(this);
}
