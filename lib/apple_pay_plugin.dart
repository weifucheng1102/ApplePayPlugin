import 'dart:async';

import 'package:flutter/services.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> event);

class ApplePayPlugin {
  static const MethodChannel _channel = const MethodChannel('apple_pay_plugin');
  static Future userApplePay(String productid, String orderid) async {
    _channel.invokeMethod('userApplePay', {'productid':productid,'orderid':orderid});
  }

  EventHandler _onReceiveNotification;
  void addEventHandler({
    EventHandler onReceiveNotification,
  }) {
    _onReceiveNotification = onReceiveNotification;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "ApplePaySuccess":
        return _onReceiveNotification(call.arguments.cast<String, dynamic>());
      default:
        throw new UnsupportedError("Unrecognized Event");
    }
  }
}
