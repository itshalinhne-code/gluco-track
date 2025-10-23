import '../helper/get_req_helper.dart';
import '../model/configuration_model.dart';
import '../utilities/api_content.dart';

class ConfigurationService {
  static const getConfigByIdNameApiUrl = ApiContents.getConfigByIdNameApiUrl;
  static const getConfigurationsAllURL = ApiContents.getConfigurationsAllURL;

  static List<ConfigurationModel> dataFromJson(jsonDecodedData) {
    return List<ConfigurationModel>.from(
        jsonDecodedData.map((item) => ConfigurationModel.fromJson(item)));
  }

  static ConfigurationModel dataFromJsonById(data) {
    return ConfigurationModel.fromJson(data);
  }

  static Future<ConfigurationModel?> getDataById({required String? idName}) async {
    final res = await GetService.getReq("$getConfigByIdNameApiUrl/${idName ?? ""}");
    if (res == null) {
      return null;
    } else {
      ConfigurationModel dataModel = dataFromJsonById(res);
      return dataModel;
    }
  }

  static Future getAllData() async {
    final res = await GetService.getReq(getConfigurationsAllURL);
    if (res == null) {
      return null;
    } else {
      return res;
    }
  }
}
