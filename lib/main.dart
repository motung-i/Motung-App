import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motunge/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:motunge/bloc/auth/auth_bloc.dart';
import 'package:motunge/bloc/map/map_bloc.dart';
import 'package:motunge/bloc/review/review_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await FlutterNaverMap().init(
    clientId: 's8fd3gla1n',
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<MapBloc>(
          create: (context) => MapBloc(),
        ),
        BlocProvider<ReviewBloc>(
          create: (context) => ReviewBloc(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();

          return ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, child) {
              return MaterialApp.router(
                title: '모퉁이',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
                  scaffoldBackgroundColor: Colors.white,
                  useMaterial3: true,
                ),
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.createRouter(authBloc),
              );
            },
          );
        },
      ),
    );
  }
}
