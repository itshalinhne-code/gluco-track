import 'package:get/get.dart';
import 'package:userapp/model/clinic_model.dart';
import '../services/clinic_service.dart';

class ClinicController extends GetxController {
  var isLoading = false.obs; // Trạng thái đang tải dữ liệu
  var dataList = <ClinicModel>[].obs; // Danh sách tất cả dữ liệu đã tải
  var isError = false.obs;
  var dataMap = ClinicModel().obs; // Danh sách tất cả dữ liệu đã tải

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  void getData(String start, String end, String cityId) async {
    isLoading(true);
    try {
      final getDataList = await ClinicService.getData(start: start, end: end, cityId: cityId);

      if (getDataList != null) {
        isError(false);
        dataList.value = getDataList;
      } else {
        isError(true);
      }
    } catch (e) {
      isError(true);
    } finally {
      isLoading(false);
    }
  }
}
