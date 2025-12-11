import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jebby/model/pro_detail_model.dart';

class ProDetailService {
  Future<ProductDetailmodel?> getproDetails(id) async {
    String Url = dotenv.env['baseUrlM'] ?? 'No url found';
    try {
      var headers = {
        'Cookie':
            'connect.sid=s%3Adaex69rrn23Fcj_kh2KoQ1yvKoO7jFgv.jf7K6aCym2FPb8ygUhnJboXaug%2FVrb68cTzxh4Z7TXY',
      };
      var request = http.Request('GET', Uri.parse('${Url}/getProductById/$id'));

      request.headers.addAll(headers);

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 400) {
        throw ('Error');
      } else {
        return productDetailmodelFromJson(response.body);
      }
    } catch (e) {}
    return null;
  }
}
