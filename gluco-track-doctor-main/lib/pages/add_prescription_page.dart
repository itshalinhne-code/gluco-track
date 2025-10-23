import 'dart:io';

import 'package:doctorapp/utilities/sharedpreference_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/prescription_controller.dart';
import '../helper/theme_helper.dart';
import '../model/appointment_model.dart';
import '../model/medication.dart';
import '../model/medicine_model.dart';
import '../model/prescription_model.dart';
import '../service/appointment_Service.dart';
import '../service/medication_service.dart';
import '../service/prescription_service.dart';
import '../utilities/colors_constant.dart';
import '../widget/app_bar_widget.dart';
import '../widget/bottom_button.dart';
import '../widget/button_widget.dart';
import '../widget/input_label_widget.dart';
import '../widget/loading_Indicator_widget.dart';
import '../widget/toast_message.dart';

class AddPrescriptionPage extends StatefulWidget {
  final String? appId;
  final String? prescriptionId;
  const AddPrescriptionPage({super.key, required this.appId, this.prescriptionId});

  @override
  State<AddPrescriptionPage> createState() => _AddPrescriptionPageState();
}

class _AddPrescriptionPageState extends State<AddPrescriptionPage> {
  PrescriptionController prescriptionController = Get.find<PrescriptionController>();
  final TextEditingController _testController = TextEditingController();
  final TextEditingController _adviceController = TextEditingController();
  final TextEditingController _problemDescController = TextEditingController();
  final TextEditingController _foodAllergiesController = TextEditingController();
  final TextEditingController _tendencyBleedController = TextEditingController();
  final TextEditingController _heartDiseaseController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _diabeticController = TextEditingController();
  final TextEditingController _surgeryController = TextEditingController();
  final TextEditingController _accidentController = TextEditingController();
  final TextEditingController _othersController = TextEditingController();
  final TextEditingController _medicalHistoryController = TextEditingController();
  final TextEditingController _currentMedicationController = TextEditingController();
  final TextEditingController _femalePregnancyController = TextEditingController();
  final TextEditingController _breastFeedingController = TextEditingController();
  final TextEditingController _pulseRateController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _nextVisitController = TextEditingController();
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String selectedDosage = "1";
  String selectedDuration = "Trong 3 ngày";
  String selectedTime = "Sau bữa ăn";
  String selectedDoseInterval = "Một lần một ngày";
  bool _isLoading = false;
  List<Medication> medicationList = [];
  List<MedicineModel> _suggestions = [];
  AppointmentModel? appointmentModel;
  PrescriptionModel? prescriptionModel;
  @override
  void initState() {
    // TODO: implement initState
    getAndSetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: IBottomNavBarWidget(
        title: "Lưu",
        onPressed: medicationList.isEmpty || _isLoading
            ? null
            : () {
                if (widget.prescriptionId != "" && widget.prescriptionId != null) {
                  _handleUpdateData();
                } else {
                  _handleAddData();
                }
              },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorResources.btnColor,
        onPressed: _isLoading
            ? null
            : () {
                _openBottomSheetAddMedicine();
              },
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: IAppBar.commonAppBar(
          title: widget.prescriptionId != "" && widget.prescriptionId != null
              ? "Cập nhật đơn thuốc"
              : "Thêm đơn thuốc"),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return _isLoading
        ? const ILoadingIndicatorWidget()
        : ListView(
            padding: const EdgeInsets.all(8),
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: medicationList.length,
                  itemBuilder: (context, index) {
                    Medication medication = medicationList[index];
                    return buildMedicineList(medication, index);
                  }),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Vấn đề"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  maxLines: 5,
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _problemDescController,
                  decoration: ThemeHelper().textInputDecoration('Vấn đề'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Xét nghiệm"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  maxLines: 5,
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _testController,
                  decoration: ThemeHelper().textInputDecoration('Xét nghiệm'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Lời khuyên"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  maxLines: 5,
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _adviceController,
                  decoration: ThemeHelper().textInputDecoration('Lời khuyên'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Lần tái khám tiếp theo"),
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
                  validator: null,
                  controller: _nextVisitController,
                  decoration: ThemeHelper().textInputDecoration('Lần tái khám tiếp theo (ngày)'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Dị ứng thực phẩm"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _foodAllergiesController,
                  decoration: ThemeHelper().textInputDecoration('Dị ứng thực phẩm'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Xu hướng chảy máu"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _tendencyBleedController,
                  decoration: ThemeHelper().textInputDecoration('Xu hướng chảy máu'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Bệnh tim"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _heartDiseaseController,
                  decoration: ThemeHelper().textInputDecoration('Bệnh tim'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Huyết áp"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _bloodPressureController,
                  decoration: ThemeHelper().textInputDecoration('Huyết áp'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Đái tháo đường"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _diabeticController,
                  decoration: ThemeHelper().textInputDecoration('Đái tháo đường'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Phẫu thuật"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _surgeryController,
                  decoration: ThemeHelper().textInputDecoration('Phẫu thuật'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Tai nạn"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _accidentController,
                  decoration: ThemeHelper().textInputDecoration('Tai nạn'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Khác"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _othersController,
                  decoration: ThemeHelper().textInputDecoration('Khác'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Lịch sử bệnh"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _medicalHistoryController,
                  decoration: ThemeHelper().textInputDecoration('Lịch sử bệnh'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Điều trị hiện tại"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _currentMedicationController,
                  decoration: ThemeHelper().textInputDecoration('Điều trị hiện tại'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Phụ nữ mang thai"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _femalePregnancyController,
                  decoration: ThemeHelper().textInputDecoration('Phụ nữ mang thai'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Sữa mẹ"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _breastFeedingController,
                  decoration: ThemeHelper().textInputDecoration('Sữa mẹ'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Nhịp tim"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _pulseRateController,
                  decoration: ThemeHelper().textInputDecoration('Nhịp tim'),
                ),
              ),
              const SizedBox(height: 10),
              InputLabel.buildLabelBox("Nhiệt độ"),
              const SizedBox(height: 10),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  validator: null,
                  controller: _temperatureController,
                  decoration: ThemeHelper().textInputDecoration('Nhiệt độ'),
                ),
              ),
            ],
          );
  }

  // Function to get suggestions based on the query
  Future<List<MedicineModel>> _getSuggestions(String query) async {
    // Filter medicines based on title and notes
    final List<MedicineModel> matches = _suggestions.where((medicine) {
      return medicine.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return matches;
  }

  _openBottomSheetAddMedicine() {
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
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: const Text('Danh sách thuốc',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          )),
                    ),
                    const SizedBox(height: 20),
                    const Text('Thêm thuốc',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        )),
                    const SizedBox(height: 20),
                    TypeAheadField<MedicineModel>(
                      controller: _medicineNameController,
                      suggestionsCallback: _getSuggestions,
                      builder: (context, controller, focusNode) {
                        return Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            keyboardType: Platform.isIOS
                                ? const TextInputType.numberWithOptions(decimal: true, signed: true)
                                : TextInputType.name,
                            validator: null,
                            controller: controller,
                            focusNode: focusNode,
                            decoration: ThemeHelper().textInputDecoration('Thuốc'),
                          ),
                        );
                      },
                      itemBuilder: (context, medicineModel) {
                        return ListTile(
                          title: Text(
                            medicineModel.title,
                            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                          ),
                          subtitle: Text(
                            medicineModel.notes,
                            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                          ),
                        );
                      },
                      onSelected: (text) {
                        _medicineNameController.text = text.title;
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    InputLabel.buildLabelBox("Liều lượng"),
                    const SizedBox(height: 10),
                    InputDecorator(
                      decoration: ThemeHelper().textInputDecoration('Liều lượng*'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          padding: EdgeInsets.zero,
                          value: selectedDosage,
                          hint: const Text('Liều lượng',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                          items: <String>['1', '2', '3', '4', '5', '6'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDosage = newValue ?? "";
                            });
                          },
                          isExpanded: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InputLabel.buildLabelBox("Thời gian"),
                    const SizedBox(height: 10),
                    InputDecorator(
                      decoration: ThemeHelper().textInputDecoration('Thời gian*'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          padding: EdgeInsets.zero,
                          value: selectedDuration,
                          hint: const Text('Thời gian',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                          items: <String>[
                            'Trong 1 ngày',
                            'Trong 2 ngày',
                            'Trong 3 ngày',
                            'Trong 7 ngày',
                            'Trong 15 ngày',
                            'Trong 1 tháng'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDuration = newValue ?? "";
                            });
                          },
                          isExpanded: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InputLabel.buildLabelBox("Thời gian"),
                    const SizedBox(height: 10),
                    InputDecorator(
                      decoration: ThemeHelper().textInputDecoration('Thời gian*'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          padding: EdgeInsets.zero,
                          value: selectedTime,
                          hint: const Text('Thời gian',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                          items: <String>['Sau bữa ăn', 'Trước bữa ăn'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedTime = newValue ?? "";
                            });
                          },
                          isExpanded: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InputLabel.buildLabelBox("Khoảng cách liều"),
                    const SizedBox(height: 10),
                    InputDecorator(
                      decoration: ThemeHelper().textInputDecoration('Khoảng cách liều*'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          padding: EdgeInsets.zero,
                          value: selectedDoseInterval,
                          hint: const Text('Khoảng cách liều',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                          items: <String>[
                            'Một lần một ngày',
                            'Mỗi sáng và tối',
                            '3 lần một ngày',
                            '4 lần một ngày'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDoseInterval = newValue ?? "";
                            });
                          },
                          isExpanded: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InputLabel.buildLabelBox("Ghi chú"),
                    const SizedBox(height: 10),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        validator: null,
                        controller: _notesController,
                        decoration: ThemeHelper().textInputDecoration('Ghi chú'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SmallButtonsWidget(
                        title: "Thêm",
                        onPressed: () {
                          if (_medicineNameController.text.isEmpty) {
                            IToastMsg.showMessage("Vui lòng chọn thuốc");
                            return;
                          }
                          bool isNeedToAdd = true;
                          Medication medication = Medication(
                              medicineName: _medicineNameController.text,
                              dosage: selectedDosage,
                              duration: selectedDuration,
                              time: selectedTime,
                              doseInterval: selectedDoseInterval,
                              notes: _notesController.text);
                          for (var e in medicationList) {
                            if (e.medicineName == medication.medicineName) {
                              isNeedToAdd = false;
                              IToastMsg.showMessage("Tên thuốc đã tồn tại");
                              break;
                            }
                          }
                          if (isNeedToAdd == false) {
                            return;
                          }
                          medicationList.add(medication);
                          Get.back();
                          clearData();
                        }),
                  ],
                ),
              ),
            ),
          );
        });
      },
    ).whenComplete(() {});
  }

  buildMedicineList(Medication medication, int index) {
    return Card(
      elevation: .1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: ColorResources.cardBgColor,
      child: ListTile(
        trailing: IconButton(
            onPressed: () {
              _openDialogBox(medication.medicineName, index);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.redAccent,
            )),
        title: Text(
          "${index + 1} - ${medication.medicineName}",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Liều lượng - ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                Text(
                  medication.dosage,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text("Khoảng thời gian - ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                Text(
                  medication.duration,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text("Thời gian - ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                Text(
                  medication.time,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text("Khoảng cách liều - ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                Flexible(
                  child: Text(
                    medication.doseInterval,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
            medication.notes == ""
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      children: [
                        const Text("Ghi chú - ",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                        Flexible(
                          child: Text(
                            medication.notes,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }

  _openDialogBox(String medicineName, index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            "Xóa",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Bạn có chắc chắn muốn xóa $medicineName",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
              const SizedBox(height: 10),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.btnColorRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Không",
                    style:
                        TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.btnColorGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Có",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  medicationList.removeAt(index);
                  setState(() {});
                }),
            // usually buttons at the bottom of the dialog
          ],
        );
      },
    );
  }

  void getAndSetData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String clinicId = preferences.getString(SharedPreferencesConstants.clinicId) ?? "";
    final res = await MedicationService.getData(clinicId);
    if (res != null) {
      _suggestions = res;
    }

    final resApp = await AppointmentService.getDataById(appId: widget.appId);
    if (resApp != null) {
      appointmentModel = resApp;
    }
    if (widget.prescriptionId != "" && widget.prescriptionId != null) {
      final resPresc = await PrescriptionService.getDataByPrescriptionId(
          prescriptionId: widget.prescriptionId ?? "");
      if (resPresc != null) {
        prescriptionModel = resPresc;
        _testController.text = prescriptionModel?.test ?? "";
        _adviceController.text = prescriptionModel?.advice ?? "";
        _problemDescController.text = prescriptionModel?.problemDesc ?? "";
        _foodAllergiesController.text = prescriptionModel?.foodAllergies ?? "";
        _tendencyBleedController.text = prescriptionModel?.tendencyBleed ?? "";
        _heartDiseaseController.text = prescriptionModel?.heartDisease ?? "";
        _bloodPressureController.text = prescriptionModel?.bloodPressure ?? "";
        _diabeticController.text = prescriptionModel?.diabetic ?? "";
        _surgeryController.text = prescriptionModel?.surgery ?? "";
        _accidentController.text = prescriptionModel?.accident ?? "";
        _othersController.text = prescriptionModel?.others ?? "";
        _medicalHistoryController.text = prescriptionModel?.medicalHistory ?? "";
        _currentMedicationController.text = prescriptionModel?.currentMedication ?? "";
        _femalePregnancyController.text = prescriptionModel?.femalePregnancy ?? "";
        _breastFeedingController.text = prescriptionModel?.breastFeeding ?? "";
        _pulseRateController.text = prescriptionModel?.pulseRate ?? "";
        _temperatureController.text = prescriptionModel?.temperature ?? "";
        _nextVisitController.text = prescriptionModel?.nextVisit ?? "";
        _notesController.text = prescriptionModel?.notes ?? "";
        if (prescriptionModel?.items != null) {
          final List dataList = prescriptionModel!.items!;
          medicationList.clear();
          for (var e in dataList) {
            medicationList.add(Medication(
              medicineName: e['medicine_name'],
              dosage: e['dosage'] ?? "",
              duration: e['duration'] ?? "",
              time: e['time'] ?? "",
              doseInterval: e['dose_interval'] ?? "",
              notes: e['notes'] ?? "",
            ));
          }
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void clearData() {
    selectedDosage = "1";
    selectedDuration = "Trong 3 ngày";
    selectedTime = "Sau bữa ăn";
    selectedDoseInterval = "Một lần một ngày";
    _medicineNameController.text = "";
    _notesController.text = "";
    setState(() {});
  }

  void _handleAddData() async {
    setState(() {
      _isLoading = true;
    });
    final res = await PrescriptionService.addData(
        patientId: appointmentModel?.patientId.toString() ?? "",
        test: _testController.text,
        advice: _adviceController.text,
        problemDesc: _problemDescController.text,
        foodAllergies: _foodAllergiesController.text,
        tendencyBleed: _tendencyBleedController.text,
        heartDisease: _heartDiseaseController.text,
        bloodPressure: _bloodPressureController.text,
        diabetic: _diabeticController.text,
        surgery: _surgeryController.text,
        accident: _accidentController.text,
        others: _othersController.text,
        medicalHistory: _medicalHistoryController.text,
        currentMedication: _currentMedicationController.text,
        femalePregnancy: _femalePregnancyController.text,
        breastFeeding: _breastFeedingController.text,
        pulseRate: _pulseRateController.text,
        temperature: _temperatureController.text,
        nextVisit: _nextVisitController.text,
        appointmentId: widget.appId ?? "",
        medicationList: medicationList);
    if (res != null) {
      IToastMsg.showMessage("success");
      prescriptionController.getData(appointmentId: widget.appId ?? "");
      Get.back();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _handleUpdateData() async {
    setState(() {
      _isLoading = true;
    });
    final res = await PrescriptionService.updateData(
        id: widget.prescriptionId ?? "",
        test: _testController.text,
        advice: _adviceController.text,
        problemDesc: _problemDescController.text,
        foodAllergies: _foodAllergiesController.text,
        tendencyBleed: _tendencyBleedController.text,
        heartDisease: _heartDiseaseController.text,
        bloodPressure: _bloodPressureController.text,
        diabetic: _diabeticController.text,
        surgery: _surgeryController.text,
        accident: _accidentController.text,
        others: _othersController.text,
        medicalHistory: _medicalHistoryController.text,
        currentMedication: _currentMedicationController.text,
        femalePregnancy: _femalePregnancyController.text,
        breastFeeding: _breastFeedingController.text,
        pulseRate: _pulseRateController.text,
        temperature: _temperatureController.text,
        nextVisit: _nextVisitController.text,
        medicationList: medicationList);
    if (res != null) {
      IToastMsg.showMessage("success");
    }
    setState(() {
      _isLoading = false;
    });
  }
}
