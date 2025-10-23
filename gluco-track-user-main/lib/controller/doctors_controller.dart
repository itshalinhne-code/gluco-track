import 'package:get/get.dart';
import '../model/doctors_model.dart';
import '../services/doctor_service.dart';

class DoctorsController extends GetxController {
  var isLoading = false.obs; // Trạng thái đang tải dữ liệu
  var dataList = <DoctorsModel>[].obs; // Danh sách tất cả dữ liệu đã tải
  var isError = false.obs;
  var dataMap = DoctorsModel().obs; // Danh sách tất cả dữ liệu đã tải

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  void getData(String searchQuery, String cityId) async {
    isLoading(true);
    try {
      final getDataList = await DoctorsService.getData(searchQuery: searchQuery, cityId: cityId);

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

  void getDataByDoctId(String doctId) async {
    isLoading(true);
    try {
      final getData = await DoctorsService.getDataById(doctId: doctId);

      if (getData != null) {
        isError(false);
        dataMap.value = getData;
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
