import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/notification_dot_controller.dart';
import '../helper/date_time_helper.dart';
import '../helper/route_helper.dart';
import '../model/user_model.dart';
import '../service/user_service.dart';
import '../utilities/api_content.dart';
import '../utilities/app_constans.dart';
import '../utilities/colors_constant.dart';
import '../utilities/image_constants.dart';
import '../widget/toast_message.dart';
import 'image_box_widget.dart';

class IDrawerWidget {
  buildDrawerWidget(UserModel? userModel, NotificationDotController notificationDotController) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const SizedBox(height: 40),
          userModel == null ? Container() : _buildProfileSection(userModel),
          const SizedBox(height: 10),
          _buildCardBox("Đơn thuốc", Icons.support_agent, () {
            Get.back();
            Get.toNamed(RouteHelper.getPrescriptionPageRoute());
          }),
          _buildNotificationCardBox(notificationDotController, "Thông báo", Icons.notifications,
              () async {
            Get.back();
            Get.toNamed(RouteHelper.getNotificationPageRoute());
          }),
          const SizedBox(height: 10),
          _buildCardBox("Liên hệ chúng tôi", Icons.support_agent, () {
            Get.back();
            Get.toNamed(RouteHelper.getContactUsPageRoute());
          }),
          _buildCardBox("Chia sẻ", Icons.share, () {
            Get.back();
            Get.toNamed(RouteHelper.getShareAppPageRoute());
          }),
          const Divider(),
          _buildCardBox("Về chúng tôi", Icons.info, () {
            Get.back();
            Get.toNamed(RouteHelper.getAboutUsPageRoute());
          }),
          _buildCardBox("Chính sách bảo mật", Icons.link, () async {
            Get.back();
            Get.toNamed(RouteHelper.getPrivacyPagePageRoute());
          }),
          _buildCardBox("Điều khoản & Điều kiện", Icons.link, () async {
            Get.back();
            Get.toNamed(RouteHelper.getTermCondPageRoute());
          }),
          const Divider(),
          _buildCardBox("Đăng xuất", Icons.power_settings_new, () async {
            final res = await UserService.logOutUser();
            if (res != null) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              IToastMsg.showMessage("Đã đăng xuất");
              Get.offAllNamed(RouteHelper.getLoginPageRoute());
            }
          }),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Phiên bản - ${Platform.isAndroid ? AppConstants.appVersion : AppConstants.appVersionIOS}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }

  static _buildProfileSection(UserModel userModel) {
    return SizedBox(
      height: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: ClipOval(
                    child: userModel.imageUrl == null || userModel.imageUrl == ""
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: ColorResources.primaryColor,
                          )
                        : ImageBoxFillWidget(
                            imageUrl: "${ApiContents.imageUrl}/${userModel.imageUrl}")),
              ),
              Row(children: [
                Image.asset(ImageConstants.crownImage, width: 40, height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: ColorResources.containerBgColor,
                  child: const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Thành viên",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                )
              ])
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${userModel.fName ?? " "} ${userModel.lName ?? ""}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Thành viên từ ${DateTimeHelper.getDataFormat(userModel.createdAt)}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static _buildCardBox(String title, IconData icon, onPressed, [selected]) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: selected ?? false ? ColorResources.primaryColor : null,
          borderRadius:
              const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                  ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ?? false ? Colors.white : ColorResources.primaryColor,
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                    color: selected ?? false ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _buildNotificationCardBox(
      NotificationDotController notificationDotController, String title, IconData icon, onPressed,
      [selected]) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: selected ?? false ? ColorResources.primaryColor : null,
          borderRadius:
              const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                  ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
          child: Row(
            children: [
              Stack(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: selected ?? false ? Colors.white : ColorResources.primaryColor,
                  ),
                  Obx(() {
                    return notificationDotController.isShow.value
                        ? const Icon(
                            Icons.circle,
                            size: 10,
                            color: Colors.red,
                          )
                        : Container();
                  })
                ],
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                    color: selected ?? false ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
