
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vipal/custom_widgets/custom_texfield.dart';
import 'package:vipal/database_services/controller.dart';
import 'package:vipal/models/user_model.dart';
import 'package:vipal/pages/registration.dart';
import 'package:vipal/tools/my_colors.dart';

import 'home.dart';



class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
   
    if(FirebaseAuth.instance.currentUser!=null){
      UserController.getUserDoc(id:FirebaseAuth.instance.currentUser!.uid ).then((value){

        UserModel userModel = UserModel.toObject(doc: value.data()!);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home(userModel: userModel,)),
              (Route<dynamic> route) => false,
        );
      });

    }
  }
  @override
  Widget build(BuildContext context) {

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
              color: MyColors.red,
              fontSize: 100,
              fontWeight: FontWeight.bold
          ),),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    CustomTextField(
                        icon: Icons.email,
                        controller: email,
                        padding: EdgeInsets.all(10),
                        hint:"Email"
                    ),
                    CustomTextField(
                        icon: Icons.password,
                        controller: password,
                        padding: EdgeInsets.all(10),
                        hint:"Password",
                        obscureText:true
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                TextButton(
                    onPressed: (){
                      FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text).then((value) {
                        UserController.getUserDoc(id:FirebaseAuth.instance.currentUser!.uid ).then((value){

                          UserModel userModel = UserModel.toObject(doc: value.data()!);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Home(userModel: userModel,)),
                                (Route<dynamic> route) => false,
                          );
                        });
                      }).catchError((onError){
                        Fluttertoast.showToast(
                            msg: "User not found!",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      });

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
                                side: BorderSide(color: MyColors.red,width: 2)
                            )
                        )
                    )
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    height: 5,
                    thickness: 1,
                    color: MyColors.red.withAlpha(50),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Text("Don't have an account yet?",style: TextStyle(color: Colors.black87.withAlpha(100)),),
                TextButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Registration()),
                      );
                    },
                    child: Container(
                        alignment: Alignment.center,
                        width: 100,
                        child: const Text("Register",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
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
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}