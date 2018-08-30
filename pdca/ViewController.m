//
//  ViewController.m
//  pdca
//
//  Created by anjingxw@126.com on 2017/11/14.
//  Copyright © 2017年 glimlab. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import "MyRecordMp3View.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import "XMMovableView.h"
#import <Floaty/Floaty-Swift.h>

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate>
@property (nonatomic, strong) WKWebView* wkWebview;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIButton * testButton;
@property (nonatomic, weak)  MyRecordMp3View* recordMp3View;
@property (nonatomic,strong) WebViewJavascriptBridge * webViewBridge;
@property (nonatomic, strong) WVJBResponseCallback recordMp3callback;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    //[self setupUITest];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupUI{
    self.wkWebview = [[WKWebView alloc]initWithFrame:self.view.bounds];
    self.wkWebview.navigationDelegate = self;
    [self.view addSubview:self.wkWebview];
    self.wkWebview.UIDelegate = self;
    [_wkWebview setMultipleTouchEnabled:YES];
    [_wkWebview setAutoresizesSubviews:YES];
    [_wkWebview.scrollView setAlwaysBounceVertical:YES];
    // 这行代码可以是侧滑返回webView的上一级，而不是根控制器（*只针对侧滑有效）
    [_wkWebview setAllowsBackForwardNavigationGestures:true];
    
    [WebViewJavascriptBridge enableLogging];
    _webViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.wkWebview];
    [_webViewBridge setWebViewDelegate:self];
    [_webViewBridge registerHandler:@"recordMp3" handler:^(id data, WVJBResponseCallback responseCallback) {;
        if (_recordMp3callback != nil) {
            return;
        }
        _recordMp3callback = responseCallback;
        [self showRecordView];
    }];

    NSURL *url = [NSURL URLWithString:@"http://58.16.248.170:8088"];//
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.wkWebview  addObserver:self
                 forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                    options:0
                    context:nil];
    [self.wkWebview  loadRequest:request];
    //[self makefourbtn];
}

- (void)setupUITest{
    self.wkWebview = [[WKWebView alloc]initWithFrame:self.view.bounds];
    self.wkWebview.navigationDelegate = self;
    [self.view addSubview:self.wkWebview];

    self.wkWebview.UIDelegate = self;
    
    [WebViewJavascriptBridge enableLogging];
    _webViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.wkWebview];
    [_webViewBridge setWebViewDelegate:self];
    [_webViewBridge registerHandler:@"recordMp3" handler:^(id data, WVJBResponseCallback responseCallback) {;
        _recordMp3callback = responseCallback;
        [self showRecordView];
    }];

    NSURL *path = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    [self.wkWebview loadRequest:[NSURLRequest requestWithURL:path]];
    //[self makefourbtn];
    
    Floaty*  floaty = [[Floaty alloc] init];
    [floaty addItem:@"回退" icon:nil handler:^(FloatyItem * _Nonnull item) {
        if (self.wkWebview.canGoBack) {
            [self.wkWebview goBack];
        }
    }];
    [floaty addItem:@"刷新" icon:nil handler:^(FloatyItem * _Nonnull item) {
        [self.wkWebview reload];
    }];
    [self.view addSubview:floaty];
}



-(void)showRecordView{
    if (!_recordMp3View) {
        CGFloat x = (self.wkWebview.bounds.size.width -240)/2;
        CGFloat y = (self.wkWebview.bounds.size.height -380)/2-10;
        MyRecordMp3View * mp3Vie = [[MyRecordMp3View alloc] initWithFrame:CGRectMake(x, y, 240, 380)];
        self.recordMp3View = mp3Vie;
        mp3Vie.finish = ^(NSString *base64) {
            if(_recordMp3callback != nil){
                _recordMp3callback(base64);
                _recordMp3callback = nil;
            }
        };
        [self.view addSubview:self.recordMp3View];
    }
    self.recordMp3View.hidden = NO;
}

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidStartLoad");
    //开始加载的时候，让进度条显示
    self.progressView.hidden = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidFinishLoad");
}

//-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
//    //如果是跳转一个新页面
////    if (navigationAction.targetFrame == nil) {
////        [webView loadRequest:navigationAction.request];
////    }
//    decisionHandler(WKNavigationActionPolicyAllow);
//}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
}

//kvo 监听进度
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == self.wkWebview) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebview.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebview.estimatedProgress
                              animated:animated];
        
        if (self.wkWebview.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.progressView setAlpha:0.0f];
                             }
                             completion:^(BOOL finished) {
                                 [self.progressView setProgress:0.0f animated:NO];
                             }];
        }
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}
// 记得取消监听
- (void)dealloc {
    
    [self.wkWebview removeObserver:self  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

- (UIProgressView *)progressView{
    if(!_progressView){
        _progressView= [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame  = CGRectMake(0, 64, self.view.bounds.size.width, 5);
        [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255
                                                         green:240.0/255
                                                          blue:240.0/255
                                                         alpha:1.0]];
        _progressView.progressTintColor = [UIColor greenColor];
        [self.view addSubview:self.progressView];
    }
    return _progressView;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)makefourbtn{
    XMMovableView *view = [[XMMovableView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 82, self.view.bounds.size.height - 102, 82, 102)];
    view.backgroundColor = [UIColor grayColor];
    view.alpha = 0.5;
    view.layer.cornerRadius = 20;
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(1,1,80,40);
    [button setTitle:@"刷新" forState:UIControlStateNormal];
    [button setBackgroundImage:[MyRecordMp3View createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [button setBackgroundImage:[MyRecordMp3View createImageWithColor:[UIColor grayColor]] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ClicK:) forControlEvents:UIControlEventTouchDown];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 20;
    button.tag = 1;
    [view addSubview:button];
    UIButton * back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(1,61,80,40);
    [back setTitle:@"后退" forState:UIControlStateNormal];
    [back setBackgroundImage:[MyRecordMp3View createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [back setBackgroundImage:[MyRecordMp3View createImageWithColor:[UIColor grayColor]] forState:UIControlStateHighlighted];
    [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(ClicK:) forControlEvents:UIControlEventTouchDown];
    back.layer.masksToBounds = YES;
    back.layer.cornerRadius = 20;
    back.tag = 2;
    
    [view addSubview:button];
    [view addSubview:back];
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
}
-(void)ClicK:(UIButton *)Btn{
    switch (Btn.tag) {
        case 1:{
            [self.wkWebview reload];
        }
            break;
        case 2:{
            if (self.wkWebview.canGoBack) {
                [self.wkWebview goBack];
            }
        }
            break;
//        case 2:{
//            if (self.wkWebview.canGoForward) {
//                [self.wkWebview goForward];
//            }
//        }
//            break;
//        case 3:{
//            //进行跳转,我们设置跳转的返回到第一个界面
//            NSLog(@"%@",self.wkWebview.backForwardList.backList);
//            if (self.wkWebview.backForwardList.backList.count >2) {
//                [self.wkWebview goToBackForwardListItem:self.wkWebview.backForwardList.backList[0]];
//            }
//        }
            break;
        default:
            break;
    }
}

@end
