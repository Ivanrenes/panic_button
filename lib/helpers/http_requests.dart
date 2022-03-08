import 'package:panic_button_app/constants/api.dart';
import 'package:http/http.dart' as http;

class HttpService {
  String api = ApiConstants.apiUri;

  Future<http.Response> post({
    required String endpoint,
    required dynamic body,
    required Map<String, dynamic> params,
  }) async {
    Uri url = Uri.https(api, endpoint, params);
    return await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
  }

  Future<http.Response> get(
      {required String endpoint, required Map<String, String> params}) async {
    Uri url = Uri.https(api, endpoint, params);
    return await http.get(url);
  }
}
