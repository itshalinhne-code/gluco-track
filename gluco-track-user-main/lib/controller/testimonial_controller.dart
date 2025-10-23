import 'package:get/get.dart';
import '../services/testimonial_service.dart';

class TestimonialController extends GetxController{
  var isLoading=false.obs; // Trạng thái đang tải dữ liệu
  var dataList= [].obs; // Đối tượng của mô hình bài đăng
  var isError=false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData("");
    super.onInit();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  void getData(clinicId)async{
    isLoading(true);
    try{
      final getDataList=await TestimonialsService.getData(clinicId); // Lấy danh sách chi tiết bài đánh giá từ trang dịch vụ
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
