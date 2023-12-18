//
//  ViewController.m
//  BrandPayObjcExample
//
//  Created by 김진규 on 2023/12/13.
//  Copyright © 2023 com.tosspayments. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <BrandPayBase/BrandPayBase-Swift.h>
#import <OCRInterface/OCRInterface-Swift.h>
#import <BiometricInterface/BiometricInterface-Swift.h>

@interface ViewController () <WKNavigationDelegate, WebViewControllerType>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController

static NSString * const latestURL = @"LatestURL";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupWebView];
    [self setupRightBarButton];
    
    [self installAppBridges];
}

- (void)setupWebView {
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_webView];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [_webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
    
    _webView.navigationDelegate = self;
#if DEBUG && __IPHONE_OS_VERSION_MAX_ALLOWED >= 160400
    [_webView setInspectable:true];
#endif
    
    NSString *urlString = [[NSUserDefaults standardUserDefaults] stringForKey:latestURL] ?: @"https://tosspayments.com";
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)setupRightBarButton {
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                          target:self
                                                                          action:@selector(didTapRightBarButton:)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)didTapRightBarButton:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Test URL을 입력하세요."
                                                                             message:@"클립보드의 내용이 URL일 경우 자동으로 붙여 넣습니다."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSString *pasteBoardString = [UIPasteboard generalPasteboard].string;
        if (pasteBoardString && ![pasteBoardString isEqualToString:@""] && [NSURL URLWithString:pasteBoardString]) {
            textField.text = pasteBoardString;
        }
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"취소"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          UITextField *urlTextField = alertController.textFields.firstObject;
                                                          NSString *urlString = urlTextField.text;
                                                          NSURL *url = [NSURL URLWithString:urlString];
                                                          if (url) {
                                                              [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:latestURL];
                                                              [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:url]];
                                                          }
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self showAlert:error.localizedDescription];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self showAlert:error.localizedDescription];
}

- (void)showAlert:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"로드 실패"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)installAppBridges {
    WebScriptMessageHandler* messageHandler = [[WebScriptMessageHandler alloc] init];
    [messageHandler setController:self];
    
    [messageHandler registerWithAppBridge:[[GetAppInfoAppBridge alloc] init]];
    [messageHandler registerWithAppBridge:[[HasBiometricAuthAppBridge alloc] init]];
    [messageHandler registerWithAppBridge:[[GetBiometricAuthMethodsAppBridge alloc] init]];
    [messageHandler registerWithAppBridge:[[VerifyBiometricAuthAppBridge alloc] init]];
    [messageHandler registerWithAppBridge:[[RegisterBiometricAuthAppBridge alloc] init]];
    [messageHandler registerWithAppBridge:[[UnregisterBiometricAuthAppBridge alloc] init]];
    [_webView.configuration.userContentController addScriptMessageHandler:messageHandler name:@"ConnectPayAuth"];
    
//    * OCR 기능은 앱 패키지 별로 flk license file 로 관리됩니다.
    [messageHandler registerWithAppBridge:[[ScanOCRCardAppBridge alloc] initWithLicenseKeyFile:@"tosspayment_20220513.flk"]];
    [messageHandler registerWithAppBridge:[[IsOCRAvailableAppBridge alloc] init]];
    [_webView.configuration.userContentController addScriptMessageHandler:messageHandler name:@"ConnectPayOcr"];
    
    
    [_webView.configuration.userContentController addScriptMessageHandler:messageHandler name:@"connectWebViewAction"];
}

- (void)evaluateJavaScriptSafelyWithJavaScriptString:(NSString * _Nonnull)javaScriptString {
    [_webView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}

@end
