import 'dart:io';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:motunge/bloc/review/review_event.dart';
import 'package:motunge/bloc/review/review_state.dart';
import 'package:motunge/dataSource/map.dart';
import 'package:motunge/dataSource/review.dart';
import 'package:motunge/model/review/reviews_response.dart';
import 'package:motunge/model/review/review_request.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewBlocState> {
  final MapDataSource _mapDataSource = MapDataSource();
  final ReviewDataSource _reviewDataSource = ReviewDataSource();
  Timer? _debounceTimer;

  ReviewBloc() : super(const ReviewInitial()) {
    on<ReviewRegionsRequested>(_onRegionsRequested);
    on<ReviewsRequested>(_onReviewsRequested);
    on<ReviewFilterChanged>(_onFilterChanged);
    on<ReviewTabChanged>(_onTabChanged);
    on<ReviewReportRequested>(_onReportRequested);
    on<ReviewRefreshRequested>(_onRefreshRequested);
    on<MyReviewsRequested>(_onMyReviewsRequested);
    on<MyReviewsRefreshRequested>(_onMyReviewsRefreshRequested);
    on<ReviewWriteRequested>(_onReviewWriteRequested);
  }

  Future<void> _onRegionsRequested(
    ReviewRegionsRequested event,
    Emitter<ReviewBlocState> emit,
  ) async {
    emit(const ReviewLoading());

    try {
      final regionsData = await _mapDataSource.getRegions();

      // 초기 상태 설정
      final Map<String, List<Review>> reviewsByRegion = {};
      final Map<String, bool> isLoadingByRegion = {};
      final Map<String, bool> isInitializedByRegion = {};

      for (var region in regionsData.regions) {
        reviewsByRegion[region] = [];
        isLoadingByRegion[region] = false;
        isInitializedByRegion[region] = false;
      }

      final initialState = ReviewsLoaded(
        reviewsByRegion: reviewsByRegion,
        isLoadingByRegion: isLoadingByRegion,
        isInitializedByRegion: isInitializedByRegion,
        regions: regionsData.regions,
        currentTabIndex: 0,
        showPhotoReviewsOnly: false,
        searchQuery: '',
      );

      emit(initialState);

      if (regionsData.regions.isNotEmpty) {
        add(ReviewsRequested(region: regionsData.regions[0]));
      }
    } catch (e) {
      emit(ReviewError(message: '지역 정보를 불러오는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onReviewsRequested(
    ReviewsRequested event,
    Emitter<ReviewBlocState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReviewsLoaded) return;

    // forceReload가 true가 아닌 경우, 이미 초기화되었거나 로딩 중인 경우 요청하지 않음
    if (!event.forceReload) {
      final isInitialized =
          currentState.isInitializedByRegion[event.region] ?? false;
      final isLoading = currentState.isLoadingByRegion[event.region] ?? false;

      if (isInitialized || isLoading) return;
    }

    final updatedIsLoadingByRegion =
        Map<String, bool>.from(currentState.isLoadingByRegion);
    updatedIsLoadingByRegion[event.region] = true;

    emit(currentState.copyWith(isLoadingByRegion: updatedIsLoadingByRegion));

    try {
      final response = await _reviewDataSource.getReviews(
        region: event.region,
        onlyByImage: event.onlyByImage,
        localAlias: event.localAlias,
      );

      final updatedReviewsByRegion =
          Map<String, List<Review>>.from(currentState.reviewsByRegion);
      final updatedIsInitializedByRegion =
          Map<String, bool>.from(currentState.isInitializedByRegion);
      updatedIsLoadingByRegion[event.region] = false;

      updatedReviewsByRegion[event.region] = response.reviews;
      updatedIsInitializedByRegion[event.region] = true;

      emit(currentState.copyWith(
        reviewsByRegion: updatedReviewsByRegion,
        isLoadingByRegion: updatedIsLoadingByRegion,
        isInitializedByRegion: updatedIsInitializedByRegion,
      ));
    } catch (e) {
      updatedIsLoadingByRegion[event.region] = false;
      emit(currentState.copyWith(isLoadingByRegion: updatedIsLoadingByRegion));
      emit(ReviewError(message: '리뷰를 불러오는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onFilterChanged(
    ReviewFilterChanged event,
    Emitter<ReviewBlocState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReviewsLoaded) return;

    // 디바운싱 - 이전 타이머 취소
    _debounceTimer?.cancel();

    final updatedState = currentState.copyWith(
      showPhotoReviewsOnly: event.showPhotoReviewsOnly,
      searchQuery: event.searchQuery,
    );

    emit(updatedState);

    // 500ms 디바운싱 적용 (검색어 입력 시)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // emit 대신 새로운 이벤트 추가
      if (!emit.isDone) {
        add(ReviewsRequested(
          region: event.region,
          onlyByImage: event.showPhotoReviewsOnly,
          localAlias: event.searchQuery.isNotEmpty ? event.searchQuery : null,
          forceReload: true,
        ));
      }
    });
  }

  Future<void> _onTabChanged(
    ReviewTabChanged event,
    Emitter<ReviewBlocState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReviewsLoaded) return;

    final updatedState = currentState.copyWith(currentTabIndex: event.tabIndex);
    emit(updatedState);

    // 해당 지역이 이미 초기화되었는지 확인
    final isInitialized =
        updatedState.isInitializedByRegion[event.region] ?? false;
    final isLoading = updatedState.isLoadingByRegion[event.region] ?? false;

    // 이미 초기화되었거나 로딩 중이면 요청하지 않음
    if (!isInitialized && !isLoading) {
      add(ReviewsRequested(
        region: event.region,
        onlyByImage: updatedState.showPhotoReviewsOnly,
        localAlias: updatedState.searchQuery.isNotEmpty
            ? updatedState.searchQuery
            : null,
      ));
    }
  }

  Future<void> _onReportRequested(
    ReviewReportRequested event,
    Emitter<ReviewBlocState> emit,
  ) async {
    final currentState = state;

    try {
      await _reviewDataSource.reportReview(event.reviewId, event.reasons);

      if (currentState is ReviewsLoaded) {
        emit(currentState.copyWith(showReportSuccess: true));
        await Future.delayed(const Duration(milliseconds: 100));
        emit(currentState.copyWith(showReportSuccess: false));
      } else {
        emit(const ReviewReportSuccess());
      }
    } catch (e) {
      emit(ReviewError(message: '신고 처리 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onRefreshRequested(
    ReviewRefreshRequested event,
    Emitter<ReviewBlocState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReviewsLoaded) return;

    add(ReviewsRequested(
      region: event.region,
      onlyByImage: event.onlyByImage,
      localAlias: event.localAlias,
      forceReload: true,
    ));
  }

  Future<void> _onMyReviewsRequested(
    MyReviewsRequested event,
    Emitter<ReviewBlocState> emit,
  ) async {
    emit(const MyReviewsLoading());

    try {
      final response = await _reviewDataSource.getOwnReviews();
      emit(MyReviewsLoaded(myReviews: response.reviews));
    } catch (e) {
      emit(MyReviewsError(message: '내가 쓴 리뷰를 불러오는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onMyReviewsRefreshRequested(
    MyReviewsRefreshRequested event,
    Emitter<ReviewBlocState> emit,
  ) async {
    emit(const MyReviewsLoading());

    try {
      final response = await _reviewDataSource.getOwnReviews();
      emit(MyReviewsLoaded(myReviews: response.reviews));
    } catch (e) {
      emit(MyReviewsError(message: '내가 쓴 리뷰를 새로고침하는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onReviewWriteRequested(
    ReviewWriteRequested event,
    Emitter<ReviewBlocState> emit,
  ) async {
    emit(const ReviewWriteLoading());

    try {
      final imageFiles = event.imagePaths.map((path) => File(path)).toList();

      final request = ReviewRequest(
        request: Request(
          isRecommend: event.isRecommend,
          description: event.description,
        ),
        images: imageFiles,
      );

      await _reviewDataSource.writeReview(request);
      emit(const ReviewWriteSuccess());
    } catch (e) {
      emit(ReviewWriteError(message: '리뷰 작성 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
