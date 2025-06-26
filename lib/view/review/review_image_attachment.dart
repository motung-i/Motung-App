import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:path/path.dart' as path;
import 'package:motunge/dataSource/review.dart';
import 'package:motunge/model/review/review_request.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/component/topbar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class ReviewImageAttachmentPage extends StatefulWidget {
  final String location;
  final bool isRecommend;
  final String description;

  const ReviewImageAttachmentPage({
    super.key,
    required this.location,
    required this.isRecommend,
    required this.description,
  });

  @override
  State<ReviewImageAttachmentPage> createState() =>
      _ReviewImageAttachmentPageState();
}

class _ReviewImageAttachmentPageState extends State<ReviewImageAttachmentPage> {
  final ReviewDataSource _reviewDataSource = ReviewDataSource();
  final List<File> _images = [];
  bool _isLoading = false;

  Future<void> _pickImage() async {
    if (_images.length >= 3) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);

      // HEIC 파일인지 확인 후 변환
      if (path.extension(image.path).toLowerCase() == '.heic' ||
          path.extension(image.path).toLowerCase() == '.heif') {
        try {
          // HEIC를 JPG로 변환
          String jpgPath = image.path.replaceAll(
              RegExp(r'\.(heic|heif)$', caseSensitive: false), '.jpg');
          String? convertedPath = await HeifConverter.convert(
            image.path,
            output: jpgPath,
          );
          if (convertedPath != null) {
            imageFile = File(convertedPath);
          } else {
            throw Exception('변환된 파일 경로가 null입니다');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('이미지 변환에 실패했습니다: $e')),
            );
          }
          return;
        }
      }

      setState(() {
        _images.add(imageFile);
      });
    }
  }

  Future<void> _submitReview() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = ReviewRequest(
        request: Request(
          isRecommend: widget.isRecommend,
          description: widget.description,
        ),
        images: _images,
      );

      await _reviewDataSource.writeReview(request);

      if (mounted) {
        context.go('/map');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰 작성에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Topbar(
              isSelectable: false,
              isPopAble: true,
              selectAbleText: null,
              text: "이미지 첨부",
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 28.h),
                    Text(
                      "이미지 추가",
                      style: GlobalFontDesignSystem.labelRegular
                          .copyWith(color: DiaryMainGrey.grey600),
                    ),
                    SizedBox(height: 8.h),
                    _buildImageSection(),
                    const Spacer(),
                    ButtonComponent(
                      isEnable: !_isLoading,
                      text: _isLoading ? "작성 중..." : "작성 완료",
                      onPressed: _submitReview,
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(
                _images.length,
                (index) => Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          _images[index],
                          width: 104.w,
                          height: 104.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_images.length < 3)
                GestureDetector(
                  onTap: _pickImage,
                  child: SvgPicture.asset(
                    "assets/images/add-image.svg",
                    width: 104.w,
                    height: 104.h,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "이미지는 최대 3개까지 업로드 할 수 있어요",
          style: GlobalFontDesignSystem.labelRegular
              .copyWith(color: DiaryMainGrey.grey600),
        ),
      ],
    );
  }
}
