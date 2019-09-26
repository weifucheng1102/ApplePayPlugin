import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:apple_pay_plugin/apple_pay_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
    ApplePayPlugin applePay = ApplePayPlugin();
    applePay.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
      //请求验证接口
      return Future.value('chenggong');
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {} on PlatformException {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: FlatButton(
            child: Text('支付'),
            onPressed: () {
              String alphabet =
                  'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
              int strlenght = 30;

              /// 生成的字符串固定长度
              String left = '';
              for (var i = 0; i < strlenght; i++) {
                left = left + alphabet[Random().nextInt(alphabet.length)];
              }
              ApplePayPlugin.userApplePay('sy_qd_1', left);
            },
          ),
        ),
      ),
    );
  }
}
