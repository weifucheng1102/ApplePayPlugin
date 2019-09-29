#import "ApplePayPlugin.h"
#import <StoreKit/StoreKit.h>
@interface ApplePayPlugin ()
//遵循代理
<
SKPaymentTransactionObserver,
SKProductsRequestDelegate
>
@end
@implementation ApplePayPlugin
FlutterMethodChannel *_channel;
NSString * _orderid;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"apple_pay_plugin"
            binaryMessenger:[registrar messenger]];
    _channel = channel;
  ApplePayPlugin* instance = [[ApplePayPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if([@"userApplePay" isEqualToString:call.method]){
      _orderid = call.arguments[@"orderid"];
      [self initApplePayWithProductid:call.arguments[@"productid"]];
  } else if([@"addTransactionObserver" isEqualToString:call.method]){
       [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  }else{
    result(FlutterMethodNotImplemented);
  }
}

- (void)initApplePayWithProductid:(NSString *)productid
{
    //是否允许内购
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"用户允许内购");

        //bundleid+xxx 就是你添加内购条目设置的产品ID
        NSArray *product = [[NSArray alloc] initWithObjects:productid,nil];
        NSSet *nsset = [NSSet setWithArray:product];

        //初始化请求
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
        request.delegate = self;

        //开始请求
        [request start];

    }else{
        
        NSLog(@"用户不允许内购");
    }

}
#pragma mark - SKProductsRequestDelegate
//接收到产品的返回信息，然后用返回的商品信息进行发起购买请求
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response NS_AVAILABLE_IOS(3_0)
{
    NSArray *product = response.products;

    //如果服务器没有产品
    if([product count] == 0){
        [_channel invokeMethod:@"haveNoProduct" arguments:@{@"test":@"test"}];
        return;
    }

    SKProduct *requestProduct = nil;
    for (SKProduct *pro in product) {

        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        requestProduct = pro;
    }
    //发送购买请求
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:requestProduct];
        payment.applicationUsername = _orderid;//可以是userId，也可以是订单id，跟你自己需要而定
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKRequestDelegate
//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
     [_channel invokeMethod:@"requestFailed" arguments:@{@"test":@"test"}];
    NSLog(@"error:%@", error);
}

//请求结束
- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"请求结束");
}

#pragma mark - SKPaymentTransactionObserver
//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction *tran in transactions){
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"交易完成");
                //订单id存一下  跟苹果的交易id 对应
                [self completeTransaction:tran];
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");

                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran]; //消耗型商品不用写

                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                 [_channel invokeMethod:@"payFailed" arguments:@{@"test":@"test"}];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];

                break;
            default:
                break;
        }
    }
}

//交易结束,当交易结束后还要去appstore上验证支付信息是否都正确,只有所有都正确后,我们就可以给用户方法我们的虚拟物品了。
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    //直接去请求服务器验证吧
    //* receipt :加密后的凭证字符串
    //* orderid :生成订单时服务器返回的订单id（不是苹果支付订单）
    //* productid :要购买的app 内购项目的产品id
    //* bundleid :加密后的凭证字符串
    NSLog(@"去服务端验证");
    [self verifyWithReceipt:@{@"receipt":encodeStr,@"orderid":transaction.payment.applicationUsername,@"productid":transaction.payment.productIdentifier,@"bundleid":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]} Transaction:transaction];
}
//去服务端验证
-(void)verifyWithReceipt:(NSDictionary *)dic Transaction:(SKPaymentTransaction *)transaction
{
  
    __weak __typeof(self)weakSelf = self;
    [_channel invokeMethod:@"ApplePaySuccess" arguments:dic result:^(id  _Nullable result) {
        if ([result intValue]==0) {//验证通过 或者后台订单错误 不再验证
            NSLog(@"验证完成");
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        }else{
             [weakSelf verifyWithReceipt:dic Transaction:transaction];
        }
    }];
}

@end
