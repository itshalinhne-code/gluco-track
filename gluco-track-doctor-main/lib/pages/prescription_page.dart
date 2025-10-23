import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/prescription_controller.dart';
import '../helper/date_time_helper.dart';
import '../helper/route_helper.dart';
import '../model/prescription_model.dart';
import '../service/prescription_service.dart';
import '../utilities/api_content.dart';
import '../utilities/colors_constant.dart';
import '../widget/app_bar_widget.dart';
import '../widget/error_widget.dart';
import '../widget/loading_Indicator_widget.dart';
import '../widget/no_data_widgets.dart';
import '../widget/toast_message.dart';

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({super.key});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  PrescriptionController prescriptionController = Get.put(PrescriptionController());
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    prescriptionController.getDataByDoctorId("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: IAppBar.commonAppBar(title: "Đơn thuốc"),
        body: _isLoading
            ? const ILoadingIndicatorWidget()
            : ListView(
                controller: _scrollController,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onSubmitted: (value) {
                              prescriptionController.getDataByDoctorId(_textEditingController.text);
                              // appointmentSearchController.getData(0,20,_textEditingController.text);
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
                              prescriptionController.getDataByDoctorId("");
                              //    appointmentSearchController.getData(0,20,_textEditingController.text);
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
                  Obx(() {
                    if (!prescriptionController.isError.value) {
                      // if no any error
                      if (prescriptionController.isLoading.value) {
                        return const IVerticalListLongLoadingWidget();
                      } else if (prescriptionController.dataList.isEmpty) {
                        return const NoDataWidget();
                      } else {
                        return dataList(prescriptionController.dataList);
                      }
                    } else {
                      return const IErrorWidget();
                    } //Error svg
                  }),
                ],
              ));
  }

  Widget dataList(RxList<PrescriptionModel> dataList) {
    return ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          PrescriptionModel prescriptionModel = dataList[index];
          return Card(
            color: ColorResources.cardBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: .1,
            child: ListTile(
              title: Text(
                "${prescriptionModel.patientFName} ${prescriptionModel.patientLName}",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 3),
                  Text(
                    "Mã đơn thuốc #${prescriptionModel.id}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Mã lịch hẹn #${prescriptionModel.appointmentId}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateTimeHelper.getDataFormat(prescriptionModel.createdAt),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () async {
                            if (prescriptionModel.pdfFile != null &&
                                prescriptionModel.pdfFile != "") {
                              await launchUrl(
                                  Uri.parse("${ApiContents.imageUrl}/${prescriptionModel.pdfFile}"),
                                  mode: LaunchMode.externalApplication);
                            } else {
                              await launchUrl(
                                  Uri.parse(
                                    "${ApiContents.prescriptionUrl}/${prescriptionModel.id}",
                                  ),
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(
                            Icons.download,
                            color: Colors.green,
                            size: 20,
                          )),
                      prescriptionModel.pdfFile != null
                          ? Container()
                          : IconButton(
                              onPressed: () {
                                Get.toNamed(RouteHelper.getAddPrescriptionPageRoute(
                                    appId: prescriptionModel.appointmentId.toString(),
                                    prescriptionId: prescriptionModel.id.toString()));
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.grey,
                                size: 20,
                              )),
                      IconButton(
                          onPressed: () {
                            _openDialogDeletePrescriptionBox(prescriptionModel.id.toString());
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                            size: 20,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  _openDialogDeletePrescriptionBox(String id) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon cảnh báo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),

                // Tiêu đề
                const Text(
                  "Xóa đơn thuốc",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Nội dung
                Text(
                  "Bạn có chắc chắn muốn xóa đơn thuốc #$id ?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),

                // Nút bấm
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Không",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _handleDeletePrescription(id);
                        },
                        child: const Text(
                          "Có",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleDeletePrescription(String id) async {
    setState(() {
      _isLoading = true;
    });
    final res = await PrescriptionService.deleteData(id: id);
    if (res != null) {
      if (res['response'] == 200) {
        prescriptionController.getDataByDoctorId("");
        IToastMsg.showMessage("Xóa đơn thuốc thành công");
      } else {
        IToastMsg.showMessage("Xóa đơn thuốc thất bại");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
}
