import 'package:get/get.dart';
import '../services/vitals_service.dart';

class VitalController extends GetxController{
  var isLoading=false.obs; // Trạng thái đang tải dữ liệu
  var dataList= [].obs; // Đối tượng của mô hình chỉ số sinh tồn
  var isError=false.obs;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  void getData(String familyMemberId,String type,String startDate,String endDate)async{
    isLoading(true);
    try{
      final getDataList=await VitalsService.getData(familyMemberId,type,startDate,endDate); // Lấy danh sách chỉ số sinh tồn từ dịch vụ
      if (getDataList!=null) {
        isError(false);
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
