// To parse this JSON data, do
//
//     final device = deviceFromJson(jsonString);

import 'dart:convert';

Device deviceFromJson(String str) => Device.fromJson(json.decode(str));

String deviceToJson(Device data) => json.encode(data.toJson());

class Device {
  Device({
    required this.created,
    required this.device,
    required this.os,
  });

  String created;
  String device;
  String os;

  Device copyWith({
    required String created,
    required String device,
    required String os,
  }) =>
      Device(created: created, device: device, os: os);

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        created: json["created"],
        device: json["device"],
        os: json["os"],
      );

  Map<String, dynamic> toJson() => {
        "created": created,
        "device": device,
        "os": os,
      };
}
