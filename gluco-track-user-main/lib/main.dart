import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import './utilities/app_constans.dart';
import 'controller/theme_controller.dart';
import 'helpers/get_di.dart' as di;
import 'helpers/route_helper.dart';
import 'theme/dark_theme.dart';
import 'theme/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Set the color here
      statusBarIconBrightness: Brightness.light, // For light or dark icons
      statusBarBrightness: Brightness.dark, // For iOS (light or dark status bar background)
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetMaterialApp(
        title: AppConstants.appName,
        initialRoute:
            RouteHelper.getSplashPageRoute(), //RouteHelper.getOnBoardingPageRoute(),//LoginPage(),
        debugShowCheckedModeBanner: false,
        theme: themeController.darkTheme ? dark : light,
        getPages: RouteHelper.routes,
      );
    });
  }
}
