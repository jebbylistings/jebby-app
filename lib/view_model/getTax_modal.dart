import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetJebbyfee {
  static Future<Map<String, dynamic>> fetchData() async {
    String Url = dotenv.env['baseUrlM'] ?? 'No url found';
    final response = await http.get(Uri.parse("${Url}/GetValues"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print('data ${response.body}');
      return data;
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}

class GetreturnProduct{
  static Future<Map<String, dynamic>> fetchData() async {
    String Url = dotenv.env['baseUrlM'] ?? 'No url found';
     final SharedPreferences s = await SharedPreferences.getInstance();
     var id;
     id = "${Url}/getAllExpiryOrdersByUserId/${s.getString('id')}";
    final response = await http.get(Uri.parse("${Url}/getAllExpiryOrdersByUserId/${s.getString('id')}"));
    print("id =====> $id");
    print(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print('data ${response.body}');
      return data;
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}

class GetreturnProduct2{
  static Future<Map<String, dynamic>> fetchData() async {
    String Url = dotenv.env['baseUrlM'] ?? 'No url found';
     final SharedPreferences s = await SharedPreferences.getInstance();
     var id;
    final response = await http.get(Uri.parse("${Url}/getAllExpiryOrdersByVendorId/${s.getString('id')}"));
    print("id ${s.getString('id')}");
    print(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print('data ${response.body}');
      return data;
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}