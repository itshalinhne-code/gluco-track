import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:star_rating/star_rating.dart';

import '../controller/appointment_controller.dart';
import '../controller/dashboard_controller.dart';
import '../controller/notification_dot_controller.dart';
import '../helper/route_helper.dart';
import '../model/appointment_model.dart';
import '../model/dashboard_model.dart';
import '../model/doctors_model.dart';
import '../model/user_model.dart';
import '../service/doctor_service.dart';
import '../service/notification_seen_service.dart';
import '../service/user_service.dart';
import '../utilities/api_content.dart';
import '../utilities/app_constans.dart';
import '../utilities/colors_constant.dart';
import '../utilities/image_constants.dart';
import '../widget/drawer_widget.dart';
import '../widget/image_box_widget.dart';
import '../widget/loading_Indicator_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  AppointmentController appointmentController = Get.put(AppointmentController());
  DashboardController dashboardController = Get.put(DashboardController());
  final ScrollController _scrollController = ScrollController();
  RefreshController refreshController = RefreshController();
  UserModel? userModel;
  DoctorsModel? doctorsModel;
  final NotificationDotController _notificationDotController = Get.find(tag: "notification_dot");

  @override
  void initState() {
    // TODO: implement initState
    getAdnSetData();

    appointmentController.getData();
    dashboardController.getData();
    super.initState();
  }

  void _onRefresh() async {
    refreshController.refreshCompleted();
    appointmentController.getData();
    dashboardController.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: IDrawerWidget().buildDrawerWidget(userModel, _notificationDotController),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: ColorResources.appBarColor,
        title: const Text(
          "Bác sĩ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Get.toNamed(RouteHelper.getNotificationPageRoute());
                    },
                  ),
                  Obx(() {
                    return _notificationDotController.isShow.value
                        ? const Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 12,
                            ),
                          )
                        : Container();
                  })
                ],
              ))
        ],
      ),
      backgroundColor: ColorResources.bgColor,
      body: _isLoading
          ? const ILoadingIndicatorWidget()
          : SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: null,
              footer: null,
              controller: refreshController,
              onRefresh: _onRefresh,
              onLoading: null,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: ColorResources.cardBgColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Xin chào!",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(RouteHelper.getNotificationPageRoute());
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 18,
                                          child: Icon(
                                            Icons.notifications_none,
                                            size: 25,
                                            color: ColorResources.primaryColor,
                                          ),
                                        ),
                                        Obx(() {
                                          return _notificationDotController.isShow.value
                                              ? const Positioned(
                                                  top: 5,
                                                  right: 7,
                                                  child: Icon(
                                                    Icons.circle,
                                                    color: Colors.red,
                                                    size: 12,
                                                  ),
                                                )
                                              : Container();
                                        })
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                userModel?.fName ?? "",
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  StarRating(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    length: 5,
                                    color: doctorsModel?.averageRating == 0
                                        ? Colors.grey
                                        : Colors.amber,
                                    rating: doctorsModel?.averageRating ?? 0,
                                    between: 5,
                                    starSize: 15,
                                    onRaitingTap: (rating) {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${doctorsModel?.averageRating ?? "0"} (${doctorsModel?.numberOfReview ?? "0"} đánh giá)",
                                style: const TextStyle(
                                    color: ColorResources.secondaryFontColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 70,
                            width: 70,
                            child: ClipOval(
                                child: userModel?.imageUrl == null || userModel?.imageUrl == ""
                                    ? const Icon(
                                        Icons.person,
                                        color: ColorResources.primaryColor,
                                        size: 50,
                                      )
                                    : ImageBoxFillWidget(
                                        imageUrl:
                                            "${ApiContents.imageUrl}/${userModel?.imageUrl}")),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeeCard("OPD", doctorsModel?.opdFee.toString() ?? "0",
                          doctorsModel?.clinicAppointment ?? 0),
                      _buildFeeCard("Khám video", doctorsModel?.videoFee.toString() ?? "0",
                          doctorsModel?.videoAppointment ?? 0),
                      _buildFeeCard("Khám cấp cứu", doctorsModel?.emgFee.toString() ?? "0",
                          doctorsModel?.emergencyAppointment ?? 0),
                    ],
                  ),
                  Obx(() {
                    if (!dashboardController.isError.value) {
                      // if no any error
                      if (dashboardController.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ILoadingIndicatorWidget(),
                        );
                      } else {
                        DashboardModel dashboardModel = dashboardController.dataModel.value;
                        return Column(
                          children: [
                            Row(
                              children: [
                                buildCard(
                                    "Lịch hẹn",
                                    dashboardModel.totalAppointments?.toString() ?? "0",
                                    ImageConstants.totalAppointmentImage,
                                    Colors.green),
                                buildCard(
                                    "Hôm nay",
                                    dashboardModel.totalTodayAppointment?.toString() ?? "0",
                                    ImageConstants.todayImage,
                                    Colors.orange),
                              ],
                            ),
                            Row(
                              children: [
                                buildCard(
                                    "Chờ xác nhận",
                                    dashboardModel.totalPendingAppointment?.toString() ?? "0",
                                    ImageConstants.pendingImage,
                                    Colors.yellow),
                                buildCard(
                                    "Hủy bỏ",
                                    dashboardModel.totalCancelledAppointment?.toString() ?? "0",
                                    ImageConstants.cancelledImage,
                                    Colors.redAccent),
                              ],
                            ),
                            Row(
                              children: [
                                buildCard(
                                    "Đã xác nhận",
                                    dashboardModel.totalConfirmedAppointment?.toString() ?? "0",
                                    ImageConstants.confirmedImage,
                                    Colors.green),
                                buildCard(
                                    "Từ chối",
                                    dashboardModel.totalRejectedAppointment?.toString() ?? "0",
                                    ImageConstants.rejectedImage,
                                    Colors.redAccent),
                              ],
                            ),
                          ],
                        );
                      }
                    } else {
                      return Container();
                    } //Error svg
                  }),
                  Card(
                    color: ColorResources.cardBgColor,
                    elevation: .1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      trailing: TextButton(
                          onPressed: () {
                            Get.toNamed(RouteHelper.getAppointmentPageRoute());
                          },
                          child: const Text(
                            "Xem tất cả >",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: ColorResources.primaryColor,
                            ),
                          )),
                      title: const Text(
                        "20 lịch hẹn gần nhất",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Obx(() {
                    if (!appointmentController.isError.value) {
                      // if no any error
                      if (appointmentController.isLoading.value) {
                        return const IVerticalListLongLoadingWidget();
                      } else if (appointmentController.dataList.isEmpty) {
                        return const Center(
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Text(
                                "Không tìm thấy lịch hẹn",
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return buildAppointmentList(appointmentController.dataList);
                      }
                    } else {
                      return Container();
                    } //Error svg
                  })
                ],
              ),
            ),
    );
  }

  buildCard(String titleFirst, String numbers, String imageAsset, Color dotIconColor) {
    return Expanded(
      child: SizedBox(
        height: 100,
        child: Card(
          elevation: 1,
          color: ColorResources.cardBgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      titleFirst,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 10, color: dotIconColor),
                        const SizedBox(width: 10),
                        Text(
                          numbers,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: ColorResources.btnColor,
                  child: Image.asset(
                    imageAsset,
                    height: 25,
                    width: 25,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildAppointmentList(dataList) {
    return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: dataList.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return _card(dataList[index]);
        });
  }

  Widget _card(AppointmentModel appointmentModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: GestureDetector(
        onTap: () async {
          Get.toNamed(
              RouteHelper.getAppointmentDetailsPageRoute(appId: appointmentModel.id.toString()));
        },
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Card(
            color: ColorResources.cardBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: .1,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _appointmentDate(appointmentModel.date),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              const Text("Tên: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  )),
                              Text(
                                  "${appointmentModel.pFName ?? ""} ${appointmentModel.pLName ?? ""} #${appointmentModel.id}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  )),
                            ],
                          ),
                          Row(
                            children: [
                              const Text("Thời gian: ",
                                  style: TextStyle(
                                    fontFamily: 'OpenSans-Regular',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  )),
                              Text(appointmentModel.timeSlot ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  )),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Container(height: 1, color: Colors.grey[300])),
                              Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: appointmentModel.status == "Pending"
                                      ? _statusIndicator(Colors.yellowAccent)
                                      : appointmentModel.status == "Rescheduled"
                                          ? _statusIndicator(Colors.orangeAccent)
                                          : appointmentModel.status == "Rejected"
                                              ? _statusIndicator(Colors.red)
                                              : appointmentModel.status == "Confirmed"
                                                  ? _statusIndicator(Colors.green)
                                                  : appointmentModel.status == "Completed"
                                                      ? _statusIndicator(Colors.green)
                                                      : null),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                                child: Text(
                                  appointmentModel.status ?? "--",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(appointmentModel.type ?? "--",
                                        style: const TextStyle(
                                          color: ColorResources.secondaryFontColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        )),
                                    Text(
                                        "Bác sĩ ${appointmentModel.doctFName ?? "--"} ${appointmentModel.doctLName ?? "--"}",
                                        style: const TextStyle(
                                          color: ColorResources.secondaryFontColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        )),
                                    Text(appointmentModel.departmentTitle ?? "--",
                                        style: const TextStyle(
                                          color: ColorResources.secondaryFontColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        )),
                                  ],
                                ),
                              ),
                              // appointmentDetails[index].appointmentStatus=="Visited"?

                              //:Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appointmentDate(date) {
    //  print(date);
    var appointmentDate = date.split("-");
    String appointmentMonth = "";
    switch (int.parse(appointmentDate[1])) {
      case 1:
        appointmentMonth = "JAN";
        break;
      case 2:
        appointmentMonth = "FEB";
        break;
      case 3:
        appointmentMonth = "MARCH";
        break;
      case 4:
        appointmentMonth = "APRIL";
        break;
      case 5:
        appointmentMonth = "MAY";
        break;
      case 6:
        appointmentMonth = "JUN";
        break;
      case 7:
        appointmentMonth = "JULY";
        break;
      case 8:
        appointmentMonth = "AUG";
        break;
      case 9:
        appointmentMonth = "SEP";
        break;
      case 10:
        appointmentMonth = "OCT";
        break;
      case 11:
        appointmentMonth = "NOV";
        break;
      case 12:
        appointmentMonth = "DEC";
        break;
    }

    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(appointmentMonth,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            )),
        Text(appointmentDate[2],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: ColorResources.primaryColor,
              fontSize: 35,
            )),
        Text(appointmentDate[0],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            )),
      ],
    );
  }

  Widget _statusIndicator(color) {
    return CircleAvatar(radius: 4, backgroundColor: color);
  }

  void getAdnSetData() async {
    setState(() {
      _isLoading = true;
    });
    final res = await UserService.getData();
    userModel = res;
    final resD = await DoctorsService.getDataById();
    doctorsModel = resD;
    final resN = await NotificationSeenService.getDataById();
    if (resN != null) {
      if (resN.dotStatus == true) {
        _notificationDotController.setDotStatus(true);
      }
    }
    setState(() {
      _isLoading = false;
    });
    _requestNotificationPermission();
  }

  _buildFeeCard(String titleFirst, String fee, int enable) {
    return Expanded(
      child: Card(
        elevation: 1,
        color: ColorResources.cardBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                titleFirst,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 3),
              Text(
                "Phí: $fee ${AppConstants.appCurrency}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle,
                      size: 10, color: enable == 1 ? Colors.green : Colors.redAccent),
                  const SizedBox(width: 5),
                  Text(
                    enable == 1 ? "Bật" : "Tắt",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _requestNotificationPermission() {
    //HandleLocalNotification.showWithOutImageNotification("ssss","slsls");
    if (Platform.isAndroid) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      // HandleLocalNotification.showWithOutImageNotification("hii", "ddd",);
    } else if (Platform.isIOS) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }
}
