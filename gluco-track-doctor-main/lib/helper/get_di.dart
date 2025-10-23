import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/notification_dot_controller.dart';
import '../controller/theme_controller.dart';
import '../service/handle_firebase_notification.dart';
import '../service/handle_local_notification.dart';

init() async {
  await Firebase.initializeApp();
  //await Firebase.initializeApp(options: IFirebaseOption.firebaseOption);
  await HandleFirebaseNotification.handleNotifications();
  await HandleLocalNotification.initializeFlutterNotification();
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put(NotificationDotController(), tag: "notification_dot", permanent: true);
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
}
