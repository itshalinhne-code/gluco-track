import 'package:get/get.dart';
import 'package:userapp/services/patient_files_service.dart';

class PatientFileController extends GetxController{
  var isLoading=false.obs; // Trạng thái đang tải dữ liệu
  var dataList= [].obs; // Đối tượng của mô hình hồ sơ bệnh nhân
  var isError=false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  void getData(String searchQ)async{
    isLoading(true);
    try{
      final getDataList=await PatientFilesService.getData(searchQ); // Lấy danh sách chi tiết hồ sơ bệnh nhân từ trang dịch vụ
      if (getDataList!=null) {
        isLoading(false);
        dataList.value=getDataList;
      } else {
        isError(true);
      } // Nếu có lỗi
    }
    catch(e){
      isError(true);  // Nếu có lỗi
    }
    finally{
      isLoading(false); // Chạy khối try với lỗi hoặc không có lỗi
    }

  }


}
