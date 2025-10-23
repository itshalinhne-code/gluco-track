import '../helper/post_req_helper.dart';
import '../model/user_model.dart';
import '../utilities/api_content.dart';

class LoginService {
  static const loginUrl = ApiContents.loginUrl;

  static List<UserModel> dataFromJson(jsonDecodedData) {
    return List<UserModel>.from(jsonDecodedData.map((item) => UserModel.fromJson(item)));
  }

  static Future login({
    required String email,
    required String password,
  }) async {
    Map body = {'email': email, 'password': password};
    final res = await PostService.postReq(loginUrl, body);
    return res;
  }
}
