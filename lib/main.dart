import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:walking/Controllers/busDataController.dart';
import 'package:walking/Controllers/shareController.dart';
import 'package:walking/Controllers/userDataController.dart';
import 'package:walking/pages/allFunctionsPage.dart';
import 'package:walking/pages/busSelectionPage.dart';
import 'package:walking/pages/homePage.dart';
import 'package:walking/pages/leaderListPage.dart';
import 'package:walking/pages/loginPage.dart';
import 'package:walking/pages/notePage.dart';
import 'package:walking/pages/scanPage.dart';
import 'package:walking/pages/splashPage.dart';
import 'package:walking/pages/studentListPage.dart';
import 'package:walking/pages/widgetsPage.dart';
import 'package:walking/root.dart';
import 'package:walking/Controllers/authController.dart';
import 'package:rive/rive.dart';
import 'datas.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: 'a1c9777515879c04248d1ba76bfc85c0',
    javaScriptAppKey: '4de65029b745f6837a1e3766011d40c9',
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(AuthService());
  Get.put(AuthViewModel(), permanent: true);
  Get.put(UserDataService());
  Get.put(CommonUserDataViewModel(), permanent: true);
  Get.put(CurrentUserDataViewModel(), permanent: true);
  Get.put(BusDataService());
  Get.put(BusDataViewModel(), permanent: true);
  Get.put(ShareController());
  // RiveFile.initializeText();
  // RiveFile.asset('assets/videos/logoAnim.riv');
  // await RiveFile.initialize();
  // print(await KakaoSdk.origin);
  // rootBundle.load('assets/videos/logoAnim.riv');
  runApp(const MyApp());
  //
  // print(await KakaoSdk.origin);
  // ShareController.to.share(await KakaoSdk.origin);

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: ColorDatas.onBackgroundSoft),
          scrolledUnderElevation: 0,
        ),
        scaffoldBackgroundColor: ColorDatas.background,
      ),
      title: "Pull ups",
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/', page: () => RootPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/widgets', page: () => WidgetsPage()),
        GetPage(name: '/splash', page: () => SplashPage()),
        GetPage(name: '/busSelection', page: () => BusSelectionPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/scan', page: () => ScanPage()),
        GetPage(name: '/studentList', page: () => StudentListPage()),
        GetPage(name: '/note', page: () => NotePage()),
        GetPage(name: '/allFunctions', page: () => AllFunctionsPage()),
        GetPage(name: '/leaderList', page: () => LeaderListPage()),
      ],
    );
  }
}
