import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetJebbyfee {
  static Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse("https://api.jebbylistings.com/GetValues"));
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
     final SharedPreferences s = await SharedPreferences.getInstance();
     var id;
     id = "https://api.jebbylistings.com/getAllExpiryOrdersByUserId/${s.getString('id')}";
    final response = await http.get(Uri.parse("https://api.jebbylistings.com/getAllExpiryOrdersByUserId/${s.getString('id')}"));
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
     final SharedPreferences s = await SharedPreferences.getInstance();
     var id;
    final response = await http.get(Uri.parse("https://api.jebbylistings.com/getAllExpiryOrdersByVendorId/${s.getString('id')}"));
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