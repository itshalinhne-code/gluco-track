import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../controller/appoitnment_controller_serach.dart';
import '../helper/route_helper.dart';
import '../model/appointment_model.dart';
import '../utilities/colors_constant.dart';
import '../widget/error_widget.dart';
import '../widget/loading_Indicator_widget.dart';
import '../widget/no_data_widgets.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String serviceName = "Tại phòng khám";
  AppointmentSearchController appointmentSearchController = Get.put(AppointmentSearchController());
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  RefreshController refreshController = RefreshController();
  int start = 0;
  int end = 20;

  @override
  void initState() {
    // TODO: implement initState
    appointmentSearchController.getData();
    super.initState();
  }

  void _onRefresh() async {
    refreshController.refreshCompleted();
  }

  void _onLoading() async {
    if (mounted) {
      setState(() {});
    }
    refreshController.loadComplete();
    end += 20;
    appointmentSearchController.getMoreDataData(0, end, _textEditingController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorResources.bgColor,
        appBar: AppBar(
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.white, //change your color here
          ),
          elevation: 0,
          backgroundColor: ColorResources.appBarColor,
          title: const Column(
            children: [
              Text(
                "Lịch hẹn",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onSubmitted: (value) {
                              appointmentSearchController.getData(
                                  0, 20, _textEditingController.text);
                            },
                            controller: _textEditingController,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: GestureDetector(
                            onTap: () {
                              _textEditingController.clear();
                              appointmentSearchController.getData(
                                  0, 20, _textEditingController.text);
                            },
                            child: const Icon(
                              Icons.clear,
                              color: ColorResources.greyBtnColor,
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider()
                ],
              ),
            ),
            Positioned(
              top: 90,
              bottom: 0,
              left: 0,
              right: 0,
              child: SmartRefresher(
                scrollController: _scrollController,
                enablePullDown: false,
                enablePullUp: true,
                header: null,
                footer: null,
                controller: refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: Obx(() {
                  if (!appointmentSearchController.isError.value) {
                    // if no any error
                    if (appointmentSearchController.isLoading.value) {
                      return const IVerticalListLongLoadingWidget();
                    } else if (appointmentSearchController.dataList.isEmpty) {
                      return const NoDataWidget();
                    } else {
                      return _upcomingAppointmentList(appointmentSearchController.dataList);
                    }
                  } else {
                    return const IErrorWidget();
                  } //Error svg
                }),
              ),
            ),
          ],
        ));
  }

  _upcomingAppointmentList(List dataList) {
    return ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: dataList.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return _card(dataList[index]);
        });
  }

  Widget _card(AppointmentModel appointmentModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
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
                                  _getStatusText(appointmentModel.status ?? "--"),
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
                                    Text(_getTypeText(appointmentModel.type ?? "--"),
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

  String _getStatusText(String status) {
    switch (status) {
      case "Pending":
        return "Chờ xác nhận";
      case "Rescheduled":
        return "Đã lên lịch lại";
      case "Rejected":
        return "Từ chối";
      case "Confirmed":
        return "Đã xác nhận";
      case "Completed":
        return "Hoàn thành";
      default:
        return status;
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case "Offline":
        return "Tại phòng khám";
      case "Video":
        return "Khám video";
      case "Emergency":
        return "Khám cấp cứu";
      default:
        return type;
    }
  }

  Widget _appointmentDate(date) {
    var appointmentDate = date.split("-");
    String appointmentMonth = "";
    switch (int.parse(appointmentDate[1])) {
      case 1:
        appointmentMonth = "THÁNG 1";
        break;
      case 2:
        appointmentMonth = "THÁNG 2";
        break;
      case 3:
        appointmentMonth = "THÁNG 3";
        break;
      case 4:
        appointmentMonth = "THÁNG 4";
        break;
      case 5:
        appointmentMonth = "THÁNG 5";
        break;
      case 6:
        appointmentMonth = "THÁNG 6";
        break;
      case 7:
        appointmentMonth = "THÁNG 7";
        break;
      case 8:
        appointmentMonth = "THÁNG 8";
        break;
      case 9:
        appointmentMonth = "THÁNG 9";
        break;
      case 10:
        appointmentMonth = "THÁNG 10";
        break;
      case 11:
        appointmentMonth = "THÁNG 11";
        break;
      case 12:
        appointmentMonth = "THÁNG 12";
        break;
    }

    return Column(
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
}
