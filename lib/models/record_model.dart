
class RecordModel{
  String id,deviceID,userID;
  double sensor;
  int time,senorType;

  RecordModel({required this.userID,required this.deviceID,required this.id, required this.senorType, required this.sensor,required this.time});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "sensor": sensor,
      "time": time,
      "deviceID": deviceID,
      "senorType": senorType,
      "userID": userID,
    };
  }

  static RecordModel toObject({required Object doc}) {
    Map<String, dynamic> map = doc as Map<String, dynamic>;
    return RecordModel(
      id: map["id"],
      senorType: map["senorType"],
      sensor: map["sensor"],
      time: map["time"],
      deviceID: map["deviceID"],
      userID: map["userID"]
    );

  }
}