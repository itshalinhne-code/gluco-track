import 'package:get/get.dart';
import '../model/prescription_model.dart';
import '../services/prescription_service.dart';

class PrescriptionController extends GetxController {
  var isLoading = false.obs; // Trạng thái đang tải dữ liệu
  var dataList = <PrescriptionModel>[].obs; // Danh sách tất cả dữ liệu đã tải
  var isError = false.obs;

  void getData({required String appointmentId}) async {
    isLoading(true);
    try {
      final getDataList = await PrescriptionService.getData(appointmentId: appointmentId);

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
  void getDataBYUid() async {
    isLoading(true);
    try {
      final getDataList = await PrescriptionService.getDataByUid();

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
