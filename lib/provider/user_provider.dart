import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/models/basic_response.dart';
import 'package:nyoba/models/countries_model.dart';
import 'package:nyoba/models/customer_data_model.dart';
import 'package:nyoba/models/point_model.dart';
import 'package:nyoba/models/user_model.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/services/user_api.dart';
import 'package:nyoba/utils/utility.dart';

class UserProvider with ChangeNotifier {
  UserModel _user = new UserModel();

  UserModel get user => _user;

  bool loading = false;
  bool loadDelete = false;

  PointModel? point;

  CustomerData? customerData;
  List<CountriesModel>? countries;

  CountriesModel? selectedCountries;
  States? selectedStates;
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchUserDetail() async {
    loading = true;
    var result;
    await UserAPI().fetchDetail().then((data) {
      result = data;
      printLog(result.toString());

      UserModel userModel = UserModel.fromJson(result['user']);
      if (result['poin'] != null) {
        point = PointModel.fromJson(result['poin']);
      }
      Session().saveUser(userModel, Session.data.getString('cookie')!);

      this.setUser(userModel);

      print(point.toString());
      loading = false;
      notifyListeners();
    });
    loading = false;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>?> updateUser(
      {String? firstName,
      String? lastName,
      String? username,
      String? email,
      required String password,
      String? oldPassword}) async {
    loading = true;
    var result;
    await UserAPI()
        .updateUserInfo(
            firstName: firstName,
            lastName: lastName,
            password: password,
            oldPassword: oldPassword,
            email: email)
        .then((data) {
      result = data;
      printLog(result.toString());

      if (result['is_success'] == true) {
        Session.data.setString('cookie', result['cookie']);
      }

      loading = false;
      notifyListeners();
    });
    return result;
  }

  Future<BasicResponse?> deleteAccount() async {
    BasicResponse? _result;
    try {
      loadDelete = true;
      Map data = {
        "cookie": Session.data.getString('cookie'),
      };
      print(data);
      var response = await baseAPI.postAsync(
        'delete-account',
        data,
        isCustom: true,
      );
      if (response != null) {
        printLog(response.toString(), name: 'Response Delete Account');
        loadDelete = false;
        if (response['status'] == "success") {
          _result = BasicResponse(200, response['message']);
        } else {
          _result = BasicResponse(500, response['message']);
        }
        notifyListeners();
      }
      return _result;
    } catch (e) {
      printLog(e.toString(), name: "Error");
      _result = BasicResponse(500, e.toString());
      notifyListeners();
      return _result;
    }
  }

  Future<BasicResponse?> fetchAddress() async {
    BasicResponse? _result;
    loading = true;
    try {
      var response = await baseAPI.getAsync(
        'customers/${Session.data.getInt('id')}',
      );
      final result = json.decode(response.body);

      if (response.statusCode == 200) {
        loading = false;
        printLog("Status Code OK");
        if (result['id'] != null) {
          printLog("ID Exists ${result['id']}");
          customerData = new CustomerData.fromJson(result);
          _result = BasicResponse(200, "Success");
        } else {
          _result = BasicResponse(500, "Failed");
        }
        notifyListeners();
        return _result;
      } else {
        loading = false;
        _result = BasicResponse(500, result['message']);
        notifyListeners();
        return _result;
      }
    } catch (e) {
      loading = false;
      printLog(e.toString(), name: "Error");
      _result = BasicResponse(500, e.toString());
      notifyListeners();
      return _result;
    }
  }

  Future<BasicResponse?> saveAddress(
    context, {
    String? action = 'billing',
    String? billingname = '',
    String? billingsurname = '',
    String? billingcompany = '',
    String? billingaddress = '',
    String? billingaddressopt = '',
    String? billingcity = '',
    String? billingcountry = '',
    String? billingemail = '',
    String? billingpostal = '',
    String? billingphone = '',
    String? billingstate = '',
  }) async {
    BasicResponse? _result;
    try {
      if (action == 'billing') {
        if (billingname!.isEmpty ||
            billingsurname!.isEmpty ||
            billingaddress!.isEmpty ||
            billingpostal!.isEmpty ||
            billingemail!.isEmpty ||
            billingphone!.isEmpty ||
            billingcountry!.isEmpty ||
            billingstate!.isEmpty ||
            billingcity!.isEmpty) {
          return snackBar(context,
              message: 'Required form field should not be empty');
        }
      }

      loading = true;
      Map data = {
        "cookie": Session.data.getString('cookie'),
        "action": action,
        "first_name": billingname,
        "last_name": billingsurname,
        "company": billingcompany,
        "address_1": billingaddress,
        "address_2": billingaddressopt,
        "city": billingcity,
        "postcode": billingpostal,
        "country": billingcountry,
        "state": billingstate,
        "phone": billingphone,
        "email": billingemail
      };
      print(data);
      var response = await baseAPI.postAsync(
        'customer/address',
        data,
        isCustom: true,
      );
      if (response != null) {
        printLog(response.toString(), name: 'Response Save Account Address');
        loading = false;
        if (response['status'] == "success") {
          _result = BasicResponse(200, response['message']);
          snackBar(context,
              message: 'Address changed successfully.', color: Colors.green);
          Navigator.pop(context, 200);
        } else {
          _result = BasicResponse(500, response['message']);
          snackBar(context,
              message: 'Address changed failed, ${response['message']}',
              color: Colors.red);
        }
        notifyListeners();
      }
      return _result;
    } catch (e) {
      printLog(e.toString(), name: "Error");
      _result = BasicResponse(500, e.toString());
      loading = false;
      notifyListeners();
      return _result;
    }
  }

  Future<bool> fetchCountries() async {
    loading = true;
    bool _isSuccess = false;
    try {
      var response = await baseAPI.getAsync('data/countries', printedLog: true);

      countries = [];
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);

        for (Map item in responseJson) {
          countries!.add(CountriesModel.fromJson(item));
        }

        selectedCountries = countries!.first;
        selectedStates = countries!.first.states!.first;

        loading = false;
        _isSuccess = true;
        notifyListeners();
      } else {
        loading = false;
        _isSuccess = false;
        notifyListeners();
      }
    } catch (e) {
      loading = false;
      _isSuccess = false;
      notifyListeners();
    }
    return _isSuccess;
  }

  setCountries(value) {
    if (value != null) {
      print(value);
      countries!.forEach((element) {
        if (element.code == value) {
          print("Found");
          selectedCountries = element;
          if (selectedCountries!.states!.isNotEmpty) {
            selectedStates = selectedCountries!.states!.first;
          } else {
            selectedStates = null;
          }
        }
      });
    }
    notifyListeners();
  }

  setStates(value) {
    if (selectedCountries!.states!.isNotEmpty) {
      List<States> _states = selectedCountries!.states!;
      selectedStates = value == null ? null : _states.first;
      if (value != null) {
        print(value);
        _states.forEach((element) {
          if (element.code == value) {
            print("Found");
            selectedStates = element;
          }
        });
      }
    }
    notifyListeners();
  }

  String convertState(country, state) {
    String _name = state ?? "";
    if (country != null && country != '') {
      if (countries!.isNotEmpty) {
        countries!.forEach((element) {
          if (element.code == country) {
            if (state != null && state != '' && element.states!.isNotEmpty) {
              element.states!.forEach((st) {
                if (st.code == state) {
                  _name = st.name!;
                }
              });
            }
          }
        });
      }
    }
    return _name;
  }

  String convertCountry(country) {
    String _name = country ?? "";
    if (country != null && country != '') {
      if (countries!.isNotEmpty) {
        countries!.forEach((element) {
          if (element.code == country) {
            _name = element.name!;
          }
        });
      }
    }
    return _name;
  }
}
