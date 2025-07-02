import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff222222).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 63.h),
                Text(
                  "여긴 어때요?",
                  style: GlobalFontDesignSystem.m2Regular
                      .copyWith(color: Colors.white),
                ),
                Text(
                  "전주, 한옥마을",
                  style: GlobalFontDesignSystem.h4Semi
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          _bottomSheet(),
        ],
      ),
    );
  }

  Widget _bottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.052,
      maxChildSize: 0.35,
      minChildSize: 0.052,
      controller: sheetController,
      builder: (BuildContext context, scrollController) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffEFF0F2),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                    height: 4,
                    width: 80,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("전주, 한옥마을", style: GlobalFontDesignSystem.m3Semi),
                      SizedBox(height: 4.h),
                      Text(
                        "1910년 조성되기 시작한 우리나라 근대 주거문화 발달과정의 중요한 공간으로, 경기전, 오목대, 향교 등 중요 문화재와 20여개의 문화시설이 산재되어 있으며, 한옥, 한식, 한지, 한소리, 한복, 한방 등 韓스타일이 집약된 대한민국 대표 여행지입니다.",
                        style: GlobalFontDesignSystem.m3Regular,
                      ),
                      SizedBox(height: 24.h),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Container(
                      //       width: 163.w,
                      //       height: 146.h,
                      //       decoration: BoxDecoration(
                      //         color: Color(0xffd9d9d9),
                      //         borderRadius:
                      //             BorderRadius.all(Radius.circular(8)),
                      //       ),
                      //       child: Image.asset(
                      //         "assets/images/music-recommend.png",
                      //       ),
                      //     ),
                      //     Container(
                      //       width: 163.w,
                      //       height: 146.h,
                      //       decoration: BoxDecoration(
                      //         color: Color(0xffd9d9d9),
                      //         borderRadius:
                      //             BorderRadius.all(Radius.circular(8)),
                      //       ),
                      //       child: Image.asset(
                      //         "assets/images/item-recommend.png",
                      //       ),
                      //     )
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
