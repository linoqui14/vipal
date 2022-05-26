import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Authentication{
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  void registerUsingEmailPassword({required UserModel userModel,required String password,required void onError(String),required void onAdded()}) async{
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: userModel.email,
          password: password
      );
      userModel.id = userCredential.user!.uid;
      users.doc(userModel.id).set(userModel.toMap()).then((value) {
        onAdded();
      });

    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'weak-password') {
        onError("weak-password");
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        onError("email-already-in-use");
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}