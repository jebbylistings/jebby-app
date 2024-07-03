import 'package:flutter/cupertino.dart';
import 'package:jared/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel with ChangeNotifier {
  String? _role;
  String? get role => _role;

  String? _id;
  String? get id => _id;

  String? _token;
  String? get token => _token;

  String? _name;
  String? get name => _name;

  String? _email;
  String? get email => _email;

  String? _image;
  String? get image => _image;
  String? _number;
  String? get number => _number;
  String? _address;
  String? get address => _address;

  String? _latitude;
  String? get latitude => _latitude;
  String? _longitude;
  String? get longitude => _longitude;

  Future<bool> saveUser(UserModel user) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('token', user.token.toString());
    sp.setString('id', user.id.toString());
    sp.setString('fullname', user.name.toString());
    sp.setString('email', user.email.toString());
    sp.setString('role', user.role.toString());
    sp.setString('isGuest', user.isGuest.toString());

    notifyListeners();
    return true;
  }

  Future<bool> updateUser(UpdatedModel user) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    var updatedUser ;//= user.data![0];
    if( user.data!.length!=0){
       updatedUser = user.data![0];
    
    sp.setString('fullname', updatedUser.name.toString());
    sp.setString('email', updatedUser.email.toString());
    sp.setString('image', updatedUser.image.toString());
    sp.setString('address', updatedUser.address.toString());
    sp.setString('latitude', updatedUser.latitude.toString());
    sp.setString('longitude', updatedUser.longitude.toString());
    sp.setString('number', updatedUser.number.toString());
    }
    notifyListeners();
    return true;
  }

  Future<UpdatedModel> getUpdatedUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    _token = sp.getString('token');
    _id = sp.getString('id');
    _name = sp.getString('fullname');
    _email = sp.getString('email');
    _role = sp.getString('role');
    _address = sp.getString('address');
    _latitude = sp.getString('latitude');
    _longitude = sp.getString('longitude');
    _number = sp.getString('number');
    _image = sp.getString('image');

    notifyListeners();
   

    return UpdatedModel(
      data: [
 Data(
        image: image.toString(),
        name: name.toString(),
        email: email.toString(),
        number: number.toString(),
        address: address.toString(),
        userId: id.toString(),
        latitude: latitude.toString(),
        longitude: longitude.toString())
      ]
    );

   //return UpdatedModel(data: data?);
  }

  Future<UserModel> getUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    _token = sp.getString('token');
    _id = sp.getString('id');
    _name = sp.getString('fullname');
    _email = sp.getString('email');
    _role = sp.getString('role');
    String? isGuestUserString  = sp.getString('isGuest') ;
    bool isGuest  = (isGuestUserString != null && isGuestUserString == 'true')? true : false;

    notifyListeners();
    return UserModel(token: token.toString(), id: id.toString(), name: name, email: email, role: role.toString(), isGuest : isGuest );
  }

  Future<bool> remove() async {
    print("removed /////");
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove('token');
    sp.remove('id');
    sp.remove('fullname');
    sp.remove('email');
    sp.remove('role');
    sp.remove('address');
    sp.remove('latitude');
    sp.remove('longitude');
    sp.remove('number');
    sp.remove('image');

    return true;
  }
}
