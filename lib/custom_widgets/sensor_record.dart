



import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vipal/models/record_model.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class SensorRecord extends StatefulWidget{
  const SensorRecord({Key? key,required this.records,required this.measurement}) : super(key: key);
  final List<RecordModel> records;
  final String measurement;
  @override
  State<SensorRecord> createState()=>_SensorRecordState();
}

class _SensorRecordState extends State<SensorRecord>{
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOn; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  @override
  Widget build(BuildContext context) {
    int dayTotal = 0;
    widget.records.sort((a,b) =>a.time.compareTo(b.time));
    DateTime firstDate = DateTime.fromMillisecondsSinceEpoch(widget.records.first.time);
    DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(widget.records.last.time);

    List<DateTime> calculateDaysInterval(DateTime startDate, DateTime endDate) {
      List<DateTime> days = [];
      for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
        days.add(startDate.add(Duration(days: i)));
      }
      return days;
    }



    widget.records.sort((b,a)=>a.time.compareTo(b.time));

    // TODO: implement build
    return Scaffold(

      body: Container(
        color: Colors.black87,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    height: 215,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(widget.records.first.sensor.toString(),style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 200),),
                            Container(
                                margin: EdgeInsets.only(top: 30),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  color: Color(0xff212121),
                                ),
                                child: Text(widget.measurement,style: TextStyle(color:Colors.white,fontSize: 30,fontWeight: FontWeight.w100,))
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(DateFormat.yMMMd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(widget.records.first.time)) ,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w100,fontSize: 30),),
                ],
              ),

              Divider(color: Colors.white.withAlpha(50),thickness: 0.5,),
              TableCalendar(
                firstDay: DateTime.now().subtract(Duration(days: 30)),
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: _calendarFormat,
                rangeSelectionMode: _rangeSelectionMode,
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _rangeStart = null; // Important to clean those
                      _rangeEnd = null;
                      _rangeSelectionMode = RangeSelectionMode.toggledOff;
                    });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          List<RecordModel> records = [];

                          widget.records.where((rDate) {
                            DateTime rdate = DateTime.fromMillisecondsSinceEpoch(rDate.time);
                            return (rdate.year == selectedDay.year && rdate.month == selectedDay.month && rdate.day == selectedDay.day);
                          }).forEach((element) {
                            records.add(element);
                          });

                          return AlertDialog(
                            title: Text('Records'),
                            content: SizedBox(
                              height: 500,
                              width: 400,
                              child: ListView(
                                children: records.map((e) {
                                  return Container(
                                    height: 45,
                                    padding:EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateFormat.yMMMEd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(e.time)),style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w100),),
                                        Text(e.sensor.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close', style: TextStyle(color: Colors.black),),
                              ),
                            ],
                          );
                        },
                      );

                  }
                },
                onRangeSelected: (start, end, focusedDay) {

                  setState(() {
                    _selectedDay = null;
                    _focusedDay = focusedDay;
                    _rangeStart = start;
                    _rangeEnd = end;
                    _rangeSelectionMode = RangeSelectionMode.toggledOn;
                  });
                  if(start!=null&&end!=null){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        List<RecordModel> records = [];

                        calculateDaysInterval(start,end).forEach((date) {
                          widget.records.where((rDate) {
                            DateTime rdate = DateTime.fromMillisecondsSinceEpoch(rDate.time);
                            return (rdate.year == date.year && rdate.month == date.month && rdate.day == date.day);
                          }).forEach((element) {
                            records.add(element);
                          });
                        });

                        records.sort((b, a) => a.time.compareTo(b.time));
                        int prevDate = 0;
                        return AlertDialog(
                          title: Text('Records'),
                          content: SizedBox(
                            height: 500,
                            width: 400,
                            child: ListView(
                              children: records.map((e) {
                                return Container(
                                  height: 45,
                                  padding:EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat.yMMMEd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(e.time)),style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w100),),
                                      Text(e.sensor.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close', style: TextStyle(color: Colors.black),),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}