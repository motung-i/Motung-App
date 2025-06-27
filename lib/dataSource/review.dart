import 'package:motunge/dataSource/base_data_source.dart';
import 'package:motunge/model/review/reviews_response.dart';
import 'package:motunge/model/review/review_request.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ReviewDataSource extends BaseDataSource {
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
      getUrl('/review'),
      queryParameters: queryParams,
    );

    return ReviewsResponse.fromJson(response.data);
  }

  Future<ReviewsResponse> getOwnReviews() async {
    final response = await dio.get(getUrl('/review/myself'));
    return ReviewsResponse.fromJson(response.data);
  }

  Future<void> writeReview(ReviewRequest request) async {
    final formData = FormData();

    // 이미지 파일 추가 (있는 경우만)
    if (request.images.isNotEmpty) {
      for (var image in request.images) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }
    }

    // 리뷰 데이터를 JSON blob으로 추가
    final requestJson = jsonEncode(request.request.toJson());
    formData.files.add(
      MapEntry(
        'request',
        MultipartFile.fromString(
          requestJson,
          contentType: DioMediaType.parse('application/json'),
        ),
      ),
    );

    await dio.post(
      getUrl('/review'),
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }
}
