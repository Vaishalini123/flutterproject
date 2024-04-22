import 'dart:convert';

class LoginModel {
  bool status;
  String remarks;

  LoginModel({required this.status, required this.remarks});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['status'],
      remarks: json['remarks'],
    );
  }
  static LoginModel decode(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    return LoginModel.fromJson(data);
  }
}
