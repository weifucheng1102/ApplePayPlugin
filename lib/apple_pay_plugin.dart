import 'dart:async';

import 'package:flutter/services.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> event);

class ApplePayPlugin {
  static const MethodChannel _channel = const MethodChannel('apple_pay_plugin');

  
  static Future addTransactionObserver() async {
    _channel.invokeMethod('addTransactionObserver');
  }
  static Future userApplePay(String productid, String orderid) async {
    _channel.invokeMethod('userApplePay', {'productid':productid,'orderid':orderid});
  }

  EventHandler _onReceiveNotification;
  EventHandler _haveNoProduct;
  EventHandler _requestFailed;
  void addEventHandler({
    EventHandler onReceiveNotification,
    EventHandler haveNoProduct,
    EventHandler requestFailed,

  }) {
    _onReceiveNotification = onReceiveNotification;
    _haveNoProduct = haveNoProduct;
    _requestFailed = requestFailed;
    _channel.setMethodCallHandler(_handleMethod);
  }


  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "ApplePaySuccess":
        return _onReceiveNotification(call.arguments.cast<String, dynamic>());
      case "haveNoProduct":
        return _haveNoProduct(call.arguments.cast<String, dynamic>());
      case "requestFailed":
        return _requestFailed(call.arguments.cast<String, dynamic>());
      default:
        throw new UnsupportedError("Unrecognized Event");
    }
  }
}
