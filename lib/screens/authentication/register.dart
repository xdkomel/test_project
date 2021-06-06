import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plane_chat/custom_widgets/rounded_button.dart';
import 'package:plane_chat/custom_widgets/rounded_input_field.dart';
import 'package:plane_chat/custom_widgets/rounded_password_field.dart';
import 'package:plane_chat/models/SessionKeeper.dart';
import 'package:plane_chat/models/UserData.dart';
import 'package:plane_chat/screens/authentication/sign_in.dart';
import 'package:plane_chat/screens/home/home.dart';
import 'package:plane_chat/services/auth.dart';
import 'package:plane_chat/shared/loading.dart';
import 'package:plane_chat/shared/regex.dart';
import 'package:plane_chat/shared/constants.dart' as constants;
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Register extends StatefulWidget {

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  List<FocusNode> nodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode()
  ];

  final AuthService _auth = AuthService();

  bool checkedValue = false;
  String nameSurname = "";

  String email = "";
  String password = "";
  String confPassword = "";
  String errorLabel = "";
  bool isError = false;

  bool loading = false;

  void toggleSplashScreen(){
    setState(() {
      loading = !loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading? Loading() : Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: size.height * 0.01),
        child: SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Spacer(),
                  SizedBox(
                    height: 59,
                  ),
                  Center(
                    child: Text(constants.REGISTRATION.tr(),
                        style: TextStyle(
                          fontFamily: "Baloo",
                          color: constants.accentColor,
                          fontSize: 30,
                          fontWeight: FontWeight.normal,
                        )),
                  ),

                  SizedBox(
                    height: 34,
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 23),
                    child: RoundedInputField(
                        hintText: constants.NAME.tr(),
                        //textAlign: TextAlign.center,
                        onChanged: (name) {
                          nameSurname = name;
                        },
                        initialValue: nameSurname,
                        keyboard: TextInputType.visiblePassword,
                        width: 0.85,
                        maxHeight: 0.07,
                        maxCharacters: 30,
                        current: nodes[0],
                        next: nodes[1]),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 23),
                    child: RoundedInputField(
                        hintText: constants.EMAIL.tr(),
                        //textAlign: TextAlign.center,
                        initialValue: email,
                        keyboard: TextInputType.emailAddress,
                        width: 0.85,
                        maxHeight: 0.07,
                        maxCharacters: 30,
                        onChanged: (email) {
                          this.email = email;
                        },
                        current: nodes[1],
                        next: nodes[2]),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 23),
                    child: RoundedPasswordField(
                        hintText: constants.PASSWORD.tr(),
                        //textAlign: TextAlign.center,
                        keyboard: TextInputType.visiblePassword,
                        width: 0.85,
                        maxHeight: 0.07,
                        maxCharacters: 30,
                        onChanged: (password) {
                          this.password = password;
                        },
                        current: nodes[2],
                        next: nodes[3]),
                  ),

                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 23, right: 23, top: 27),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Theme(
                              data: ThemeData(
                                  unselectedWidgetColor: constants.accentColor),
                              child: Transform.scale(
                                scale: 1.5,
                                child: Checkbox(
                                    value: checkedValue,
                                    activeColor: constants.accentColor,
                                    hoverColor: constants.accentColor,
                                    onChanged: (state) {
                                      setState(() {
                                        checkedValue = state!;
                                      });
                                    }),
                              )),
                          privacyPolicyLinkAndTermsOfService()
                        ],
                      )),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Center(
                      child:InkWell(
                          child: Text(
                            constants.ALREADY_A_MEMBER.tr(),
                            style: TextStyle(
                              height: 1,
                              fontSize: 20,
                              color: constants.accentColor,
                              fontFamily: "Baloo",
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap: () async {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                            );
                          }),
                    ),
                  ),

                  Spacer(),
                  if (isError)
                    Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 15, left: 23, right: 23),
                          child: Text(errorLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Baloo",
                                color: Colors.orange,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              )),
                        )),

                  Container(
                    margin: EdgeInsets.only(left: 23, right: 23, bottom: 21),
                    child: RoundedButton(
                      text: constants.SIGN_UP.tr(),
                      textColor: Colors.white,
                      textSize: 20,
                      press: () async {
                        errorLabel = "";
                        if(mounted){
                          setState(() {
                            isError = true;
                          });
                        }

                        if(!validateName(nameSurname)){
                          errorLabel = constants.INCORRECT_NAME.tr();
                        }else if (!validateEmail(email)) {
                          errorLabel = constants.INCORRECT_EMAIL.tr();
                        } else if (!validatePassword(password)) {
                          errorLabel = constants.INCORRECT_PASSWORD.tr();
                        } else if (!checkedValue) {
                          errorLabel = constants.ACCEPT_POLICY.tr();
                        } else {
                          if(mounted) {
                            setState(() {
                              isError = false;
                              loading=true;
                            });
                          }

                          User result = await _auth.registerWithEmailAndPassword(
                              email, password, nameSurname);
                          if(mounted){
                            setState(() {
                                loading = false;
                            });
                          }

                          if (result == null) {
                            if(mounted){
                              setState(() {
                                errorLabel = constants.REGISTRATION_FAILED;
                                isError = true;
                              });
                            }

                          } else {
                            FirebaseFirestore.instance.collection('users').doc(result.uid).collection("flights").doc('AB 1234').set({
                              'id': 'AB 1234',
                            });
                            FirebaseFirestore.instance.collection('users').doc(result.uid).collection("flights").doc('BM 2345').set({
                              'id': 'BM 2345',
                            });
                            FirebaseFirestore.instance.collection('users').doc(result.uid).set({
                              'email': email,
                              'name': nameSurname
                            });
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString('email', email);
                            prefs.setString('name', nameSurname);
                            SessionKeeper.user = new UserData(uid: result.uid, name: nameSurname);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            )),
      ),
    );


  }
  Widget privacyPolicyLinkAndTermsOfService() {
    return Flexible(
      child: Container(
        alignment: Alignment.center,
        //padding: EdgeInsets.all(10),
        child: Center(
          child:InkWell(
              child: Text(
                constants.POLICY_AGREEMENT.tr(),
                style: TextStyle(
                  height: 1,
                  fontSize: 15,
                  color: Colors.black,
                  fontFamily: "Baloo",
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Tap'),
                ));
              }),
        ),
      ),
    );
  }

  bool validateEmail(String email) {
    return RegExp(r"" + RegexType.EMAIL).hasMatch(email);
  }

  bool validatePassword(String password) {
    return RegExp(r"" + RegexType.PASSWORD).hasMatch(password);
  }

  bool validateName(String name) {
    return RegExp(RegexType.NAME).hasMatch(name);
  }

}


