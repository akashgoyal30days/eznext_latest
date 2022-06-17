import 'dart:io';

import 'package:eznext/api_models/school_code.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/app_constants/loader.dart';
import 'package:eznext/app_constants/popup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../main.dart';
import 'login.dart';

class Scode extends StatefulWidget {
  @override
  _ScodeState createState() => _ScodeState();
}

class _ScodeState extends State<Scode> {
  final myKey = new GlobalKey<_ScodeState>();
  dynamic schoolCodeController = TextEditingController();
  bool enabled = true;

  @override
  void initState() {
    tokens();
    super.initState();
  }

  void tokens() async {
    await Firebase.initializeApp();
    FirebaseMessaging messagings = FirebaseMessaging.instance;
    SharedPreferences studentdetails = await SharedPreferences.getInstance();
    setState(() {
      os = Platform.operatingSystem;
      //debugPrint(os.toString());

      //---getting username----//

      //----saving firebasetoken---//

      messagings.getToken().then((token) {
        studentdetails.setString('fbasetoken', token);
      });
      devtoken = studentdetails.getString('fbasetoken');
      //debugPrint(devtoken.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: themecolor,
        child: Stack(
          children: [
            Positioned(
                bottom: 100, right: 46, child: Image.asset('assets/ssit.png')),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 80,
                  ),
                  Image.asset(
                    'assets/EZLOGO.png',
                    height: 70,
                    width: 200,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
                    child: Text(
                      'Enter School',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2A75B6),
                        decoration: TextDecoration.none,
                      )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Text(
                      'Code',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2A75B6),
                        decoration: TextDecoration.none,
                      )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      height: 50,
                      child: CupertinoTextField(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Color(0xFF2A75B6)),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                          ),
                        ),
                        enabled: enabled,
                        controller: schoolCodeController,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                              RegExp(r'[/\\_@$-]')),
                          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                        ],
                        suffix: GestureDetector(
                            onTap: enabled == true
                                ? () async {
                                    if (schoolCodeController.text.isNotEmpty) {
                                      var scode = schoolCodeController.text;
                                      // Dialogs.showLoadingDialog(context, myKey, 'Hold on.. connecting to school');
                                      setState(() {
                                        enabled = false;
                                      });
                                      try {
                                        var rsp = await Scul_code(
                                            scode.toString().toLowerCase());
                                        //debugPrint(rsp.toString());
                                        if (rsp.containsKey('url')) {
                                          // Navigator.pop(context);
                                          setState(() {
                                            enabled = true;
                                          });
                                          SharedPreferences initialschoolcode =
                                              await SharedPreferences
                                                  .getInstance();
                                          initialschoolcode.setString(
                                              'url', rsp['url']);
                                          initialschoolcode.setString(
                                              'site_url', rsp['site_url']);
                                          initialschoolcode.setString(
                                              'app_logo', rsp['app_logo']);
                                          Future.delayed(
                                              const Duration(seconds: 0), () {
                                            Navigator.pushReplacement(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        Login()));
                                          });
                                        }
                                      } catch (error) {
                                        //debugPrint(error.toString());
                                        setState(() {
                                          enabled = true;
                                        });
                                        Toast.show(wrong_school_code_error_text,
                                            context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.BOTTOM,
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                            backgroundRadius: 5);
                                      }
                                    } else {
                                      PopUps.showPopDialoguge(context, myKey,
                                          'School code is empty', 'error');
                                    }
                                  }
                                : null,
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5.0),
                                    bottomRight: Radius.circular(5.0),
                                  ),
                                  color: enabled == true
                                      ? CupertinoColors.link
                                      : CupertinoColors.systemGrey5,
                                ),
                                height: 50,
                                width: 50,
                                //color: Colors.blue,
                                child: Icon(
                                  CupertinoIcons.forward,
                                  color: CupertinoColors.white,
                                ))),
                        placeholder: "School Code Here",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Powered by EZNEXT School ERP',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: CupertinoColors.black,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (enabled == false)
                    Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()),
                  if (enabled == false)
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Hold on.. Connecting to school',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.blue,
                              decoration: TextDecoration.none),
                        )),
                  Spacer(),
                ],
              ),
            ),
          ],
        ));
  }
}
