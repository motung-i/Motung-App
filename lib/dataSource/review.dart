import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:motunge/model/review/enum/report_reason.dart';
import 'package:motunge/model/review/reviews_response.dart';
import 'package:motunge/network/dio.dart';

class ReviewDataSource {
  final dio = AppDio.getInstance();

  Future<ReviewsResponse> getReviews({
    String? country,
    String? region,
    String? district,
    String? neighborhood,
    bool? onlyByImage,
    String? localAlias,
  }) async {
    final queryParams = <String, dynamic>{};

    if (country != null) {
      queryParams['country'] = country;
    }
    if (region != null) {
      queryParams['region'] = region;
    }
    if (district != null) {
      queryParams['district'] = district;
    }
    if (neighborhood != null) {
      queryParams['neighborhood'] = neighborhood;
    }
    if (onlyByImage != null) {
      queryParams['onlyByImage'] = onlyByImage.toString();
    }
    if (localAlias != null) {
      queryParams['localAlias'] = localAlias;
    }

    final response = await dio.get(
      '${dotenv.env['API_URL']}/review',
      queryParameters: queryParams,
    );

    return ReviewsResponse.fromJson(response.data);
  }

  Future<ReviewsResponse> getOwnReviews() async {
    final response = await dio.get('${dotenv.env['API_URL']}/review/myself');
    return ReviewsResponse.fromJson(response.data);
  }

  Future<void> writeReview(List<ReportReason> reason) async {
    await dio.post('${dotenv.env['API_URL']}/review/myself',
        data: {'reason': reason.toString()});
  }
}
