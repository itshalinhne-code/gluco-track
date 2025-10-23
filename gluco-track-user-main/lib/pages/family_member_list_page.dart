import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/family_members_controller.dart';
import '../helpers/date_time_helper.dart';
import '../helpers/theme_helper.dart';
import '../model/family_members_model.dart';
import '../services/family_members_service.dart';
import '../utilities/app_constans.dart';
import '../utilities/colors_constant.dart';
import '../widget/app_bar_widget.dart';
import '../widget/button_widget.dart';
import '../widget/loading_Indicator_widget.dart';
import '../widget/toast_message.dart';

class FamilyMemberListPage extends StatefulWidget {
  const FamilyMemberListPage({super.key});

  @override
  State<FamilyMemberListPage> createState() => _FamilyMemberListPageState();
}

class _FamilyMemberListPageState extends State<FamilyMemberListPage> {
  final FamilyMembersController _familyMembersController = FamilyMembersController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _isLoading = false;
  String? selectedDate = "";
  String? selectedFamilyMemberId = "";
  String? selectedGender;
  final _formKey = GlobalKey<FormState>();
  String phoneCode = "+";

  @override
  void initState() {
    phoneCode = AppConstants.defaultCountyCode;
    // TODO: implement initState
    _familyMembersController.getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorResources.btnColor,
        onPressed: () {
          // Add your onPressed code here!
          clearData();
          _openBottomSheetAddFamilyMember(true);
        },
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: IAppBar.commonAppBar(title: "Thành viên gia đình"),
      body: _isLoading ? const ILoadingIndicatorWidget() : _buildBody(),
    );
  }

  _buildBody() {
    return Obx(() {
      if (!_familyMembersController.isError.value && !_familyMembersController.isError.value) {
        // if no any error
        if (_familyMembersController.isLoading.value || _familyMembersController.isLoading.value) {
          return const ILoadingIndicatorWidget();
        } else if (_familyMembersController.dataList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Không tìm thấy thành viên gia đình. Nhấn nút + ở dưới để thêm mới.",
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
            ),
          );
        } else {
          return _buildMembersList(_familyMembersController.dataList);
        }
      } else {
        return const Text("Đã xảy ra lỗi");
      } //Error svg
    });
  }

  _buildMembersList(List dataList) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          FamilyMembersModel familyMembersModel = dataList[index];
          return Card(
            color: ColorResources.cardBgColor,
            elevation: .1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            child: ListTile(
              onTap: () async {
                _fNameController.text = familyMembersModel.fName ?? "";
                _lNameController.text = familyMembersModel.lName ?? "";
                _mobileController.text = familyMembersModel.phone ?? "";
                if (familyMembersModel.dob != null && familyMembersModel.dob != "") {
                  _dobController.text = DateTimeHelper.getDataFormat(familyMembersModel.dob);
                  selectedDate = familyMembersModel.dob;
                }
                if (familyMembersModel.isdCode != null && familyMembersModel.isdCode != "") {
                  phoneCode = familyMembersModel.isdCode!;
                }
                if (familyMembersModel.gender != null && familyMembersModel.gender != "") {
                  selectedGender = familyMembersModel.gender.toString();
                }
                selectedFamilyMemberId = familyMembersModel.id?.toString() ?? "";
                _openBottomSheetAddFamilyMember(false);
              },
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () {
                  _openDialogBox(familyMembersModel);
                },
              ),
              title: Text(
                "${familyMembersModel.fName ?? ""} ${familyMembersModel.lName ?? ""}",
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      familyMembersModel.gender == null || familyMembersModel.gender == ""
                          ? Container()
                          : Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 18,
                                  color: ColorResources.greyBtnColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  familyMembersModel.gender ?? "--",
                                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                                ),
                              ],
                            ),
                      familyMembersModel.gender == null || familyMembersModel.gender == ""
                          ? Container()
                          : const SizedBox(width: 5),
                      familyMembersModel.dob == null || familyMembersModel.dob == ""
                          ? Container()
                          : Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  size: 18,
                                  color: ColorResources.greyBtnColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  DateTimeHelper.getDataFormat(familyMembersModel.dob),
                                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                                ),
                              ],
                            ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 18,
                        color: ColorResources.greyBtnColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "+84${familyMembersModel.phone ?? "--"}",
                        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  _openBottomSheetAddFamilyMember(bool isForAdding) {
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${isForAdding ? "Thêm" : "Cập nhật"} Thành viên gia đình",
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        validator: (item) {
                          return item!.length > 3 ? null : "Nhập tên";
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
                          return item!.length > 3 ? null : "Nhập họ";
                        },
                        controller: _lNameController,
                        decoration: ThemeHelper().textInputDecoration('Họ'),
                      ),
                    ),
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
                            return item!.length > 5 ? null : "Nhập số điện thoại hợp lệ";
                          },
                          controller: _mobileController,
                          decoration: InputDecoration(
                            prefixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 9),
                                GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      "+84",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              ],
                            ),
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
                          )),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                      child: TextFormField(
                          readOnly: true,
                          onTap: () {
                            _selectDate(context);
                          },
                          validator: null,
                          controller: _dobController,
                          decoration: InputDecoration(
                            hintText: "DOB",
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
                          )),
                    ),
                    const SizedBox(height: 10),
                    InputDecorator(
                      decoration: ThemeHelper().textInputDecoration('Chọn giới tính*'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          padding: EdgeInsets.zero,
                          value: selectedGender,
                          hint: const Text('Chọn giới tính',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                          items: <String>['Male', 'Female', 'Other'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedGender = newValue;
                            });
                          },
                          isExpanded: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SmallButtonsWidget(
                        title: "Lưu",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Get.back();
                            if (isForAdding) {
                              handleAddUserDataData();
                            } else if (!isForAdding) {
                              handleUpdateUserDataData();
                            }
                            //  handleAddData();
                          }
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

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
        _dobController.text = DateTimeHelper.getDataFormat(selectedDate);
      });
    }
  }

  void handleUpdateUserDataData() async {
    setState(() {
      _isLoading = true;
    });

    final res = await FamilyMembersService.updateUser(
        id: selectedFamilyMemberId,
        dob: selectedDate ?? "",
        gender: selectedGender ?? "",
        fName: _fNameController.text,
        lName: _lNameController.text,
        isdCode: phoneCode,
        phone: _mobileController.text);
    if (res != null) {
      IToastMsg.showMessage("Thành công");
      _familyMembersController.getData();
      clearData();
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void handleAddUserDataData() async {
    setState(() {
      _isLoading = true;
    });

    final res = await FamilyMembersService.addUser(
        dob: selectedDate ?? "",
        gender: selectedGender ?? "",
        fName: _fNameController.text,
        lName: _lNameController.text,
        isdCode: phoneCode,
        phone: _mobileController.text);
    if (res != null) {
      IToastMsg.showMessage("Thành công");
      _familyMembersController.getData();
      clearData();
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void handleDeleteDataData(String id) async {
    setState(() {
      _isLoading = true;
    });

    final res = await FamilyMembersService.deleteData(id: id);
    if (res != null) {
      IToastMsg.showMessage("Thành công");
      _familyMembersController.getData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _openDialogBox(FamilyMembersModel familyMembersModel) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_outline,
                  color: ColorResources.redColor,
                  size: 60,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Xóa thành viên",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  "Bạn có chắc chắn muốn xóa ${familyMembersModel.fName ?? ''} ${familyMembersModel.lName ?? ''} khỏi danh sách không?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: ColorResources.secondaryFontColor,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: ColorResources.greyBtnColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          "Hủy",
                          style: TextStyle(
                            color: ColorResources.greyBtnColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorResources.redColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          "Xóa",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          handleDeleteDataData(familyMembersModel.id.toString());
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void clearData() {
    _fNameController.clear();
    _lNameController.clear();
    _dobController.clear();
    _mobileController.clear();
    selectedGender = null;
    selectedDate = "";
    selectedFamilyMemberId = "";
  }
}
