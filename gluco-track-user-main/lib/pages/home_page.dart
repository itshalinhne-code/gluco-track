import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_rating/star_rating.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:userapp/controller/clinic_controller.dart';
import 'package:userapp/model/clinic_model.dart';
import 'package:userapp/services/banner_service.dart';
import 'package:userapp/services/city_service.dart';

import '../controller/depratment_controller.dart';
import '../controller/doctors_controller.dart';
import '../controller/notification_dot_controller.dart';
import '../controller/user_controller.dart';
import '../helpers/route_helper.dart';
import '../model/city_model.dart';
import '../model/department_model.dart';
import '../model/doctors_model.dart';
import '../pages/auth/login_page.dart';
import '../pages/doctors_list_page.dart';
import '../pages/my_booking_page.dart';
import '../pages/wallet_page.dart';
import '../services/configuration_service.dart';
import '../services/notification_seen_service.dart';
import '../utilities/api_content.dart';
import '../utilities/colors_constant.dart';
import '../utilities/image_constants.dart';
import '../utilities/sharedpreference_constants.dart';
import '../widget/carousel_widget.dart';
import '../widget/drawer_widget.dart';
import '../widget/image_box_widget.dart';
import '../widget/loading_Indicator_widget.dart';
import '../widget/search_box_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final DepartmentController _departmentController =
      Get.put(DepartmentController(), tag: "department");
  final DoctorsController _doctorsController = Get.put(DoctorsController(), tag: "doctor");
  final ScrollController _scrollController = ScrollController();
  final NotificationDotController _notificationDotController = Get.find(tag: "notification_dot");
  final ClinicController _clinicController = Get.put(ClinicController());
  final TextEditingController _searchTextController = TextEditingController();
  final ScrollController _bottomSheetScrollController = ScrollController();
  int _selectedIndex = 3; // Index of the initially selected item
  bool _isLoading = false;
  UserController userController = Get.find(tag: "user");
  String appStoreUrl = "";
  String playStoreUrl = "";
  bool _locationLoading = false;
  String? clinicLat;
  String? clinicLng;
  String? email;
  String? phone;
  String? cityId;
  String? cityName;
  String? whatsapp;
  String? ambulancePhone;
  List<CityModel> _cityModelList = [];
  List<CityModel> filteredCities = [];

  List<String> bannerImageList = [];

  List boxCardItems = [
    {
      "title": "Lịch hẹn",
      "assets": ImageConstants.appointmentImageBox,
      "onClick": () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        final loggedIn = preferences.getBool(SharedPreferencesConstants.login) ?? false;
        final userId = preferences.getString(SharedPreferencesConstants.uid);
        if (loggedIn && userId != "" && userId != null) {
          Get.toNamed(RouteHelper.getMyBookingPageRoute());
        } else {
          Get.to(() => LoginPage(onSuccessLogin: () {
                Get.toNamed(RouteHelper.getMyBookingPageRoute());
              }));
          // Get.toNamed(RouteHelper.getLoginPageRoute());
        }
      }
    },
    {
      "title": "Chỉ số sức khoẻ",
      "assets": ImageConstants.vialImageBox,
      "onClick": () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        final loggedIn = preferences.getBool(SharedPreferencesConstants.login) ?? false;
        final userId = preferences.getString(SharedPreferencesConstants.uid);
        if (loggedIn && userId != "" && userId != null) {
          Get.toNamed(RouteHelper.getVitalsPageRoute());
        } else {
          Get.to(() => LoginPage(onSuccessLogin: () {
                Get.toNamed(RouteHelper.getVitalsPageRoute());
              }));
          // Get.toNamed(RouteHelper.getLoginPageRoute());
        }
      }
    },
    {
      "title": "Đơn thuốc",
      "assets": ImageConstants.prescriptionImageBox,
      "onClick": () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        final loggedIn = preferences.getBool(SharedPreferencesConstants.login) ?? false;
        final userId = preferences.getString(SharedPreferencesConstants.uid);
        if (loggedIn && userId != "" && userId != null) {
          Get.toNamed(RouteHelper.getPrescriptionListPageRoute());
        } else {
          Get.to(() => LoginPage(onSuccessLogin: () {
                Get.toNamed(RouteHelper.getPrescriptionListPageRoute());
              }));
          // Get.toNamed(RouteHelper.getLoginPageRoute());
        }
      }
    },
    {
      "title": "Hồ sơ",
      "assets": ImageConstants.profileImageBox,
      "onClick": () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        final loggedIn = preferences.getBool(SharedPreferencesConstants.login) ?? false;
        final userId = preferences.getString(SharedPreferencesConstants.uid);
        if (loggedIn && userId != "" && userId != null) {
          Get.toNamed(RouteHelper.getEditUserProfilePageRoute());
        } else {
          Get.to(() => LoginPage(onSuccessLogin: () {
                Get.toNamed(RouteHelper.getEditUserProfilePageRoute());
              }));
          // Get.toNamed(RouteHelper.getLoginPageRoute());
        }
      }
    },
    {
      "title": "Thành viên gia đình",
      "assets": ImageConstants.familyMemberImageBox,
      "onClick": () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        final loggedIn = preferences.getBool(SharedPreferencesConstants.login) ?? false;
        final userId = preferences.getString(SharedPreferencesConstants.uid);
        if (loggedIn && userId != "" && userId != null) {
          Get.toNamed(RouteHelper.getFamilyMemberListPageRoute());
        } else {
          Get.to(() => LoginPage(onSuccessLogin: () {
                Get.toNamed(RouteHelper.getFamilyMemberListPageRoute());
              }));
          // Get.toNamed(RouteHelper.getLoginPageRoute());
        }
      }
    },
    {
      "title": "Ví",
      "assets": ImageConstants.walletImageBox,
      "onClick": () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        final loggedIn = preferences.getBool(SharedPreferencesConstants.login) ?? false;
        final userId = preferences.getString(SharedPreferencesConstants.uid);
        if (loggedIn && userId != "" && userId != null) {
          Get.toNamed(RouteHelper.getWalletPageRoute());
        } else {
          Get.to(() => LoginPage(onSuccessLogin: () {
                Get.toNamed(RouteHelper.getWalletPageRoute());
              }));
          // Get.toNamed(RouteHelper.getLoginPageRoute());
        }
      }
    },
    {
      "title": "Thông báo",
      "assets": ImageConstants.notificationImageBox,
      "onClick": () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        final loggedIn = preferences.getBool(SharedPreferencesConstants.login) ?? false;
        final userId = preferences.getString(SharedPreferencesConstants.uid);
        if (loggedIn && userId != "" && userId != null) {
          Get.toNamed(RouteHelper.getNotificationPageRoute());
        } else {
          Get.to(() => LoginPage(onSuccessLogin: () {
                Get.toNamed(RouteHelper.getNotificationPageRoute());
              }));
          // Get.toNamed(RouteHelper.getLoginPageRoute());
        }
      }
    },
    {
      "title": "Liên hệ chúng tôi",
      "assets": ImageConstants.contactUsImageBox,
      "onClick": () async {
        Get.toNamed(RouteHelper.getContactUsPageRoute());
      }
    },
    {
      "title": "Tệp",
      "assets": ImageConstants.filesImageBox,
      "onClick": () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        final loggedIn = preferences.getBool(SharedPreferencesConstants.login) ?? false;
        final userId = preferences.getString(SharedPreferencesConstants.uid);
        if (loggedIn && userId != "" && userId != null) {
          Get.toNamed(RouteHelper.getPatientFilePageRoute());
        } else {
          Get.to(() => LoginPage(onSuccessLogin: () {
                Get.toNamed(RouteHelper.getPatientFilePageRoute());
              }));
          // Get.toNamed(RouteHelper.getLoginPageRoute());
        }
      }
    }
  ];
  @override
  void initState() {
    // TODO: implement initState

    userController.getData();
    _requestLocationPermission();
    // getAndSetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 3 ? true : false,
      onPopInvokedWithResult: (didPop, dynamic) {
        if (_selectedIndex == 3) {
        } else {
          setState(() {
            _selectedIndex = 3;
          });
          //  return false;
        }
      },
      child: Scaffold(
          key: _key,
          drawer: IDrawerWidget().buildDrawerWidget(userController, _notificationDotController),
          backgroundColor: ColorResources.bgColor,
          bottomNavigationBar: _isLoading
              ? null
              : BottomAppBar(
                  height: 80,
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 8.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences preferences = await SharedPreferences.getInstance();
                          final loggedIn =
                              preferences.getBool(SharedPreferencesConstants.login) ?? false;
                          final userId = preferences.getString(SharedPreferencesConstants.uid);
                          if (loggedIn && userId != "" && userId != null) {
                            _onItemTapped(4);
                          } else {
                            Get.to(LoginPage(
                              onSuccessLogin: () {
                                _onItemTapped(4);
                              },
                            ));
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_month,
                                color: _selectedIndex == 4
                                    ? ColorResources.primaryColor
                                    : Colors.black),
                            const SizedBox(height: 3),
                            Text(
                              "Lịch hẹn",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedIndex == 4
                                      ? ColorResources.primaryColor
                                      : Colors.grey),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _onItemTapped(2);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search,
                                color: _selectedIndex == 2
                                    ? ColorResources.primaryColor
                                    : Colors.black),
                            const SizedBox(height: 3),
                            Text(
                              "Tìm kiếm",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedIndex == 2
                                      ? ColorResources.primaryColor
                                      : Colors.grey),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      // Empty space for the circular button
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences preferences = await SharedPreferences.getInstance();
                          final loggedIn =
                              preferences.getBool(SharedPreferencesConstants.login) ?? false;
                          final userId = preferences.getString(SharedPreferencesConstants.uid);
                          if (loggedIn && userId != "" && userId != null) {
                            _onItemTapped(1);
                          } else {
                            Get.to(LoginPage(
                              onSuccessLogin: () {
                                _onItemTapped(1);
                              },
                            ));
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.account_balance_wallet,
                                color: _selectedIndex == 1
                                    ? ColorResources.primaryColor
                                    : Colors.black),
                            const SizedBox(height: 3),
                            Text(
                              "Ví",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedIndex == 1
                                      ? ColorResources.primaryColor
                                      : Colors.grey),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          _key.currentState!.openDrawer();
                          // print("open drawer");
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu,
                              color: Colors.black,
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Menu",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
          floatingActionButtonLocation:
              _isLoading ? null : FloatingActionButtonLocation.centerDocked,
          floatingActionButton: MediaQuery.of(context).viewInsets.bottom != 0
              ? null
              : FloatingActionButton(
                  backgroundColor: ColorResources.secondaryColor,
                  onPressed: () => _onItemTapped(3),
                  tooltip: 'Trang chủ',
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: const Icon(Icons.home, color: Colors.white),
                ),
          body: _isLoading || _locationLoading
              ? const ILoadingIndicatorWidget()
              : _selectedIndex == 1
                  ? const WalletPage()
                  : _selectedIndex == 2
                      ? const DoctorsListPage(
                          selectedDeptTitle: "",
                          selectedDeptId: "",
                        )
                      : _selectedIndex == 4
                          ? const MyBookingPage()
                          : _buildBody()),
    );
  }

  _buildBody() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(0),
      children: [
        _buildProfileSection(),
        bannerImageList.isEmpty
            ? Container()
            : CarouselSliderWidget(
                imagesUrl: bannerImageList,
              ),
        // _buildHeaderSection(),
        _buildDepartment(),
        _buildDoctor(),
        _buildClinic(),
        _buildCardBox(),
        //       checkIsShowBox()?_buildContactCard():Container(),
        const SizedBox(height: 100)
      ],
    );
  }

  _buildCardBox() {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: 9,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 1, crossAxisCount: 3),
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: .1,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: GestureDetector(
            onTap: boxCardItems[index]['onClick'],
            child: GridTile(
              footer: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  boxCardItems[index]['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Image.asset(
                  boxCardItems[index]['assets'],
                  // color: ColorResources.primaryColor,
                ),
              ), //just for testing, will fill with image later
            ),
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  _buildDepartmentBox(List dataList) {
    return Card(
      elevation: .1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(5),
        title: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                "Khoa",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              dataList.length < 4
                  ? Container()
                  : const Text(
                      'Vuốt để xem thêm >>',
                      style:
                          TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
            ])),
        subtitle: SizedBox(
          height: 100,
          child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: dataList.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final DepartmentModel departmentModel = dataList[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 18, 8),
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(RouteHelper.getDoctorsListPageRoute(
                          selectedDeptId: departmentModel.id?.toString() ?? "",
                          selectedDeptTitle: departmentModel.title ?? ""));
                      //   Get.toNamed(RouteHelper.getSearchProductsPageRoute(initSelectedProductCatId: productCatModel.id.toString()));
                    },
                    child: Column(
                      children: [
                        departmentModel.image == null || departmentModel.image == ""
                            ? const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 25,
                                child: Icon(Icons.image),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 25,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                          '${ApiContents.imageUrl}/${departmentModel.image}'),
                                    ),
                                  ),
                                )),
                        const SizedBox(height: 5),
                        Text(
                          departmentModel.title ?? "--",
                          maxLines: 1, // Limit to 1 line
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  _buildDoctorBox(List dataList) {
    return Card(
      elevation: .1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(5),
        title: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                "Bác sĩ giỏi nhất tại ${cityName ?? "--"}",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              dataList.length < 3
                  ? Container()
                  : const Text(
                      'Vuốt để xem thêm >>',
                      style:
                          TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
            ])),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: SizedBox(
              height: dataList.length > 2 ? 220 : 100,
              child: GridView.builder(
                  padding: const EdgeInsets.all(0),
                  physics: dataList.length > 2 ? null : const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: dataList.length > 2 ? Axis.horizontal : Axis.vertical,
                  itemCount: dataList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: .58, crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    return _buildDoctorCard(dataList[index]);
                  })),
        ),
      ),
    );
  }

  _buildClinicList(List dataList) {
    return Card(
      elevation: .1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(5),
        title: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                "Phòng khám tốt nhất tại ${cityName ?? "--"}",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(RouteHelper.getClinicListPageRoute());
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                      color: ColorResources.btnColor, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ])),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ListView.builder(
              padding: const EdgeInsets.all(0),
              controller: _scrollController,
              // physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: dataList.length <= 5 ? dataList.length : 5,
              itemBuilder: (context, index) {
                return _buildClinicCard(dataList[index]);
              }),
        ),
      ),
    );
  }

  _buildClinicCard(ClinicModel clinicModel) {
    return ListTile(
      onTap: () {
        Get.toNamed(RouteHelper.getClinicPageRoute(clinicId: clinicModel.id.toString()));
      },
      title: Text(
        clinicModel.title ?? "",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: Text(
        clinicModel.address ?? "",
        style: TextStyle(
            color: ColorResources.secondaryFontColor, fontWeight: FontWeight.w400, fontSize: 12),
      ),
      leading: clinicModel.image == null || clinicModel.image == ""
          ? const SizedBox(
              height: 70,
              width: 70,
              child: Icon(Icons.image, size: 40),
            )
          : SizedBox(
              height: 70,
              width: 70,
              child: CircleAvatar(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10), // Adjust the radius according to your preference
                  child: ImageBoxFillWidget(
                    imageUrl: "${ApiContents.imageUrl}/${clinicModel.image}",
                    boxFit: BoxFit.fill,
                  ),
                ),
              )),
    );
  }

  _buildDoctorCard(DoctorsModel doctorsModel) {
    return GestureDetector(
      onTap: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        final loggedIn = preferences.getBool(SharedPreferencesConstants.login) ?? false;
        final userId = preferences.getString(SharedPreferencesConstants.uid);
        if (loggedIn && userId != "" && userId != null) {
          Get.toNamed(RouteHelper.getDoctorsDetailsPageRoute(doctId: doctorsModel.id.toString()));
        } else {
          Get.to(() => LoginPage(onSuccessLogin: () {
                Get.toNamed(
                    RouteHelper.getDoctorsDetailsPageRoute(doctId: doctorsModel.id.toString()));
              }));
        }
      },
      child: SizedBox(
        // width: 240,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                    flex: 2,
                    child: Stack(
                      children: [
                        doctorsModel.image == null || doctorsModel.image == ""
                            ? const SizedBox(
                                height: 70,
                                width: 70,
                                child: Icon(Icons.person, size: 40),
                              )
                            : SizedBox(
                                height: 70,
                                width: 70,
                                child: CircleAvatar(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust the radius according to your preference
                                    child: ImageBoxFillWidget(
                                      imageUrl: "${ApiContents.imageUrl}/${doctorsModel.image}",
                                      boxFit: BoxFit.fill,
                                    ),
                                  ),
                                )),
                        const Positioned(
                          top: 5,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 6,
                            child: CircleAvatar(backgroundColor: Colors.green, radius: 4),
                          ),
                        )
                      ],
                    )),
                const SizedBox(width: 10),
                Flexible(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "${doctorsModel.fName ?? "--"} ${doctorsModel.lName ?? "--"}",
                                maxLines: 2, // Limit to 1 line
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctorsModel.specialization ?? "",
                          maxLines: 1, // Limit to 1 line
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: ColorResources.secondaryFontColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            StarRating(
                              mainAxisAlignment: MainAxisAlignment.center,
                              length: 5,
                              color: doctorsModel.averageRating == 0 ? Colors.grey : Colors.amber,
                              rating: doctorsModel.averageRating ?? 0,
                              between: 5,
                              starSize: 15,
                              onRaitingTap: (rating) {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${doctorsModel.averageRating} (${doctorsModel.numberOfReview} đánh giá)",
                          style: const TextStyle(
                              color: ColorResources.secondaryFontColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        )
                      ],
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildDepartment() {
    return Obx(() {
      if (!_departmentController.isError.value) {
        // if no any error
        if (_departmentController.isLoading.value) {
          return const IVerticalListLongLoadingWidget();
        } else if (_departmentController.dataList.isEmpty) {
          return Container();
        } else {
          return _departmentController.dataList.length == 1
              ? Container()
              : _buildDepartmentBox(_departmentController.dataList);
        }
      } else {
        return Container();
      } //Error svg
    });
  }

  _buildDoctor() {
    return Obx(() {
      if (!_doctorsController.isError.value) {
        // if no any error
        if (_doctorsController.isLoading.value) {
          return const IVerticalListLongLoadingWidget();
        } else if (_doctorsController.dataList.isEmpty) {
          return SizedBox();
        } else {
          return _buildDoctorBox(_doctorsController.dataList);
        }
      } else {
        return Container();
      } //Error svg
    });
  }

  _buildClinic() {
    return Obx(() {
      if (!_clinicController.isError.value) {
        // if no any error
        if (_clinicController.isLoading.value) {
          return const IVerticalListLongLoadingWidget();
        } else if (_clinicController.dataList.isEmpty) {
          return Container();
        } else {
          return _buildClinicList(_clinicController.dataList);
        }
      } else {
        return Container();
      } //Error svg
    });
  }

  void _requestNotificationPermission() {
    setState(() {
      _isLoading = true;
    });
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

  void getAndSetData() async {
    setState(() {
      _isLoading = true;
    });
    _departmentController.getData();
    _doctorsController.getData("", cityId.toString());
    _clinicController.getData("0", "10", cityId.toString());
    final cityRes = await CityService.getData(search: "");
    if (cityRes != null) {
      _cityModelList = cityRes;
      filteredCities.addAll(_cityModelList);
    }
    final res = await NotificationSeenService.getDataById();
    if (res != null) {
      if (res.dotStatus == true) {
        _notificationDotController.setDotStatus(true);
      }
    }
    String? playStoreLink;
    String? androidForceUpdateBoxEnable;
    String? androidAndroidAppVersion;
    String? androidUpdateBoxEnable;
    String? androidTechnicalIssueEnable;

    String? appStoreLink;
    String? iosForceUpdateBoxEnable;
    String? iosAppVersion;
    String? iosUpdateBoxEnable;
    String? iosTechnicalIssueEnable;

    final configRes = await ConfigurationService.getDataByGroupName("Mobile App");
    if (configRes != null) {
      for (var e in configRes) {
        if (Platform.isAndroid) {
          if (e.idName == "play_store_link") {
            playStoreLink = e.value;
          }
          if (e.idName == "android_technical_issue_enable") {
            androidTechnicalIssueEnable = e.value;
          }
          if (e.idName == "android_update_box_enable") {
            androidUpdateBoxEnable = e.value;
          }
          if (e.idName == "android_android_app_version") {
            androidAndroidAppVersion = e.value;
          }
          if (e.idName == "android_force_update_box_enable") {
            androidForceUpdateBoxEnable = e.value;
          }
        }
        if (Platform.isIOS) {
          if (e.idName == "app_store_link") {
            appStoreLink = e.value;
          }
          if (e.idName == "ios_technical_issue_enable") {
            iosTechnicalIssueEnable = e.value;
          }
          if (e.idName == "ios_update_box_enable") {
            iosUpdateBoxEnable = e.value;
          }
          if (e.idName == "ios_app_version") {
            iosAppVersion = e.value;
          }
          if (e.idName == "ios_force_update_box_enable") {
            iosForceUpdateBoxEnable = e.value;
          }
        }
      }
    }

    if (Platform.isAndroid) {
      // if(webSetting!=null){
      playStoreUrl = playStoreLink ?? "";
      if (kDebugMode) {
        print("Play store Url $playStoreUrl");
      }
      //}
      if (androidTechnicalIssueEnable != null) {
        if (androidTechnicalIssueEnable == "true") {
          _openDialogIssueBox();
        } else {
          if (androidUpdateBoxEnable != null) {
            if (androidUpdateBoxEnable == "true") {
              if (androidAndroidAppVersion != null) {
                PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
                  String version = packageInfo.version;
                  if (kDebugMode) {
                    print("Phiên bản $version");
                    print("setting phiên bản $androidAndroidAppVersion");
                  }
                  if (version.toString() != androidAndroidAppVersion.toString()) {
                    if (androidForceUpdateBoxEnable != null) {
                      if (androidForceUpdateBoxEnable == "true") {
                        _openDialogSettingBox(false);
                      } else {
                        _openDialogSettingBox(true);
                      }
                    }
                  }
                });
              }
            }
          }
        }
      }
    } else if (Platform.isIOS) {
      // if(webSetting!=null){
      appStoreUrl = appStoreLink ?? "";
      if (kDebugMode) {
        print("app store Url $appStoreUrl");
      }
      //}
      if (iosTechnicalIssueEnable != null) {
        if (iosTechnicalIssueEnable == "true") {
          _openDialogIssueBox();
        } else {
          if (iosUpdateBoxEnable != null) {
            if (iosUpdateBoxEnable == "true") {
              if (iosAppVersion != null) {
                PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
                  String version = packageInfo.version;
                  if (kDebugMode) {
                    print("Phiên bản Ios $version");
                    print("setting phiên bản Ios $iosAppVersion");
                  }
                  if (version.toString() != iosAppVersion.toString()) {
                    if (iosForceUpdateBoxEnable != null) {
                      if (iosForceUpdateBoxEnable == "true") {
                        _openDialogSettingBox(false);
                      } else {
                        _openDialogSettingBox(true);
                      }
                    }
                  }
                });
              }
            }
          }
        }
      }
    }
    bannerImageList.clear();
    final resBanner = await BannerService.getData();
    if (resBanner != null) {
      for (int i = 0; i < resBanner.length; i++) {
        bannerImageList.add("${ApiContents.imageUrl}/${resBanner[i].image ?? ""}");
      }
    }
    _requestNotificationPermission();
    setState(() {
      _isLoading = false;
    });
  }

  _openDialogSettingBox(bool isCancel) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return PopScope(
          canPop: isCancel,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: const Text(
              "Cập nhật",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    isCancel
                        ? "Có phiên bản mới, vui lòng cập nhật ứng dụng"
                        : "Xin lỗi, chúng tôi hiện không hỗ trợ phiên bản cũ của ứng dụng, vui lòng cập nhật với phiên bản mới nhất",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                const SizedBox(height: 10),
              ],
            ),
            actions: <Widget>[
              isCancel
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorResources.greyBtnColor,
                      ),
                      child: const Text("Hủy",
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                  : Container(),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorResources.greenFontColor,
                  ),
                  child: const Text(
                    "Cập nhật",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  ),
                  onPressed: () async {
                    // Navigator.of(context).pop();
                    if (Platform.isAndroid) {
                      if (playStoreUrl != "") {
                        try {
                          await launchUrl(Uri.parse(playStoreUrl),
                              mode: LaunchMode.externalApplication);
                        } catch (e) {
                          if (kDebugMode) {
                            print(e);
                          }
                        }
                      }
                    } else if (Platform.isIOS) {
                      if (appStoreUrl != "") {
                        try {
                          await launchUrl(Uri.parse(appStoreUrl),
                              mode: LaunchMode.externalApplication);
                        } catch (e) {
                          if (kDebugMode) {
                            print(e);
                          }
                        }
                      }
                    }
                  }),
              // usually buttons at the bottom of the dialog
            ],
          ),
        );
      },
    );
  }

  // _openDialogCityControl() {
  //   return showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       // return object of type Dialog
  //       return PopScope(
  //         canPop: false,
  //         child: AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20.0),
  //           ),
  //           title: const Text("Initial Setup Required",
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //                 fontWeight: FontWeight.w600,
  //                 fontSize: 18
  //             ),),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                  "To get started, please add at least one country, state, and city from the admin panel. Make sure all are active, and at least one city is set as the default",
  //                   textAlign: TextAlign.center,
  //                   style: const TextStyle(
  //                       fontWeight: FontWeight.w400,
  //                       fontSize: 12
  //                   )),
  //               const SizedBox(height: 10),
  //
  //             ],
  //           ),
  //
  //         ),
  //       );
  //     },
  //   );
  // }
  _openDialogIssueBox() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: const Text(
              "Xin lỗi!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "Chúng tôi đang gặp phải một số vấn đề kỹ thuật. đội ngũ của chúng tôi đang cố gắng giải quyết vấn đề. hy vọng chúng tôi sẽ trở lại sớm.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildProfileSection() {
    return Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 50, 10, 20),
          color: ColorResources.appBarColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: ClipOval(
                            child: userController.usersData.value.imageUrl == null ||
                                    userController.usersData.value.imageUrl == ""
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                  )
                                : ImageBoxFillWidget(
                                    imageUrl:
                                        "${ApiContents.imageUrl}/${userController.usersData.value.imageUrl}")),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Xin chào!",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                              ),
                              const SizedBox(width: 3),
                              GestureDetector(
                                onTap: () async {
                                  SharedPreferences preferences =
                                      await SharedPreferences.getInstance();
                                  final loggedIn =
                                      preferences.getBool(SharedPreferencesConstants.login) ??
                                          false;
                                  final userId =
                                      preferences.getString(SharedPreferencesConstants.uid);
                                  if (loggedIn && userId != "" && userId != null) {
                                    Get.toNamed(RouteHelper.getNotificationPageRoute());
                                  } else {
                                    Get.to(() => LoginPage(onSuccessLogin: () {
                                          Get.toNamed(RouteHelper.getNotificationPageRoute());
                                        }));
                                    // Get.toNamed(RouteHelper.getLoginPageRoute());
                                  }
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      Icons.notifications_none,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                    Obx(() {
                                      return _notificationDotController.isShow.value
                                          ? const Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Icon(
                                                Icons.circle,
                                                color: Colors.red,
                                                size: 10,
                                              ),
                                            )
                                          : Container();
                                    })
                                  ],
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Obx(() {
                                return !userController.isLoading.value &&
                                        userController.usersData.value.fName != null
                                    ? Text(
                                        "${userController.usersData.value.fName}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      )
                                    : const Text(
                                        "User",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      _openBottomSheetSearchCity();
                    },
                    child: Row(
                      children: [
                        Text(
                          cityName ?? "--",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              ISearchBox.buildSearchBoxOnTap(
                  textEditingController: null,
                  labelText: "Tìm kiếm.....",
                  onTap: () {
                    _onItemTapped(2);
                    //  _requestLocationPermission();
                    //  _clinicController.getData("0","5",cityId.toString());
                  }),
            ],
          ),
        ));
  }

  void _requestLocationPermissionCurrentLocation() async {
    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print("Location services are disabled.");
        }
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    double? lat;
    double? long;
    if (kDebugMode) {
      print("Location Permission status $permissionGranted");
    }
    if (permissionGranted == loc.PermissionStatus.granted) {
      setState(() {
        _isLoading = true;
      });
      // Get the user's current location
      loc.LocationData locationData = await location.getLocation();
      lat = locationData.latitude;
      long = locationData.longitude;

      final res = await CityService.getLocationData(
          lat: lat?.toString() ?? "", lng: long?.toString() ?? "");
      setState(() {
        _isLoading = false;
      });
      cityId = res['city_id']?.toString();
      cityName = res['city']?.toString();
      _searchTextController.text = cityName ?? "";
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString("city_id", cityId ?? "");
      sharedPreferences.setString("city", cityName ?? "");
      _doctorsController.getData("", cityId.toString());
      _clinicController.getData("0", "5", cityId.toString());
      setState(() {});
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing by tapping outside
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          "Location Permission Required",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "To access location features, you need to allow location permission from the app settings. Please enable it to continue.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.settings, size: 20),
            label: const Text("Open Settings"),
            onPressed: () {
              AppSettings.openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _requestLocationPermission() async {
    setState(() {
      _locationLoading = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cityName = sharedPreferences.getString("city") ?? "";
    cityId = sharedPreferences.getString("city_id") ?? "";
    if (cityName != null && cityName != "" && cityId != null && cityId != "") {
      setState(() {
        _locationLoading = false;
      });
      getAndSetData();
      return;
    }
    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print("Dịch vụ định vị bị vô hiệu hóa.");
        }
        setState(() {
          _locationLoading = false;
        });
        getAndSetData();
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    double? lat;
    double? long;
    if (kDebugMode) {
      print("Quyền truy cập định vị $permissionGranted");
    }
    if (permissionGranted == loc.PermissionStatus.granted) {
      // Get the user's current location
      loc.LocationData locationData = await location.getLocation();
      lat = locationData.latitude;
      long = locationData.longitude;
    }

    final res =
        await CityService.getLocationData(lat: lat?.toString() ?? "", lng: long?.toString() ?? "");

    if (res != null) {
      cityId = res['city_id']?.toString();
      cityName = res['city']?.toString();
      sharedPreferences.setString("city_id", cityId ?? "");
      sharedPreferences.setString("city", cityName ?? "");
    }

    setState(() {
      _locationLoading = false;
    });
    // else{
    // _openDialogCityControl();
    // }

    getAndSetData();
  }

  _openBottomSheetSearchCity() {
    return showModalBottomSheet(
      backgroundColor: ColorResources.bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.0),
          topLeft: Radius.circular(20.0),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return FractionallySizedBox(
            heightFactor:
                0.9, // Adjust this factor to control the height (e.g., 0.7 = 70% of screen height)
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Stack(
                    // controller: _bottomSheetScrollController,
                    children: [
                      ISearchBox.buildSearchBox(
                          textEditingController: _searchTextController,
                          labelText: "Tìm thành phố",
                          onChanged: () {
                            filterCities(_searchTextController.text, setState);
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              Get.back();
                              _requestLocationPermissionCurrentLocation();
                            },
                            icon: Icon(
                              Icons.my_location,
                              size: 20,
                            ),
                          )),
                      Positioned(
                        top: 50,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: filteredCities.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const Text("Không tìm thấy dữ liệu!"),
                              )
                            : ListView.builder(
                                controller: _bottomSheetScrollController,
                                shrinkWrap: true,
                                itemCount: filteredCities.length,
                                itemBuilder: (context, index) {
                                  CityModel cityMode = filteredCities[index];
                                  return Card(
                                    color: ColorResources.cardBgColor,
                                    elevation: .1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: ListTile(
                                        onTap: () async {
                                          Get.back();
                                          cityId = cityMode.id.toString();
                                          cityName = "${cityMode.title}";
                                          _searchTextController.text =
                                              "${cityMode.title},${cityMode.stateTitle}";
                                          SharedPreferences sharedPreferences =
                                              await SharedPreferences.getInstance();
                                          sharedPreferences.setString("city_id", cityId ?? "");
                                          sharedPreferences.setString("city", cityName ?? "");
                                          _doctorsController.getData("", cityId.toString());
                                          _clinicController.getData("0", "5", cityId.toString());

                                          this.setState(() {});
                                        },
                                        title: Text(
                                          "${cityMode.title},${cityMode.stateTitle}",
                                          style:
                                              TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                        )),
                                  );
                                }),
                      )
                    ],
                  )),
            ),
          );
        });
      },
    ).whenComplete(() {});
  }

  void filterCities(String query, setState) {
    if (query.isEmpty) {
      setState(() {
        filteredCities = _cityModelList;
      });
    } else {
      setState(() {
        filteredCities = _cityModelList
            .where((city) =>
                city.title!.toLowerCase().contains(query.toLowerCase()) ||
                city.stateTitle!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }
}
