// To parse this JSON data, do
//
//     final panic = panicFromJson(jsonString);

import 'dart:convert';

Panic panicFromJson(String str) => Panic.fromJson(json.decode(str));

String panicToJson(Panic data) => json.encode(data.toJson());

class Panic {
  Panic({
    required this.title,
    required this.body,
    required this.myLocation,
    this.zipCode,
    this.userUid,
    required this.name,
    required this.phone,
    required this.alias,
    required this.countryCode,
  });

  String title;
  String body;
  Map<String, dynamic> myLocation;
  int? zipCode;
  String? userUid;
  String name;
  String phone;
  String alias;
  String countryCode;

  factory Panic.fromJson(Map<String, dynamic> json) => Panic(
        title: json["title"],
        body: json["body"],
        myLocation: {
          "lat": json["myLocation"]["lat"],
          "lng": json["myLocation"]["lng"]
        },
        zipCode: json["zip_code"],
        userUid: json["user_uid"],
        name: json["name"],
        phone: json["phone"],
        alias: json["alias"],
        countryCode: json["countryCode"]
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "body": body,
        "my_location": {"lat": myLocation["lat"], "lng": myLocation["lng"]},
        "zip_code": zipCode,
        "user_uid": userUid,
        "name": name,
        "phone": phone,
        "alias": alias,
        "countryCode": countryCode
      };
}
