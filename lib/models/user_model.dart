

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  String fname,lname,email,mobileNumber,id;
  int pmin,pmax,omin,omax;
  double tmin = 0.0,tmax = 0.0;

  UserModel({ this.tmax = 37, this.tmin = 36.2, this.omax = 100, this.omin = 95, this.pmax = 100, this.pmin = 60, required this.fname,  required this.lname,  required this.email, required this.mobileNumber, this.id = ""});

  Map<String,dynamic> toMap(){
    return {
      "fname":fname,
      "lname":lname,
      "email":email,
      "mobileNumber":mobileNumber,
      "id":id,
      "tmin":tmin,
      "tmax":tmax,
      "pmin":pmin,
      "pmax":pmax,
      "omin":omin,
      "omax":omax,
    };
  }

  static UserModel toObject({required Object doc}){
    Map<String,dynamic> map = doc as Map<String,dynamic>;
    return UserModel(
        fname: map["fname"],
        lname: map["lname"],
        email: map["email"],
        mobileNumber: map["mobileNumber"],
        id: map["id"],
        tmax: map["tmax"],
        tmin: map["tmin"],
        pmin: map["pmin"],
        pmax: map["pmax"],
        omin: map["omin"],
        omax: map["omax"]
    );
  }


}