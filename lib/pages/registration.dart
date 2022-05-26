import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vipal/custom_widgets/custom_texfield.dart';
import 'package:vipal/models/user_model.dart';
import 'package:vipal/pages/login.dart';
import 'package:vipal/tools/my_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../database_services/authentication.dart';
import 'home.dart';
class Registration extends StatefulWidget{
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();


}

class _RegistrationState extends State<Registration>{
  TextEditingController lname = TextEditingController();
  TextEditingController fname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController passwordConfirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 160,
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle:true,
        title:  Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Text("Vi-Pal",style: GoogleFonts.comforter(
              color: MyColors.deadBlue,
              fontSize: 100,
              fontWeight: FontWeight.bold
          ),),
        ),
      ),
      body: Container(
        width:MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        padding: EdgeInsets.only(right: 10,left: 10,top: 10,bottom: 10),
        child: SingleChildScrollView(
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
                  Text("Password",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color:MyColors.deadBlue),),
                  Column(
                      children: [
                        CustomTextField(
                          controller: password,
                          obscureText: true,
                          color: MyColors.deadBlue,
                          rTopLeft:0 ,
                          hint: "Password",
                          padding: EdgeInsets.symmetric(vertical: 5),

                        ),
                        Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                        CustomTextField(
                          controller:passwordConfirm ,
                          obscureText: true,
                          color: MyColors.deadBlue,
                          hint: "Confirm Password",
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),

                      ]
                  ),

                ],
              ),
              TextButton(
                  onPressed: ()async {
                    print("REGISTER!");
                    if(passwordConfirm.text!=password.text){
                      Fluttertoast.showToast(
                          msg: "Password confirmation is incorrect",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                    if(passwordConfirm.text.isNotEmpty&&
                        password.text.isNotEmpty&&
                        lname.text.isNotEmpty&&
                        fname.text.isNotEmpty&&
                        email.text.isNotEmpty&&
                        mobile.text.isNotEmpty
                    ){

                      UserModel userModel = UserModel(fname: fname.text, lname: lname.text, email: email.text, mobileNumber: mobile.text);
                      Authentication().registerUsingEmailPassword(
                        userModel: userModel,
                        onError: (status) {

                          if("weak-password"==status){
                            Fluttertoast.showToast(
                                msg: "Password is too weak!",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          }
                          else{
                            Fluttertoast.showToast(
                                msg: "Email is already in used",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          }


                        },
                        onAdded: (){
                          setState(() {

                          });
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Home(userModel: userModel,)),
                                (Route<dynamic> route) => false,
                          );
                        },
                        password: password.text,
                      );
                    }
                    else{
                      print(passwordConfirm.text);

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
                      child: const Text("Submit",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Divider(
                  height: 5,
                  thickness: 1,
                  color: MyColors.red.withAlpha(50),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              Text("Already have an account?",style: TextStyle(color: Colors.black87.withAlpha(100)),),
              TextButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: const Text("Login",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(MyColors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),

                          )
                      )
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

}