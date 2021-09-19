import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Helper.dart';

class ScanQrcodePage extends StatefulWidget {
  const ScanQrcodePage({Key? key}) : super(key: key);

  @override
  _ScanQrcodePageState createState() => _ScanQrcodePageState();
}

class _ScanQrcodePageState extends State<ScanQrcodePage> {
  Helper helper = Helper();

  static const platform = const MethodChannel("th.go.moph.covidfree/reader");

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  //String result = "";
  QRViewController? controller;

  String resultStatus = "";
  String firstName = "";
  String lastName = "";
  int isPass = 1; // 1 = scanning, 2 = pass, 3 = deny

  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : helper.toastError("ไม่สามารถเปิด URL ได้");

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 200.0;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xff011c10)),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "SCAN QRCODE",
          style: TextStyle(color: Color(0xff011c10)),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await controller!.resumeCamera();
                setState(() {
                  isPass = 1;
                  resultStatus = "";
                  firstName = "";
                  lastName = "";
                });
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            // flex: 5,
            child: QRView(
              key: qrKey,
              overlay: QrScannerOverlayShape(
                  borderColor: Colors.red,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: scanArea),
              onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10))),
          height: 100,
          child: isPass == 1
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                      backgroundColor: Colors.pink[100],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text('กำลังสแกน QR CODE...'),
                    )
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'ผลการสแกน QR Code',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "$firstName $lastName",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    Text(
                      "$resultStatus",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPass == 3
                              ? Colors.pink
                              : isPass == 2
                                  ? Colors.green
                                  : Colors.grey),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: FloatingActionButton(
        child: isPass == 1
            ? Icon(
                Icons.more_horiz,
                size: 55,
                color: Colors.grey,
              )
            : isPass == 2
                ? Icon(
                    Icons.check_circle,
                    size: 55,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.remove_circle,
                    size: 55,
                    color: Colors.pink,
                  ),
        onPressed: () {},
        backgroundColor: Colors.white,
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  Future _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      print(scanData.code);

      if (scanData.code.isNotEmpty) {
        try {
          var qrcode = scanData.code;

          var strHC1 = qrcode.substring(0, 3);

          if (strHC1 == "HC1") {
            String _result =
                await platform.invokeMethod("verifyqrcode", scanData.code);
            print('xxxxxxxxxxxxxxx');
            print(_result);
            print('xxxxxxxxxxxxxxxxxx');
            if (_result.isNotEmpty) {
              Map<String, dynamic> resultJson = jsonDecode(_result);
              if (resultJson.containsKey("-260")) {
                Map result260 = resultJson["-260"];

                setState(() {
                  firstName = result260["1"]["nam"]["gn"];
                  lastName = result260["1"]["nam"]["fn"];
                });

                List vaccines = [];
                List tests = [];
                List recovery = [];

                if (result260.containsKey("1")) {
                  Map result1 = result260["1"];

                  if (result1.containsKey("v")) {
                    vaccines = result1["v"];
                  }

                  if (result1.containsKey("t")) {
                    tests = result1["t"];
                  }

                  if (result1.containsKey("r")) {
                    recovery = result1["r"];
                  }
                }

                print("============vaccines==================");
                print(vaccines);
                print("=======================================");
                print("===============tests===============");
                print(tests);
                print("=======================================");
                print("==============recovery=================");
                print(recovery);
                print("=======================================");

                bool isTestPass = false;
                bool isVaccinePass = false;
                bool isRecoveryPass = false;

                if (vaccines.length > 0) {
                  isVaccinePass = helper.checkVaccinePass(vaccines);
                  print("vaccine pass: $isVaccinePass");
                }

                if (recovery.length > 0) {
                  isRecoveryPass = helper.checkRecoveryPass(recovery);
                  print("recovery pass: $isRecoveryPass");
                }

                if (tests.length > 0) {
                  isTestPass = helper.checkTestsPass(tests);
                  print("test pass: $isTestPass");
                }

                if (isTestPass || isVaccinePass || isRecoveryPass) {
                  setState(() {
                    isPass = 2;
                    resultStatus = "เข้าเงื่อนไขปลอดโควิด";
                  });
                } else {
                  isPass = 3;
                  resultStatus = "ไม่เข้าเงื่อนไขปลอดโควิด";
                }
              } else {
                setState(() {
                  isPass = 3;
                  resultStatus = "ไม่เข้าเงื่อนไขปลอดโควิด";
                });
              }
            } else {
              setState(() {
                isPass = 1;
                lastName = "";
                firstName = "";
                resultStatus = "ไม่สามารถอ่านข้อมูลได้";
              });
            }

            await controller.stopCamera();
          } else {
            final uri = Uri.parse(qrcode);
            if (uri.host == "co19cert.moph.go.th") {
              setState(() {
                isPass = 1;
                firstName = "";
                lastName = "";
                resultStatus = "QR CODE หมอพร้อม";
              });

              _launchURL(qrcode);
            } else {
              setState(() {
                isPass = 3;
                firstName = "";
                lastName = "";
                resultStatus = "ไม่สามารถอ่านข้อมูลได้";
              });
            }
          }
        } catch (e) {
          setState(() {
            isPass = 3;
            firstName = "";
            lastName = "";
            resultStatus = "ไม่สามารถอ่านข้อมูลได้";
          });
          await controller.resumeCamera();
          print(e);
        }
      } else {
        print("ไม่พบ");
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
