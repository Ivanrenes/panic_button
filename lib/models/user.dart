// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.user_uid,
    required this.phone,
    required this.address,
    required this.alias,
    required this.avatar,
    required this.city,
    required this.countryCode,
    required this.departament,
    required this.devices,
    required this.email,
    required this.name,
    required this.lastname,
    required this.location,
    this.zipCode, 
    required this.administrator,
  });

  String? user_uid;
  String phone;
  String address;
  String alias;
  String avatar;
  String city;
  String countryCode;
  String departament;
  List<dynamic> devices;
  String email;
  String name;
  String lastname;
  Map<String, dynamic> location;
  int? zipCode;
  bool administrator;

  User copyWith({
    String? user_uid,
    required String phone,
    required String address,
    required String alias,
    required String avatar,
    required String city,
    required String countryCode,
    required String departament,
    required List<dynamic> devices,
    required String email,
    required String name,
    required String lastname,
    required Map<String, dynamic> location,
    int? zipCode,
    required bool administrator
  }) =>
      User(
        user_uid: user_uid ?? this.user_uid,
        phone: phone,
        address: address,
        alias: alias,
        avatar: avatar,
        city: city,
        countryCode: countryCode,
        departament: departament,
        devices: devices,
        email: email,
        name: name,
        lastname: lastname,
        location: location,
        zipCode: zipCode ?? this.zipCode,
        administrator: administrator
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        user_uid: json["user_uid"],
        phone: json["phone"],
        address: json["address"],
        alias: json["alias"],
        avatar: json["avatar"],
        city: json["city"],
        countryCode: json["country_code"],
        departament: json["departament"],
        devices: List<dynamic>.from(json["devices"].map((x) => x)),
        email: json["email"],
        name: json["name"],
        lastname: json["lastname"],
        location: {
          "lng": json["location"]["lng"],
          "lat": json["location"]["lat"]
        },
        zipCode: json["zipcode"],
        administrator: json['administrator']
      );

  Map<String, dynamic> toJson() => {
        "user_uid": user_uid,
        "phone": phone,
        "address": address,
        "alias": alias,
        "avatar": avatar,
        "city": city,
        "country_code": countryCode,
        "departament": departament,
        "devices": List<dynamic>.from(devices.map((x) => x)),
        "email": email,
        "name": name,
        "lastname": lastname,
        "location": {"lat": location["lat"], "lng": location["lng"]},
        "zipcode": zipCode,
        "administrator": administrator
      };
}
