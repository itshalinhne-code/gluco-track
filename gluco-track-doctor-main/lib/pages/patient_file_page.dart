import 'package:doctorapp/controller/patient_file_controller.dart';
import 'package:doctorapp/model/patient_file_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/date_time_helper.dart';
import '../utilities/api_content.dart';
import '../utilities/colors_constant.dart';
import '../widget/app_bar_widget.dart';
import '../widget/error_widget.dart';
import '../widget/image_box_widget.dart';
import '../widget/loading_Indicator_widget.dart';
import '../widget/no_data_widgets.dart';

class PatientFilePage extends StatefulWidget {
  final String? patientId;

  const PatientFilePage({super.key, this.patientId});

  @override
  State<PatientFilePage> createState() => _PatientFilePageState();
}

class _PatientFilePageState extends State<PatientFilePage> {
  PatientFileController patientFileController = Get.put(PatientFileController());
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    patientFileController.getData(widget.patientId ?? "", "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IAppBar.commonAppBar(title: "Hồ sơ bệnh nhân"),
      body: isLoading
          ? const ILoadingIndicatorWidget()
          : Obx(() {
              if (!patientFileController.isError.value) {
                if (patientFileController.isLoading.value) {
                  return const ILoadingIndicatorWidget();
                } else if (patientFileController.dataList.isEmpty) {
                  return const NoDataWidget();
                } else {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: patientFileController.dataList.length,
                    itemBuilder: (context, index) {
                      PatientFileModel patientFileModel = patientFileController.dataList[index];
                      return Card(
                        elevation: .1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: ColorResources.cardBgColor,
                        child: ListTile(
                          onTap: () async {
                            if (patientFileModel.fileUrl != null) {
                              try {
                                await launchUrl(
                                    Uri.parse(
                                        "${ApiContents.imageUrl}/${patientFileModel.fileUrl}"),
                                    mode: LaunchMode.externalApplication);
                              } catch (e) {
                                if (kDebugMode) {
                                  print(e);
                                }
                              }
                            }
                          },
                          contentPadding: const EdgeInsets.all(8),
                          leading: patientFileModel.fileUrl == null
                              ? const Icon(Icons.image)
                              : SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: ImageBoxFillWidget(
                                      imageUrl:
                                          "${ApiContents.imageUrl}/${patientFileModel.fileUrl}")),
                          title: Text(patientFileModel.fileName ?? "",
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          subtitle: Text(
                              DateTimeHelper.getDataFormat(patientFileModel.createdAt ?? ""),
                              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                        ),
                      );
                    },
                  );
                }
              } else {
                return const IErrorWidget();
              }
            }),
    );
  }
}
