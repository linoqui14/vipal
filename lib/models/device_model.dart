

class DeviceModel {
  String id, temperature, heartRate,oxigen;

  DeviceModel(
      {required this.id, required this.temperature, required this.heartRate,required this.oxigen});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "temperature": temperature,
      "heartRate": heartRate,
      "oxigen": oxigen,
    };
  }

  static DeviceModel toObject({required Object doc}) {
    Map<String, dynamic> map = doc as Map<String, dynamic>;
    return DeviceModel(
      id: map["id"],
      temperature: map["temperature"],
      heartRate: map["heartRate"],
      oxigen: map["oxigen"],
    );

  }
}