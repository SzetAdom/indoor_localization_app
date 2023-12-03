import 'package:intl/intl.dart';

class BeaconLogModel {
  String uuid;
  int? major;
  int? minor;
  int? txPower;
  int? rssi;
  double? accuracy;
  String? testId;
  DateTime? time;

  BeaconLogModel({
    required this.uuid,
    this.major,
    this.minor,
    this.txPower,
    this.rssi,
    this.accuracy,
    this.testId,
    this.time,
  });

  @override
  String toString() {
    //if value is not null, return value, otherwise return empty string
    return "UUID: $uuid, Major: ${major ?? ""}, Minor: ${minor ?? ""}, TxPower: ${txPower ?? ""}, RSSI: ${rssi ?? ""}, Accuracy: ${accuracy ?? ""}, TestID: ${testId ?? ""}, Time: ${time?.toString() ?? ""}";
  }

  String toSimpleString() {
    return "UUID: ${uuid.split('-').last}, RSSI: ${rssi ?? ""}, Accuracy: ${accuracy ?? ""}, Time: ${time != null ? simpleDate : ""}";
  }

  String get simpleDate {
    return DateFormat('yyyy-MM-dd – kk:mm:ss').format(time!);
  }

  String get simpleUUID {
    return uuid.split('-').last;
  }

  BeaconLogModel.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        major = json['major'],
        minor = json['minor'],
        txPower = json['txPower'],
        rssi = json['rssi'],
        accuracy = double.parse(json['accuracy']),
        testId = json['testId'],
        time = DateTime.parse(json['time']);

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'major': major,
        'minor': minor,
        'txPower': txPower,
        'rssi': rssi,
        'accuracy': accuracy.toString(),
        'testId': testId,
        'time': time?.toString(),
      };
}
