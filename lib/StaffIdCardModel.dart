import 'dart:convert';

class StaffIdCardModel {
  String? ATSD_EMPID;
  String? ATSD_NAME;
  String? ATSD_DESIGNATION;
  String? ATSD_BLOOD_CODE;
  String? EC_MOBILE_NO;
  String? ATSD_ADDRESS;
  String? ATS_FDATE;
  DateTime? ATS_TDATE;
  String? ATS_STATUS;
  String? ASP_PHOTO;
  String? DD_DEPT_DETAIL;
  String? EM_TYPE_FLAG;
  String? EM_EMPLOYEE_ID;
  String? EMEMPID;
  String? EMNAME;
  String? EMDESIGNAMTION;
  String? EMADDRESS;
  String? EMBLOODGROUP;
  String? EMOFFICENO;
  String? CURRENTLOCATION;
  DateTime? EM_DOR;
  String? EM_CAMP_CODE;
  String? EM_DIGITAL_IDCARD_STATUS;
  String? FC_CAMP_NAME;

  StaffIdCardModel(
      this.ATSD_EMPID,
      this.ATSD_NAME,
      this.ATSD_DESIGNATION,
      this.ATSD_BLOOD_CODE,
      this.EC_MOBILE_NO,
      this.ATSD_ADDRESS,
      this.ATS_FDATE,
      this.ATS_TDATE,
      this.ATS_STATUS,
      this.ASP_PHOTO,
      this.DD_DEPT_DETAIL,
      this.EM_TYPE_FLAG,
      this.EM_EMPLOYEE_ID,
      this.EMEMPID,
      this.EMNAME,
      this.EMDESIGNAMTION,
      this.EMADDRESS,
      this.EMBLOODGROUP,
      this.EMOFFICENO,
      this.CURRENTLOCATION,
      this.EM_DOR,
      this.EM_CAMP_CODE,
      this.EM_DIGITAL_IDCARD_STATUS,
      this.FC_CAMP_NAME);

  factory StaffIdCardModel.fromJson(Map<String, dynamic> json) {
    return StaffIdCardModel(
      json['ATSD_EMPID'],
      json['ATSD_NAME'],
      json['ATSD_DESIGNATION'],
      json['ATSD_BLOOD_CODE'],
      json['EC_MOBILE_NO'],
      json['ATSD_ADDRESS'],
      json['ATS_FDATE'],
      json['ATS_TDATE'] != null ? _parseCustomDate(json['ATS_TDATE']) : null,
      json['ATS_STATUS'],
      json['ASP_PHOTO'],
      json['DD_DEPT_DETAIL'],
      json['EM_TYPE_FLAG'],
      json['EM_EMPLOYEE_ID'],
      json['EMEMPID'],
      json['EMNAME'],
      json['EMDESIGNAMTION'],
      json['EMADDRESS'],
      json['EMBLOODGROUP'],
      json['EMOFFICENO'],
      json['CURRENTLOCATION'],
      json['EM_DOR'] != null ? _parseCustomDate(json['EM_DOR']) : null,
      json['EM_CAMP_CODE'],
      json['EM_DIGITAL_IDCARD_STATUS'],
      json['FC_CAMP_NAME'],
    );
  }

  static StaffIdCardModel decode(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    return StaffIdCardModel.fromJson(data);
  }

  static DateTime? _parseCustomDate(String? customDateString) {
    if (customDateString == null) return null;

    final List<String> months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];

    final parts = customDateString.split('-');
    if (parts.length != 3) {
      throw FormatException('Invalid date format: $customDateString');
    }

    final day = int.tryParse(parts[0]);
    final monthIndex = months.indexOf(parts[1].toUpperCase());
    final yearStr = parts[2];
    final year = yearStr.length == 2 ? int.parse(yearStr) + 2000 : int.parse(yearStr); // Adjust year based on its length

    if (day == null || monthIndex == -1) {
      throw FormatException('Invalid date format: $customDateString');
    }

    return DateTime(year, monthIndex + 1, day);
  }

}
