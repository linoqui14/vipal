
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vipal/models/record_model.dart';

import '../models/user_model.dart';

class UserController{
  static CollectionReference users = FirebaseFirestore.instance.collection('users');
  static Future<DocumentSnapshot> getUserDoc({required String id}){
    return users.doc(id).get();
  }
  static Stream<DocumentSnapshot> getUser({required String id}){
    return users.doc(id).snapshots();
  }

  static void upSert({required UserModel user}){
      users.doc(user.id).set(user.toMap());
    }
}

class DeviceController{
  static CollectionReference device = FirebaseFirestore.instance.collection('devices');

  static Future<QuerySnapshot<Object?>> getDeviceDocWhereID({required String id}){
    return device.where("id",isEqualTo:id ).get();
  }
  static Stream<DocumentSnapshot> getDevice({required String id}){
    return device.doc(id).snapshots();
  }
}
class RecordController{
  static CollectionReference record = FirebaseFirestore.instance.collection('record');

  static Stream<QuerySnapshot> getDeviceDocWhereID({required String id}){
    return record.where("userID",isEqualTo:id ).snapshots();
  }
  static Stream<DocumentSnapshot> getDevice({required String id}){
    return record.doc(id).snapshots();
  }
  static void upSert({required RecordModel recordModel}){
    record.doc(recordModel.id).set(recordModel.toMap());
  }
}