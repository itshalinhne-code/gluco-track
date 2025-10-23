import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/user_controller.dart';
import '../../helpers/theme_helper.dart';
import '../../services/login_screen_service.dart';
import '../../services/user_service.dart';
import '../../services/user_subscription.dart';
import '../../utilities/api_content.dart';
import '../../utilities/app_constans.dart';
import '../../utilities/colors_constant.dart';
import '../../utilities/image_constants.dart';
import '../../utilities/sharedpreference_constants.dart';
import '../../widget/button_widget.dart';
import '../../widget/input_label_widget.dart';
import '../../widget/loading_Indicator_widget.dart';
import '../../widget/toast_message.dart';

class LoginPage extends StatefulWidget {
  final Function? onSuccessLogin;

  const LoginPage({super.key, required this.onSuccessLogin});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final List _images = [];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String phoneCode = "+";
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    phoneCode = AppConstants.defaultCountyCode;
    getAndSetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildSlidingBody());
  }

  _buildSlidingBody() {
    return Stack(
      children: [
        // Background image
        Container(
          width: double.infinity,
          height: double.infinity,
          color: ColorResources.bgColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                ImageConstants.onBoardImage,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
        if (!_isLoading)
          Positioned(
            left: 20,
            right: 20,
            bottom: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  ImageConstants.logoGlucoTrack01,
                  fit: BoxFit.contain,
                  height: 35,
                  width: 170,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Kiểm soát tiểu đường của bạn',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 48,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dễ dàng đặt lịch hẹn và kết nối với phòng khám của bạn mọi lúc, mọi nơi.',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    color: ColorResources.secondaryFontColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        // Center loading icon
        if (_isLoading)
          const Center(
            child: ILoadingIndicatorWidget(),
          ),
        // Login button chỉ hiện khi không loading
        if (!_isLoading)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 50,
              child: SmallButtonsWidget(
                title: "Đăng nhập",
                onPressed: () {
                  _openBottomSheetLogin();
                },
              ),
            ),
          ),
      ],
    );
  }

  void getAndSetData() async {
    setState(() {
      _isLoading = true;
    });
    final resImage = await LoginScreenService.getData();
    if (resImage != null) {
      for (int i = 0; i < resImage.length; i++) {
        _images.add("${ApiContents.imageUrl}/${resImage[i].image ?? ""}");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  _openBottomSheetLogin() {
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
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogo(),
                          const SizedBox(height: 20),
                          const Text(
                            'Nhập thông tin để đăng nhập',
                            style: TextStyle(
                              color: ColorResources.secondaryFontColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    InputLabel.buildLabelBox("Nhập số điện thoại"),
                    const SizedBox(height: 10),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        keyboardType: Platform.isIOS
                            ? const TextInputType.numberWithOptions(decimal: true, signed: true)
                            : TextInputType.number,
                        validator: (item) {
                          return item!.length > 5 ? null : "Vui lòng nhập số hợp lệ";
                        },
                        controller: _mobileController,
                        decoration: InputDecoration(
                          hintText: "VD 1234567890",
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey.shade400)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.red, width: 2.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.red, width: 2.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SmallButtonsWidget(
                      title: "Gửi",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Get.back();
                          _handleLogin();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {});
  }

  _openBottomSheetForRegisterUser() {
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
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Đăng ký $phoneCode${_mobileController.text}',
                            style: const TextStyle(
                              color: ColorResources.secondaryFontColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        validator: (item) {
                          return item!.length > 3 ? null : "Vui lòng nhập tên (ít nhất 4 ký tự)";
                        },
                        controller: _fNameController,
                        decoration: ThemeHelper().textInputDecoration('Tên*'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        validator: (item) {
                          return item!.length > 3 ? null : "Vui lòng nhập họ (ít nhất 4 ký tự)";
                        },
                        controller: _lastNameController,
                        decoration: ThemeHelper().textInputDecoration('Họ*'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SmallButtonsWidget(
                      title: "Gửi",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Get.back();
                          _handleRegister();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {});
  }

  _buildLogo() {
    return SizedBox(
      height: 130,
      child: Image.asset(ImageConstants.logoImage),
    );
  }

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
    });
    final res = await UserService.addUser(
      fName: _fNameController.text,
      lName: _lastNameController.text,
      isdCode: phoneCode,
      phone: _mobileController.text,
    );
    if (res != null) {
      IToastMsg.showMessage("Đăng ký thành công");
      _handleLogin();
    } else {
      setState(() {
        _isLoading = false;
      });
      _openBottomSheetForRegisterUser();
    }
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });
    final res = await UserService.loginUser(phone: _mobileController.text);
    if (res != null) {
      if (res['message'] == "Not Exists") {
        setState(() {
          _isLoading = false;
        });
        _openBottomSheetForRegisterUser();
      } else if (res['message'] == "Successfully") {
        IToastMsg.showMessage("Đăng nhập thành công");
        _handleSuccessLogin(res);
      }
    } else {
      IToastMsg.showMessage("Đã xảy ra lỗi");
      setState(() {
        _isLoading = false;
      });
    }
  }

  _handleSuccessLogin(var res) async {
    setState(() {
      _isLoading = true;
    });
    final userData = res;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(SharedPreferencesConstants.token, userData['token']);
    await preferences.setString(SharedPreferencesConstants.uid, userData['data']['id'].toString());
    await preferences.setString(SharedPreferencesConstants.name,
        "${userData['data']['f_name']} ${userData['data']['l_name']}");
    await preferences.setString(SharedPreferencesConstants.phone, userData['data']['phone']);
    await preferences.setBool(SharedPreferencesConstants.login, true);
    UserController userController = Get.find(tag: "user");
    userController.getData();
    UserService.updateFCM();
    UserSubscribe.toTopi(topicName: "PATIENT_APP");
    Get.back();
    if (widget.onSuccessLogin != null) {
      widget.onSuccessLogin!();
    }
    setState(() {
      _isLoading = false;
    });
  }
}
