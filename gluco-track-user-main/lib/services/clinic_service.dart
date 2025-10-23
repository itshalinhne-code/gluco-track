import 'package:userapp/model/clinic_model.dart';
import '../helpers/get_req_helper.dart';
import '../utilities/api_content.dart';


class ClinicService{

  static const  getUrl=   ApiContents.getClinicUrl;
  static const  getClinicByIdUrl=   ApiContents.getClinicByIdUrl;

  static List<ClinicModel> dataFromJson (jsonDecodedData){

    return List<ClinicModel>.from(jsonDecodedData.map((item)=>ClinicModel.fromJson(item)));
  }


  static Future <List<ClinicModel>?> getData({String? start,String? end,String? cityId})async {
    final body = {
      "start":start,
      "end":end,
      "city_id":cityId,
      "active":1
    };
    final res=await GetService.getReqWithBodY(getUrl,body);
    if(res==null) {
      return null; //check if any null value
    } else {
      List<ClinicModel> dataModelList = dataFromJson(res); // convert all list to model
      return dataModelList;  // return converted data list model
    }
  }
  static Future <ClinicModel?> getDataById({required String? clinicId})async {
    final res=await GetService.getReq("$getClinicByIdUrl/${clinicId??""}");
    if(res==null) {
      return null;
    } else {
      ClinicModel dataModel = ClinicModel.fromJson(res);
      return dataModel;
    }
  }

}