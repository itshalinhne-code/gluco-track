import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../service/configuration_service.dart';
import '../utilities/app_constans.dart';
import '../utilities/image_constants.dart';
import '../widget/app_bar_widget.dart';
import '../widget/bottom_button.dart';
import '../widget/loading_Indicator_widget.dart';

class ShareAppPage extends StatefulWidget {
  const ShareAppPage({super.key});

  @override
  State<ShareAppPage> createState() => _ShareAppPageState();
}

class _ShareAppPageState extends State<ShareAppPage> {
  String appShareLink = "";

  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    getAndSetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: _isLoading
            ? const ILoadingIndicatorWidget()
            : IBottomNavBarWidget(
                onPressed: () {
                  if (appShareLink != "") {
                    Share.share('Tải ứng dụng ${AppConstants.appName} $appShareLink',
                        subject: AppConstants.appName);
                  }
                },
                title: "Chia sẻ"),
      ),
      appBar: IAppBar.commonAppBar(title: "Chia sẻ"),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child:
              //Container(color: Colors.red,)
              Image.asset(ImageConstants.shareImage),
        ),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
            ),
            SizedBox(width: 3),
            Text(
              "Chia sẻ ứng dụng với bạn bè",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 3),
            Icon(
              Icons.star,
              color: Colors.amber,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Nhấn vào nút chia sẻ để chia sẻ app tới mọi người thân của bạn",
            textAlign: TextAlign.center,
            style: const TextStyle(
              letterSpacing: 1,
              fontSize: 15,
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
    final res = await ConfigurationService.getDataById(
        idName: Platform.isAndroid
            ? "play_store_link_doctor_app"
            : Platform.isIOS
                ? "app_store_link_doctor_app"
                : "");
    if (res != null) {
      appShareLink = res.value ?? "";
    }
    // print("------------------$appShareLink");
    setState(() {
      _isLoading = false;
    });
  }
}
