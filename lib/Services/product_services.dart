import 'package:http/http.dart' as http;
import 'package:jebby/res/app_url.dart';

import '../model/products_model.dart';

class ProductServices {
  Future<ProductModel?> getProducts(String id) async {
    try {
      var headers = {
        'Cookie':
            'connect.sid=s%3AL3kkfMiV7cN7nQTh2n2W8CuJPgZeiBQ-.QcSCrHQoCGmSPWjtiqW%2F5Eo5n00ptKUSG4Avrb7qI%2Fc',
      };

      var request = http.Request(
        'GET',
        Uri.parse(AppUrl.baseUrlM + '/getProductsBySubCatId/$id'),
      );
      request.headers.addAll(headers);

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 400) {
        throw ('Error');
      } else {
        return productModelFromJson(response.body);
      }
    } catch (e) {
      throw Exception("$e");
    }
  }
}
