



import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vipal/database_services/controller.dart';
import 'package:vipal/models/device_model.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:vipal/models/record_model.dart';
import 'package:vipal/models/user_model.dart';
import 'custom_textbutton.dart';
import 'package:uuid/uuid.dart';
import 'package:charts_flutter/flutter.dart' as charts;
class SensorType{
  static const int temp = 0;
  static const int bpm = 1;
  static const int oxygen = 2;

}

class SensorWidget extends StatefulWidget{

  const SensorWidget({Key? key,
    required this.deviceModel,
    this.onWarningLevelChange,
    this.onWarningLevelReached,
    this.sensorType = SensorType.temp,
    this.color = Colors.blueAccent,
    this.max = 100,
    this.initWarningValue = 50,
    this.onWarningLevelReachedAtGivenMode,
    this.onWarningLevelReachedMinAtGivenMode,
    this.onWarningLevelReachedMin,
    this.onWarningLevelChangeMin,
    this.initWarningValueMin = 50,
    required this.user
  }) : super(key: key,);
  final DeviceModel deviceModel;
  final Function(double)? onWarningLevelChange;
  final Function(double)? onWarningLevelReached;
  final Function(double)? onWarningLevelReachedMin;
  final Function(double)? onWarningLevelChangeMin;
  final int sensorType;
  final double max;
  final Color color;
  final double initWarningValue;
  final double initWarningValueMin;
  final Function(double,int)? onWarningLevelReachedAtGivenMode;
  final Function(double,int)? onWarningLevelReachedMinAtGivenMode;
  final UserModel user;

  @override
  State<StatefulWidget> createState() => SensorWidgetState();

}
class LinearValue {
  final int time;
  final int value;

  LinearValue(this.time, this.value);
}
class SensorWidgetState extends State<SensorWidget>{
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  int mode = 1;
  late Timer _timer;
  int _start = 10;
  double valueWarningLevel = 0;
  double valueWarningLevelMin = 0;
  double valueTotal5Mins = 0;
  double avrg5mins = 0;

  double valueTotal3Mins = 0;
  double avrg3mins = 0;

  double valueTotal1Mins = 0;
  double avrg1mins = 0;

  int ticCount5 = 0;
  int ticCount3 = 0;
  int ticCount1 = 0;

  int secCount5 = 0;
  int secCount3 = 0;
  int secCount1 = 0;
  double sensorValue = 0;
  String name = "Temperature",mesurement = "°C";
  bool isLock = true;
  bool isLockM = true;
  List<LinearValue> data = [];
  int countSensor = 0;
  List<int> values = [];
  int graphCount = 0;
  ScrollController _scrollController = ScrollController();
  int delayCount = 15;
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        _timer = timer;
        if(_start<=0){
          setState(() {

          });
        }
        if(delayCount<=0){
          if(secCount5==300){
            setState(() {
              avrg5mins = (valueTotal5Mins/ticCount5).roundToDouble();
              if(widget.onWarningLevelReachedAtGivenMode!=null&&mode==3){
                if(avrg5mins>valueWarningLevel){
                  //message or do something
                  widget.onWarningLevelReachedAtGivenMode!.call(avrg5mins,mode);
                }
              }
              if(widget.onWarningLevelReachedMinAtGivenMode!=null&&mode==3){
                if(avrg5mins<valueWarningLevelMin){
                  //message or do something
                  widget.onWarningLevelReachedMinAtGivenMode!.call(avrg5mins,mode);
                }
              }

              if(mode==3){
                if(avrg5mins>valueWarningLevel||avrg5mins<=valueWarningLevelMin){
                  //message or do something
                  // audioPlayer.play();
                }
              }

              valueTotal5Mins = 0;
              secCount5 = 0;
              ticCount5 = 0;

            });
          }
          if(secCount3==180){
            setState(() {
              avrg3mins = (valueTotal3Mins/ticCount3).roundToDouble();
              if(widget.onWarningLevelReachedAtGivenMode!=null&&mode==2){
                if(avrg3mins>valueWarningLevel){
                  //message or do something
                  widget.onWarningLevelReachedAtGivenMode!.call(avrg3mins,mode);
                }
              }
              if(widget.onWarningLevelReachedMinAtGivenMode!=null&&mode==2){
                if(avrg3mins>valueWarningLevel||avrg3mins<=valueWarningLevelMin){
                  //message or do something
                  widget.onWarningLevelReachedMinAtGivenMode!.call(avrg3mins,mode);
                }
              }

              if(mode==3){
                if(avrg3mins>valueWarningLevel){
                  //message or do something
                  // audioPlayer.play();
                }
              }
              valueTotal3Mins = 0;
              secCount3 = 0;
              ticCount3 = 0;

            });
          }
          if(secCount1==60){
            setState(() {
              avrg1mins = (valueTotal1Mins/ticCount1).roundToDouble();
              if(widget.onWarningLevelReachedAtGivenMode!=null&&mode==1){
                if(avrg1mins>valueWarningLevel){
                  //message or do something
                  widget.onWarningLevelReachedAtGivenMode!.call(avrg1mins,mode);
                }
              }
              if(widget.onWarningLevelReachedMinAtGivenMode!=null&&mode==1){
                if(avrg1mins<valueWarningLevelMin){
                  //message or do something
                  widget.onWarningLevelReachedMinAtGivenMode!.call(avrg1mins,mode);
                }
              }

              if(mode==1){
                if(avrg1mins>valueWarningLevel||avrg1mins<=valueWarningLevelMin){
                  //message or do something
                  // audioPlayer.play();
                }
              }
              valueTotal1Mins = 0;
              secCount1 = 0;
              ticCount1 = 0;

            });

          }
          secCount1++;
          secCount3++;
          secCount5++;
        }


