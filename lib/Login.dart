
import 'package:covidfree/Helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'PincodeLogin.dart';
import 'Register.dart';
import 'Scan.dart';
import 'ScanQrcode.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Helper helper = Helper();

  Future initial() async {
    String? token = await helper.getStorage("token");
    if(token!.isNotEmpty) {
      // print(token);
      // Map<String, dynamic> payload = Jwt.parseJwt(token);
      bool isExpired = Jwt.isExpired(token);

      if (!isExpired) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ScanPage()));
      }

    }
  }

  @override
  void initState() {
    initial();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xff011c10)),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "เข้าสู่ระบบ/ลงทะเบียน",
          style: TextStyle(color: Color(0xff011c10)),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                height: 200,
                width: 200,
                child: Image(
                  image: AssetImage("assets/images/stopcovid_logo.jpg"),
                  width: 200,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(fontSize: 18),
                            elevation: 0,
                            primary: Color(0xff1a237e),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PincodeLoginPage()));
                          },
                          child: Text(
                            'เข้าใช้งาน Thai Stop Covid+',
                            style: TextStyle(fontFamily: "Kanit"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(fontSize: 18),
                            elevation: 0,
                            primary: Colors.red[600],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ScanQrcodePage()));
                          },
                          child: Text(
                            'ตรวจสอบ QR CODE',
                            style: TextStyle(fontFamily: "Kanit"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                                fullscreenDialog: true));
                          },
                          child: const Text(
                            'ลงทะเบียน',
                            style: TextStyle(
                              color: Color(0xff1a237e),
                                fontWeight: FontWeight.bold, fontFamily: "Kanit"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '© 2021 ICT@MOPH',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'version 1.0.0 (20210921)',
                  style: TextStyle(color: Colors.grey),
                ),
                // Text(
                //   'ศูนย์เทคโนโลยีสารสนเทศและการสื่อสาร',
                //   style: TextStyle(color: Colors.grey),
                // ),
                Text(
                  'โดย กระทรวงสาธารณสุข',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
