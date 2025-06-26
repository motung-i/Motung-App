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
    // 이미지가 있는 경우 FormData 사용
    if (request.images.isNotEmpty) {
      final formData = FormData();

      // 이미지 파일 추가
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

      // 리뷰 데이터 추가
      formData.fields.add(
        MapEntry('request', jsonEncode(request.request.toJson())),
      );

      await dio.post(
        getUrl('/review'),
        data: formData,
      );
    } else {
      // 이미지가 없는 경우 일반 JSON 요청
      await dio.post(
        getUrl('/review'),
        data: request.request.toJson(),
      );
    }
  }
}