        _start--;
        if(graphCount>3){
          graphCount = 0;
          if(countSensor>=50){
            data.clear();
            countSensor = 0;
          }
          data.add(LinearValue(countSensor, sensorValue.toInt()));
          countSensor++;
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 1),
              curve: Curves.decelerate);
        }

        graphCount++;
        if(delayCount>0){
          delayCount--;
        }


      },
    );

  }

  @override
  void initState() {
    startTimer();
    // TODO: implement initState
    valueWarningLevel = widget.initWarningValue;
    valueWarningLevelMin = widget.initWarningValueMin;
    audioPlayer.open(
        Audio("assets/sound/alarm2.wav"),
        autoStart: false,
        showNotification: true,
        loopMode: LoopMode.single
    );
    super.initState();
  }
  List<charts.Series<LinearValue, String>> _createSampleData() {
    return [
      charts.Series<LinearValue, String>(
        id: 'Sales',
        colorFn: (value, __) {
          if(value.value>valueWarningLevel){
            return charts.Color.fromHex(code: '#FF3A00');
          }
          return charts.MaterialPalette.blue.shadeDefault;
        },
        domainFn: (LinearValue value, _) {

          return value.time.toString();
        } ,
        measureFn: (LinearValue value, _) {

          return value.value;
        } ,
        data: data,
      )
    ];
  }
  @override
  void dispose() {
    _timer.cancel();
    audioPlayer.stop();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    bool isWarned = false;
    switch (widget.sensorType){
      case SensorType.temp:
        name = "Temperature";
        mesurement = "°C";
        try{
          sensorValue = double.parse(widget.deviceModel.temperature);
        }catch(e){
          sensorValue = sensorValue;
        }

        break;
      case SensorType.bpm:
        name = "Pulse Rate";
        mesurement = "/bpm";
        try{
          sensorValue = double.parse(widget.deviceModel.heartRate);
        }catch(e){
          sensorValue = sensorValue;
        }

        break;
      case SensorType.oxygen:
        name = "Oxygen Level";
        mesurement = "%";
        try{
          sensorValue = double.parse(widget.deviceModel.oxigen);
        }catch(e){
          sensorValue = sensorValue;
        }

        break;

    }
    if(valueWarningLevel<=sensorValue){
      // audioPlayer.play();
      isWarned = true;
      if(widget.onWarningLevelReached!=null){
        widget.onWarningLevelReached!.call(sensorValue);
      }
    }
    if(valueWarningLevelMin>=sensorValue){
      // audioPlayer.play();
      isWarned = true;
      if(widget.onWarningLevelReachedMin!=null){
        widget.onWarningLevelReachedMin!.call(sensorValue);
      }
    }
    if(sensorValue>0){
      valueTotal5Mins+=sensorValue;
      valueTotal3Mins+=sensorValue;
      valueTotal1Mins+=sensorValue;
      ticCount1++;
      ticCount3++;
      ticCount5++;
    }
    return Container(
      padding:EdgeInsets.all(10),

      decoration: BoxDecoration(
        border: Border.all(
            color: isWarned?Colors.red:Colors.transparent,
            width: 5
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color:widget.color.withAlpha(50),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left:23,right: 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,style: TextStyle(fontWeight: FontWeight.w100,fontSize: 13,color: Colors.white),),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sensorValue.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 60,color: Colors.white),),
                    Text(mesurement,
                      style: TextStyle(fontWeight: FontWeight.w100,fontSize: 30,color: Colors.white),),

                  ],
                ),
                // Text(delayCount.toString(),style: TextStyle(color: Colors.white),),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20),topRight:Radius.circular(20) ),
                    color:widget.color.withAlpha(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            if(mode==3){
                              audioPlayer.stop();
                            }
                            mode = 3;
                          });
                        },
                        child: Column(
                          children: [
                            Text("5min",style: TextStyle(color:Colors.white,fontWeight: FontWeight.w100)),
                            Text(avrg5mins.toString(),style: TextStyle(color:mode==3?Colors.amber:Colors.white,fontWeight: FontWeight.bold,fontSize: 20)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            if(mode==2){
                              audioPlayer.stop();
                            }
                            mode = 2;
                          });
                        },
                        child: Column(
                          children: [
                            Text("3min",style: TextStyle(color:Colors.white,fontWeight: FontWeight.w100)),
                            Text(avrg3mins.toString(),style: TextStyle(color:mode==2?Colors.amber:Colors.white,fontWeight: FontWeight.bold,fontSize: 20)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            if(mode==1){
                              audioPlayer.stop();
                            }
                            mode = 1;
                          });
                        },
                        child: Column(
                          children: [
                            Text("1min",style: TextStyle(color:Colors.white,fontWeight: FontWeight.w100)),
                            Text(avrg1mins.toString(),style: TextStyle(color:mode==1?Colors.amber:Colors.white,fontWeight: FontWeight.bold,fontSize: 20)),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Container(
                  width: MediaQuery. of(context). size. width,
                  height: 100,
                  child: charts.BarChart(_createSampleData(), animate: false,)
              )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Max",style:TextStyle(color: Colors.white,fontWeight: FontWeight.w100),),
              Expanded(
                child: SliderTheme(
                  data:  SliderThemeData(
                      activeTrackColor: widget.color.withAlpha(150),
                      inactiveTrackColor: widget.color.withAlpha(50),
                      thumbColor: widget.color,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                      trackHeight: 20

                  ),
                  child: Slider(
                      thumbColor: widget.color,
                      max:  widget.max,
                      min: 0,
                      value: valueWarningLevel,
                      onChanged: (value){

                        if(widget.onWarningLevelChange!=null){
                          widget.onWarningLevelChange!.call(value);
                        }
                        setState(() {

                          if(!isLock){
                            valueWarningLevel = value;
                          }

                        });
                      }),
                ),
              ),
              GestureDetector(
                onTap: (){
                  setState(() {
                    isLock = isLock?false:true;
                    if(isLock){
                      isLock = false;
                    }
                    else {
                      isLock = true;
                      switch (widget.sensorType){
                        case SensorType.temp:
                          widget.user.tmax = valueWarningLevel;
                          break;
                        case SensorType.bpm:
                          widget.user.pmax = valueWarningLevel.toInt();
                          break;
                        case SensorType.oxygen:
                          widget.user.omax = valueWarningLevel.toInt();
                          break;
                      }
                      UserController.upSert(user: widget.user);
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 25),
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color:widget.color.withAlpha(50),
                  ),

                  child: isLock?Icon(Icons.lock,color: widget.color,size: 15,):Icon(Icons.lock_open,color: Colors.white,size: 15),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Min",style:TextStyle(color: Colors.white,fontWeight: FontWeight.w100),),
              Expanded(
                child: SliderTheme(
                  data:  SliderThemeData(
                      activeTrackColor: widget.color.withAlpha(150),
                      inactiveTrackColor: widget.color.withAlpha(50),
                      thumbColor: widget.color,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                      trackHeight: 20

                  ),
                  child: Slider(
                      thumbColor: widget.color,
                      max:  widget.max,
                      min: 0,
                      value: valueWarningLevelMin,
                      onChanged: (value){

                        if(widget.onWarningLevelChangeMin!=null){
                          widget.onWarningLevelChangeMin!.call(value);
                        }
                        setState(() {

                          if(!isLockM&&value<valueWarningLevel){
                            valueWarningLevelMin = value;
                          }

                        });
                      }),
                ),
              ),
              GestureDetector(
                onTap: (){
                  setState(() {
                    setState(() {

                      if(isLockM){
                        isLockM = false;
                      }
                      else {
                        isLockM = true;
                        switch (widget.sensorType){
                          case SensorType.temp:
                            widget.user.tmin = valueWarningLevelMin;
                            break;
                          case SensorType.bpm:
                            widget.user.pmin = valueWarningLevelMin.toInt();
                            break;
                          case SensorType.oxygen:
                            widget.user.omin = valueWarningLevelMin.toInt();
                            break;
                        }
                        UserController.upSert(user: widget.user);
                      }
                    });

                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 25),
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color:widget.color.withAlpha(50),
                  ),

                  child: isLockM?Icon(Icons.lock,color: widget.color,size: 15,):Icon(Icons.lock_open,color: Colors.white,size: 15),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning,color: Colors.amber,),
                    Text(valueWarningLevelMin.roundToDouble().toString()+mesurement,style: TextStyle(color: Colors.white),),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.warning,color: Colors.amber,),
                    Text(valueWarningLevel.roundToDouble().toString()+mesurement,style: TextStyle(color: Colors.white),),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }
  Map<String,dynamic> getValue(){
    return {
      "value":sensorValue,
      "type":widget.sensorType
    };
  }
  
  void reset(){
    setState(() {
      delayCount = 15;
      audioPlayer.stop();
      valueTotal5Mins= 0;
      valueTotal3Mins= 0;
      valueTotal1Mins= 0;
      ticCount1= 0;
      ticCount3= 0;
      ticCount5= 0;
      secCount1 = 0;
      secCount3 = 0;
      secCount5 = 0;
      avrg1mins = 0;
      avrg3mins = 0;
      avrg5mins = 0;
    });

  }

}