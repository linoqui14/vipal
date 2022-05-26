
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:breathing_collection/breathing_collection.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:vipal/custom_widgets/custom_textbutton.dart';
import 'package:vipal/database_services/controller.dart';
import 'package:vipal/models/device_model.dart';
import 'package:vipal/models/user_model.dart';
import 'package:vipal/tools/my_colors.dart';
import 'package:telephony/telephony.dart';
import 'package:intl/intl.dart';
import '../custom_widgets/custom_texfield.dart';
import '../custom_widgets/sensor_widget.dart';
import '../models/record_model.dart';

class DashBoard extends StatefulWidget{
  DashBoard({Key? key,required  this.deviceID,this.connection,required this.user}) : super(key: key,);
  final String deviceID;
  BluetoothConnection? connection;
  final UserModel user;
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard>{
  TextEditingController lname = TextEditingController();
  TextEditingController fname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobile = TextEditingController();
  Telephony telephony = Telephony.instance;
  late Timer _timer;
  late DeviceModel _deviceModel;
  int _start = 10;
  bool disconnected = false;
  bool isTest = false;
  bool isRecording = false;
  bool isWarnedT = false;
  bool isWarnedO = false;
  bool isWarnedP = false;
  String bt = "";
  GlobalKey<SensorWidgetState> senWidgetTemp = GlobalKey();
  GlobalKey<SensorWidgetState> senWidgetO = GlobalKey();
  GlobalKey<SensorWidgetState> senWidgetP = GlobalKey();

  double rTempTotal = 0;
  double rOTotal = 0;
  double rPTotal = 0;

  double tempAvrg =0;
  double rOAvrg = 0;
  double rPAvrg =0;

  int recordCount = 0;
  int recordCountReset = 0;
  int recordCountNoReset = 0;

  int random(min, max) {
    return min + Random().nextInt(max - min);
  }
  DeviceModel deviceModel = DeviceModel(id: "0", temperature: "0", heartRate: "0",oxigen: "0");
  List<Map<String,dynamic>> records = [];
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        _timer = timer;
        if(_start<=0){
          setState(() {

          });
        }
        if(isRecording&&!disconnected){
          // print(tempAvrg>senWidgetTemp.currentState!.valueWarningLevel);

          if(senWidgetTemp.currentState!=null&&senWidgetO.currentState!=null&&senWidgetP.currentState!=null){
            if(recordCountReset>=60){
              setState(() {
                tempAvrg = rTempTotal/recordCount;
                rOAvrg = rOTotal/recordCount;
                rPAvrg = rPTotal/recordCount;
                var uuid = Uuid();
                if(tempAvrg>senWidgetTemp.currentState!.valueWarningLevel||tempAvrg<senWidgetTemp.currentState!.valueWarningLevelMin){
                  senWidgetTemp.currentState!.audioPlayer.play();
                  telephony.sendSms(to: widget.user.mobileNumber, message: "WARNING: Temperature reached!\nPlease check patient!\nTemperature: "+tempAvrg.toString()+"\nDate: "+DateFormat.yMMMd().add_jms().format(DateTime.now()));
                  isWarnedT = true;
                }
                if(rOAvrg>senWidgetO.currentState!.valueWarningLevel||rOAvrg<senWidgetO.currentState!.valueWarningLevelMin){
                  senWidgetO.currentState!.audioPlayer.play();
                  telephony.sendSms(to: widget.user.mobileNumber, message: "WARNING: Oxygen Level reached!\nPlease check patient!\nOxygen: "+rOAvrg.toInt().toString()+"\nDate: "+DateFormat.yMMMd().add_jms().format(DateTime.now()));
                  isWarnedO = true;
                }
                if(rPAvrg>senWidgetP.currentState!.valueWarningLevel||rPAvrg<senWidgetP.currentState!.valueWarningLevelMin){
                  senWidgetP.currentState!.audioPlayer.play();
                  telephony.sendSms(to: widget.user.mobileNumber, message: "WARNING: Pulse Rate reached!\nPlease check patient!\nPulse: "+rPAvrg.toInt().toString()+"\nDate: "+DateFormat.yMMMd().add_jms().format(DateTime.now()));
                  isWarnedP = true;
                }
                RecordController.upSert(recordModel: RecordModel(userID:widget.user.id,deviceID:deviceModel.id, id: uuid.v1(), senorType:SensorType.temp, sensor: tempAvrg, time: DateTime.now().millisecondsSinceEpoch));
                RecordController.upSert(recordModel: RecordModel(userID:widget.user.id,deviceID:deviceModel.id, id: uuid.v1(), senorType:SensorType.oxygen, sensor: rOAvrg.toDouble(), time: DateTime.now().millisecondsSinceEpoch));
                RecordController.upSert(recordModel: RecordModel(userID:widget.user.id,deviceID:deviceModel.id, id: uuid.v1(), senorType:SensorType.bpm, sensor: rPAvrg.toDouble(), time: DateTime.now().millisecondsSinceEpoch));
                records.add(
                    {
                      't':tempAvrg,
                      'p':rPAvrg,
                      'o':rOAvrg,
                      'time':DateTime.now()
                    }
                );
                recordCountReset = 0;
              });

            }
            setState(() {
              rTempTotal+=senWidgetTemp.currentState!.sensorValue;
              rOTotal+=senWidgetO.currentState!.sensorValue;
              rPTotal+=senWidgetP.currentState!.sensorValue;
              recordCount++;
              recordCountNoReset++;
              recordCountReset++;
            });

          }
        }
        else{
          recordCount = 0;
          rTempTotal = 0;
          rOTotal = 0;
          rPTotal = 0;
          recordCountNoReset = 0;
          recordCountReset = 0;
          tempAvrg =0;
          rOAvrg = 0;
          rPAvrg = 0;
          records.clear();
        }
        if(isTest){
          setState(() {
            deviceModel = DeviceModel(id: "0", temperature: random(28,60).toString(), heartRate: random(80,102).toString(),oxigen: random(80,110).toString());
          });

        }

        _start--;
      },
    );
  }
  @override
  void initState() {
    lname.text = widget.user.lname;
    fname.text = widget.user.fname;
    email.text = widget.user.email;
    mobile.text = widget.user.mobileNumber;
    if(widget.connection!=null){
      List<String> datas = [];
      String temp = "";
      widget.connection!.input?.listen((Uint8List data) {
        // print(ascii.decode(data));
        if(!ascii.decode(data).contains(";")){
          temp+=ascii.decode(data);
        }
        else{
          try{
            datas = temp.replaceAll("\n", "").split(",");
            DeviceModel deviceModel = DeviceModel(id: widget.deviceID, temperature: datas[3], heartRate: datas[1],oxigen:datas[2] );

            setState(() {
              bt = temp;
              _deviceModel = deviceModel;
            });
            //
            temp = "";
          }catch(e){

          }

        }
      }).onDone(() {
        print('Disconnected by remote request');
      });
    }

    startTimer();
    super.initState();
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isRecording?200:50,
        elevation: 0,
        backgroundColor: Colors.black87,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            if(isRecording)
              Text("Recording",style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.w100),),
            if(isRecording)
              Text(Duration(seconds: recordCountNoReset).toString().replaceRange(7, 14, ""),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w100),),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[

                  if(isRecording)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(tempAvrg.toString()),
                        Text("°C",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 12),),
                      ],
                    ),
                  if(isRecording)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rPAvrg.toInt().toString()),
                        Text("/bpm",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 12),),
                      ],
                    ),
                  if(isRecording)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rOAvrg.toInt().toString()),
                        Text("%",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 12),),
                      ],
                    ),

                ]
            ),
            if(isRecording&&records.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Records - slide to navigate",style: TextStyle(color: Colors.redAccent,fontSize: 13,fontWeight: FontWeight.w100),),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CarouselSlider(
                        options: CarouselOptions(
                            height: 55.0,
                            enlargeCenterPage: true,
                            viewportFraction: 1,
                            enableInfiniteScroll: false
                        ),
                        items: records.map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(

                                width: MediaQuery.of(context).size.width,
                                // margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                    color: Colors.transparent
                                ),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(DateFormat.jms().format(i['time'] as DateTime),style: TextStyle(fontWeight: FontWeight.w100,fontSize: 12),),
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children:[
                                            if(isRecording)
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Text((i['t'] as double).toPrecision(2).toString()),
                                                  Text("°C",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 12),),
                                                ],
                                              ),
                                            if(isRecording)
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text((i['p'] as double).toInt().toString()),
                                                  Text("/bpm",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 12),),
                                                ],
                                              ),
                                            if(isRecording)
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text((i['o'] as double).toInt().toString()),
                                                  Text("%",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 12),),
                                                ],
                                              ),

                                          ]
                                      ),]

                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            if(isWarnedT||isWarnedO||isWarnedP)
              IconButton(onPressed: (){
                  if(isWarnedT){
                    senWidgetTemp.currentState!.audioPlayer.stop();
                    setState(() {
                      isWarnedT = false;
                    });
                  }
                  else if(isWarnedO){
                    senWidgetO.currentState!.audioPlayer.stop();
                    setState(() {
                      isWarnedO = false;
                    });
                  }
                  else if(isWarnedP){
                    senWidgetP.currentState!.audioPlayer.stop();
                    setState(() {
                      isWarnedP = false;
                    });
                  }
              }, icon: Icon(Icons.campaign))
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        alignment: Alignment.center,
        color: Colors.black87,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: (){
                senWidgetTemp.currentState!.reset();
                senWidgetO.currentState!.reset();
                senWidgetP.currentState!.reset();

              },
              icon: Icon(Icons.refresh,color: Colors.white,),
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
            IconButton(
              onPressed: (){
                if(!isRecording){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return WillPopScope(
                        onWillPop: () async => false,
                        child: AlertDialog(
                          title: Text('Start record'),
                          content: Text('Please make sure to place your finger inside of the sensor'),
                          actions: [
                            CustomTextButton(
                                color: MyColors.darkBlue,
                                text: 'ACCEPT',
                                onPressed: (){
                                  Navigator.of(context).pop();
                                }
                            ),
                          ],
                        ),
                      );
                    },
                  ).whenComplete((){
                    setState(() {
                      isRecording = true;
                    });
                  });
                }
                else{
                  setState(() {
                    senWidgetTemp.currentState!.audioPlayer.stop();
                    senWidgetO.currentState!.audioPlayer.stop();
                    senWidgetP.currentState!.audioPlayer.stop();
                    isWarnedT = false;
                    isWarnedO = false;
                    isWarnedP = false;
                    isRecording = false;
                  });

                }



                // senWidgetTemp.currentState!.reset();
                // senWidgetO.currentState!.reset();
                // senWidgetP.currentState!.reset();

              },
              icon: Icon(!isRecording?Icons.radio_button_unchecked:Icons.radio_button_checked,color: !isRecording?Colors.white:Colors.redAccent,),
            ),
          ],
        ),
      ),
      body: Container(
          height:  MediaQuery. of(context). size. height,
          color: Colors.black87,
          child:SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left:10,right:10,top:50,bottom: 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(widget.connection==null)
                        StreamBuilder<DocumentSnapshot>(
                            stream: DeviceController.getDevice(id: widget.deviceID),
                            builder: (context,snapshot){
                              if(!snapshot.hasData) return Center(child: Text("0"),);
                              if(!isTest){
                                DeviceModel deviceModel = DeviceModel.toObject( doc: snapshot.data!.data()!,);
                                return dataContainer(deviceModel);
                              }
                              return dataContainer(deviceModel);
                            }
                        ),
                      if(widget.connection!=null)
                        dataContainer(_deviceModel)
                    ],
                  ),
                ),

              ),
            ),
          )
      ),

    );
  }
  Widget dataContainer(DeviceModel deviceModel){
    // print(deviceModel.heartRate);
    // double heartRate = double.parse(deviceModel.heartRate);
    try{
      if(this.deviceModel.temperature!=deviceModel.temperature&&this.deviceModel.heartRate!=deviceModel.heartRate&&this.deviceModel.oxigen!=deviceModel.oxigen){
        this.deviceModel.temperature  = deviceModel.temperature;
        this.deviceModel.heartRate  = deviceModel.heartRate;
        this.deviceModel.oxigen  = deviceModel.oxigen;
        disconnected = false;
      }
      else{
        if(_start<=0){
          disconnected = true;
        }
      }
      _start = 10;
      print(isWarnedT);
      return Stack(
        children: [
          if(disconnected)
            Center(
              child: Column(
                children: [
                  Icon(Icons.sensors_off,size: 200,),
                  Text("Device disconnected"),

                ],
              ),
            ),

          Container(
            // height: MediaQuery.of(context).size.height,
            child: Opacity(
              opacity: disconnected?0.05:1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(bt,style: TextStyle(fontSize: 30),),
                  SensorWidget(
                    key: senWidgetTemp,
                    onWarningLevelReachedAtGivenMode: (value,mode){


                    },
                    onWarningLevelReachedMinAtGivenMode: (value,mode){


                    },
                    onWarningLevelReached: (value){
                      // print(value);
                    },
                    user: widget.user,
                    max: 200,
                    sensorType: SensorType.temp,
                    deviceModel: deviceModel,
                    initWarningValue: widget.user.tmax,
                    initWarningValueMin: widget.user.tmin,
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  // Text(bt,style: TextStyle(fontSize: 30),),
                  //Heart Rate
                  SensorWidget(
                    key: senWidgetP,
                    user: widget.user,
                    onWarningLevelReachedAtGivenMode: (value,mode){


                    },
                    onWarningLevelReachedMinAtGivenMode: (value,mode){
                      // telephony.sendSms(to: widget.user.mobileNumber, message: "Warning bmp reached its minimum!\nmode: "+mode.toString()+"\nTemp:"+value.toString());
                    },
                    max: 200,
                    color: MyColors.red,
                    sensorType: SensorType.bpm,
                    deviceModel: deviceModel,
                    initWarningValue: widget.user.pmax.toDouble(),
                    initWarningValueMin: widget.user.pmin.toDouble(),
                  ),
                  //oxygen
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  SensorWidget(
                    key: senWidgetO,
                    user: widget.user,
                    onWarningLevelReachedAtGivenMode: (value,mode){
                      // telephony.sendSms(to: widget.user.mobileNumber, message: "Warning oxygen level reached!\nmode: "+mode.toString()+"\nTemp:"+value.toString());
                    },
                    onWarningLevelReachedMinAtGivenMode: (value,mode){
                      // telephony.sendSms(to: widget.user.mobileNumber, message: "Warning oxygen level reached its Minimum!\nmode: "+mode.toString()+"\nTemp:"+value.toString());
                    },
                    color: MyColors.skyBlueDead,
                    sensorType: SensorType.oxygen,
                    deviceModel: deviceModel,
                    initWarningValue: widget.user.omax.toDouble(),
                    initWarningValueMin: widget.user.omin.toDouble(),
                    max: 200,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }catch(e){
      return Center(child: CircularProgressIndicator(color: Colors.white,strokeWidth: 1,),);
    }

  }

}

class _PulseRateData{
  int time,pulse;

  _PulseRateData(this.time, this.pulse);
}
extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}