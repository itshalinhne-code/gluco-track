import 'package:get/get.dart';
import '../model/patient_model.dart';
import '../services/patient_service.dart';

class PatientsController extends GetxController {
  var isLoading = false.obs; // Trạng thái đang tải dữ liệu
  var dataList = <PatientModel>[].obs; // Danh sách tất cả dữ liệu đã tải
  var isError = false.obs;

  void getData() async {
    isLoading(true);
    try {
      final getDataList = await PatientsService.getDataByUID();

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
