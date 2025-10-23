import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:doctorapp/helper/route_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/sharedpreference_constants.dart';
import '../widget/toast_message.dart';

class PostService {
  static Future postReq(url, body) async {
    if (kDebugMode) {
      print("======Url==========");
      print(url);
      print("======Send Data==========");
      print(body);
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(SharedPreferencesConstants.token) ?? "";
    try {
      var dio = Dio();
      dio.options.headers["authorization"] = "Bearer $token";
      dio.options.headers["contentType"] = "application/x-www-form-urlencoded";
      dio.options.validateStatus = (status) {
        // Allow 200 and 401 status codes, so they don't throw exceptions
        return status! < 500;
      };
      final response = await dio.post(url, data: body);
      if (kDebugMode) {
        print("==========URL Response==========");
        print(response);
      }
      if (response.statusCode == 401) {
        IToastMsg.showMessage("Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.");
        logOut();
        return null;
      }
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.toString());
        if (kDebugMode) {
          print("==========Response==========");
          print(jsonData);
        }
        if (jsonData['response'] == 201) {
          if (jsonData['message'] == "error") {
            IToastMsg.showMessage("Đã xảy ra lỗi");
          } else {
            IToastMsg.showMessage(jsonData['message']);
          }
          return null;
        } else if (jsonData['response'] == 200) {
          return jsonData;
        }
      } else {
        IToastMsg.showMessage("Đã xảy ra lỗi");
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      IToastMsg.showMessage("Đã xảy ra lỗi");
      return null;
    }
  }

  static logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    IToastMsg.showMessage("Đăng xuất");
    Get.offAllNamed(RouteHelper.getLoginPageRoute());
  }
}
