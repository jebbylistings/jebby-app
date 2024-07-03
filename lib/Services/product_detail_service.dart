
import 'package:http/http.dart' as http;
import 'package:jared/model/pro_detail_model.dart';

class ProDetailService {
  Future<ProductDetailmodel?> getproDetails(id) async {
    try {
      var headers = {'Cookie': 'connect.sid=s%3Adaex69rrn23Fcj_kh2KoQ1yvKoO7jFgv.jf7K6aCym2FPb8ygUhnJboXaug%2FVrb68cTzxh4Z7TXY'};
      var request = http.Request('GET', Uri.parse('https://api.jebbylistings.com/getProductById/$id'));

      request.headers.addAll(headers);

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 400) {
        print(response.statusCode);
        throw ('Error');
      } else {
        print(response.reasonPhrase);
        return productDetailmodelFromJson(response.body);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
