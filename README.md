# ApplePayPlugin

### 使用

```dart
ApplePayPlugin.userApplePay(内购产品id, xx);
```
```dart
ApplePayPlugin.addTransactionObserver();
    ApplePayPlugin applePayPlugin = ApplePayPlugin();
    applePayPlugin.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
      String bundleid = message['bundleid'];
      String productid = message['productid'];
      String receipt = message['receipt'];
      String orderid = message['orderid'];
    },
        //请求失败
     requestFailed: (Map<String, dynamic> message) async {
     
    }, 
    payFailed: (Map<String, dynamic> message) async {
      cancelLoading();
    },
        //没查到购买的产品
    haveNoProduct: (Map<String, dynamic> message) async {
      cancelLoading();
      
    });
```
