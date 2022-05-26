
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vipal/custom_widgets/custom_texfield.dart';
import 'package:vipal/custom_widgets/custom_textbutton.dart';
import 'package:vipal/database_services/controller.dart';
import 'package:vipal/models/record_model.dart';
import 'package:vipal/pages/dashboard.dart';
import 'package:vipal/tools/my_colors.dart';
import '../custom_widgets/sensor_record.dart';
import '../custom_widgets/sensor_widget.dart';
import '../models/device_model.dart';
import '../models/user_model.dart';
import 'login.dart';

class Home extends StatefulWidget{
  const Home({Key? key, required this.userModel}) : super(key: key);
  final UserModel userModel;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;
  TextEditingController lname = TextEditingController();
  TextEditingController fname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController deviceId = TextEditingController();



  @override
  void initState() {
    FlutterBluetoothSerial.instance.requestDiscoverable(5);
    lname.text = widget.userModel.lname;
    fname.text = widget.userModel.fname;
    email.text = widget.userModel.email;
    mobile.text = widget.userModel.mobileNumber;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.2,
        centerTitle: true,
        backgroundColor: Colors.black87,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Devices",style:TextStyle(fontSize: 60,fontWeight: FontWeight.w100),),
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: (){
                      FirebaseAuth.instance.signOut().then((value) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                              (Route<dynamic> route) => false,
                        );
                      });
                    },
                    icon: Icon(Icons.logout,color: Colors.white,),
                  ),
                  Text("Logout",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.white,),)
                ],
              ),
            )
          ],
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: TabBarView(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.black87,
                child: SingleChildScrollView(
                  child: Center(
                    child: FutureBuilder<BluetoothState>(
                        future: FlutterBluetoothSerial.instance.state,
                        initialData: BluetoothState.UNKNOWN,
                        builder: (c, snapshot) {
                          final state = snapshot.data;
                          List<BluetoothDevice> devices = [];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.bluetooth,color: Colors.white,),
                                        Text("Vipal Local",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.white,),)
                                      ],
                                    ),
                                    IconButton(onPressed: (){setState(() {});}, icon: Icon(Icons.refresh,color:Colors.white))

                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 305,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(30),
                                    border: Border.all(
                                        color: Colors.white
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                                child: Column(
                                  children: [
                                    if(state==BluetoothState.STATE_ON)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            StreamBuilder<BluetoothDiscoveryResult>(
                                              stream: FlutterBluetoothSerial.instance.startDiscovery(),
                                              builder: (context,snapshot){
                                                if(!snapshot.hasData)return Center(child: CircularProgressIndicator(color: Colors.white,strokeWidth: 1,),);
                                                if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(color: Colors.white,strokeWidth: 1,),);
                                                try{
                                                  if(!devices.contains(snapshot.data!.device)){

                                                    if(snapshot.data!.device.name!.contains("VIPAL")){
                                                      devices.add(snapshot.data!.device);
                                                    }
                                                  }

                                                  return SizedBox(
                                                    width: double.infinity,
                                                    height: 300,
                                                    child: ListView(
                                                      children: devices.map((e){
                                                        return CustomTextButton(
                                                          width: 300,
                                                          text: e.name!,
                                                          color: MyColors.red,
                                                          onPressed: (){
                                                            Fluttertoast.showToast(
                                                                msg: "Connecting...",
                                                                toastLength: Toast.LENGTH_LONG,
                                                                gravity: ToastGravity.CENTER,
                                                                timeInSecForIosWeb: 1,
                                                                backgroundColor: Colors.red,
                                                                textColor: Colors.white,
                                                                fontSize: 16.0
                                                            );
                                                            BluetoothConnection.toAddress(e.address).then((connection) {
                                                              if(connection.isConnected){
                                                                try{

                                                                  DashBoard dashboard = DashBoard(user: widget.userModel,deviceID: e.name!.split("#")[1],connection: connection,);
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(builder: (context) => dashboard),
                                                                  );
                                                                }
                                                                catch(e){
                                                                  print(e);
                                                                }

                                                              }
                                                            }).catchError((onError){
                                                              Fluttertoast.showToast(
                                                                  msg: "Unable to connect, please try again.",
                                                                  toastLength: Toast.LENGTH_LONG,
                                                                  gravity: ToastGravity.CENTER,
                                                                  timeInSecForIosWeb: 1,
                                                                  backgroundColor: Colors.red,
                                                                  textColor: Colors.white,
                                                                  fontSize: 16.0
                                                              );
                                                            });



                                                            // connection.input?.listen((Uint8List data) {
                                                            //
                                                            //   if(!ascii.decode(data).contains(";")){
                                                            //     temp+=ascii.decode(data);
                                                            //   }
                                                            //   else{
                                                            //     datas = temp.split(",");
                                                            //     DeviceModel deviceModel = DeviceModel(id: e.name!.split("#")[1], temperature: datas[2], heartRate: datas[0],oxigen:datas[1] );
                                                            //     print(deviceModel.heartRate);
                                                            //     temp = "";
                                                            //   }
                                                            //
                                                            //   // connection.output.add(data); // Sending data
                                                            // }).onDone(() {
                                                            //   print('Disconnected by remote request');
                                                            // });
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                                  );
                                                }catch(e){
                                                  return Center(child: CircularProgressIndicator(),);
                                                }

                                              },

                                            ),

                                          ],
                                        ),
                                      ),
                                    if(state==BluetoothState.STATE_OFF)
                                      Text("BLUETOOTH\nIS OFF",style: TextStyle(fontSize: 50,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center,),
                                    if(state==BluetoothState.STATE_OFF)
                                      Text("Please turn bluetooth on",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w100,color: Colors.white)),
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                              // Container(
                              //   alignment: Alignment.topLeft,
                              //   padding: EdgeInsets.symmetric(horizontal: 20),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Row(
                              //         children: [
                              //           Icon(Icons.cloud,color: Colors.white,),
                              //           Text(" Vipal Cloud",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.white,),)
                              //         ],
                              //       ),
                              //       Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                              //       CustomTextField(
                              //           suffix: CustomTextButton(
                              //               rTl: 0,
                              //               rBL: 0,
                              //               color: Colors.white.withAlpha(50),
                              //               width: 50,
                              //               text: "Go",
                              //               onPressed: () {
                              //                 DeviceController.getDeviceDocWhereID(id: deviceId.text).then((value) {
                              //                   print(value.docs.first);
                              //                   try{
                              //                     DeviceModel deviceModel = DeviceModel.toObject( doc: value.docs.first.data()!,);
                              //
                              //                     Fluttertoast.showToast(
                              //                         msg: "Device found!",
                              //                         toastLength: Toast.LENGTH_LONG,
                              //                         gravity: ToastGravity.CENTER,
                              //                         timeInSecForIosWeb: 1,
                              //                         backgroundColor: Colors.red,
                              //                         textColor: Colors.white,
                              //                         fontSize: 16.0
                              //                     );
                              //                     Navigator.push(
                              //                       context,
                              //                       MaterialPageRoute(builder: (context) => DashBoard(user: widget.userModel,deviceID:value.docs.first.id )),
                              //                     );
                              //
                              //                   }catch(e){
                              //                     Fluttertoast.showToast(
                              //                         msg: "Device not found",
                              //                         toastLength: Toast.LENGTH_LONG,
                              //                         gravity: ToastGravity.CENTER,
                              //                         timeInSecForIosWeb: 1,
                              //                         backgroundColor: Colors.red,
                              //                         textColor: Colors.white,
                              //                         fontSize: 16.0
                              //                     );
                              //                   }
                              //
                              //                 });
                              //               }
                              //           ),
                              //           color:MyColors.red ,
                              //           hint: "Device ID",
                              //           padding: EdgeInsets.zero,
                              //           controller: deviceId
                              //       ),
                              //
                              //     ],
                              //   ),
                              // ),
                            ],
                          );
                        }),

                  ),
                ),
              ),
              DefaultTabController(
                length: 3,
                child: Scaffold(

                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    backgroundColor: Colors.black87,
                    title:  Container(
                      color: Colors.transparent,
                      child:  TabBar(
                        tabs: [
                          Tab(icon: Icon(Icons.favorite)),
                          Tab(icon: Icon(Icons.thermostat)),
                          Tab(icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("O",style: TextStyle(fontSize: 20,)),
                              Text("2",style: TextStyle(fontSize: 10,fontWeight: FontWeight.w100),),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                  body: Container(
                    color: Colors.black87,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: RecordController.getDeviceDocWhereID(id: widget.userModel.id),
                        builder: (context, snapshot) {
                          if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                          if((snapshot.data!.size<0))return Center(child: CircularProgressIndicator(),);
                          List<RecordModel> recordModelsPulse = [];
                          List<RecordModel> recordModelsOxygen = [];
                          List<RecordModel> recordModelsTemp = [];
                          snapshot.data!.docs.forEach((element) {
                            RecordModel recordModel = RecordModel.toObject(doc: element.data()!);

                            // switch(recordModel.senorType){
                            //   case SensorType.bpm:
                            //     recordModelsPulse.add(recordModel);
                            //     break;
                            //   case SensorType.oxygen:
                            //     recordModelsOxygen.add(recordModel);
                            //     break;
                            //   case SensorType.temp:
                            //     recordModelsTemp.add(recordModel);
                            //     break;
                            // }


                          });
                          return TabBarView(
                            children: [
                              Container(
                                child: SensorRecord(records: recordModelsPulse,measurement: "bpm",),
                              ),
                              Container(
                                child: SensorRecord(records: recordModelsTemp,measurement: "C°",),
                              ),
                              Container(
                                child: SensorRecord(records: recordModelsOxygen,measurement: "%",),
                              ),

                            ],
                          );
                        }
                    ),
                  ),
                ),
              ),
              Container(
                width:MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black87,
                padding: EdgeInsets.only(right: 10,left: 10,top: 10,bottom: 10),
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: MyColors.deadBlue),),
                            Row(
                                children: [
                                  Flexible(
                                    child: CustomTextField(
                                      controller: fname,
                                      color: MyColors.deadBlue,
                                      rTopLeft:0 ,
                                      hint: "First Name",
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                                  Flexible(
                                    child: CustomTextField(
                                      controller: lname,
                                      color: MyColors.deadBlue,
                                      hint: "Last Name",
                                      padding: EdgeInsets.symmetric(horizontal: 0),
                                    ),
                                  ),

                                ]
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                            Text("Contact Information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color:MyColors.deadBlue),),
                            Row(
                                children: [
                                  Flexible(
                                    child: CustomTextField(
                                      readonly: true,
                                      controller: email,
                                      color: MyColors.deadBlue,
                                      rTopLeft:0 ,
                                      hint: "Email address",
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                                  Flexible(
                                    child: CustomTextField(
                                      controller: mobile,
                                      color: MyColors.deadBlue,
                                      hint: "Mobile Number",
                                      padding: EdgeInsets.symmetric(horizontal: 0),
                                    ),
                                  ),

                                ]
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                            TextButton(
                                onPressed: ()async {
                                  if(
                                  lname.text.isNotEmpty&&
                                      fname.text.isNotEmpty&&
                                      email.text.isNotEmpty&&
                                      mobile.text.isNotEmpty
                                  ){
                                    UserModel userModel = UserModel(id: widget.userModel.id,fname: fname.text, lname: lname.text, email: email.text, mobileNumber: mobile.text);
                                    UserController.upSert(user: userModel);
                                  }
                                  else{
                                    Fluttertoast.showToast(
                                        msg: "Please fill up all fields",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                    );
                                  }
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    width: 100,
                                    child: const Text("Update",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                                ),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(MyColors.deadBlue),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),

                                        )
                                    )
                                )
                            ),


                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.black87,
            child:  TabBar(
              tabs: [
                Tab(icon: Icon(Icons.health_and_safety)),
                Tab(icon: Icon(Icons.query_stats)),
                Tab(icon: Icon(Icons.tune)),
              ],
            ),
          ),
        ),
      ),

    );
  }

}