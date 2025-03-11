import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              image: AssetImage('assets/images/bg.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              _bottomSheet(),
            ],
          )),
    );
  }

  _bottomSheet() => DraggableScrollableSheet(
        initialChildSize: 0.25,
        maxChildSize: 0.8,
        minChildSize: 0.25,
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
                        color: Colors.indigo,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0), // 좌우 패딩 추가
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 정렬 조정 가능
                      children: [
                        ListTile(
                          leading: Icon(Icons.star),
                          title: Text('Item 1'),
                        ),
                        ListTile(
                          leading: Icon(Icons.star),
                          title: Text('Item 2'),
                        ),
                        ListTile(
                          leading: Icon(Icons.star),
                          title: Text('Item 3'),
                        ),
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
