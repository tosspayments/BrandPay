BrandPay
https://tosspayments.com

<img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-333333.svg" alt="Supported Platforms: iOS"/>

[![Version](https://img.shields.io/cocoapods/v/BrandPay.svg?style=flat)](https://cocoapods.org/pods/BrandPay)
<!-- [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/tosspayments/ios-BrandPay) -->
<a href="https://github.com/apple/swift-package-manager" alt="RxSwift on Swift Package Manager" title="RxSwift on Swift Package Manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>

# 브랜드페이 iOS SDK 
브랜드페이 iOS SDK를 추가하고 메서드를 사용하는 방법을 알아봅니다.

## 지원
- Xcode 12.x
- Swift 5.x
- iOS 11.0

## SDK 추가
브랜드페이 iOS SDK는 Manual, Cocoapods, Swift Package Manager르 지원합니다.

### XCFreameworks
아래와 같이 프레임워크를 제공하고 있습니다.
```
# Base
Library/BrandPayBase.xcframework

# 생체인증 지원
Library/BiometricInterface.xcframework

# 카드 OCR 지원
Library/FinCubeOcrSDK.xcframework
Library/OCRInterface.xcframework
```

필요한 프레임워크를 `Target` 의 `General` 탭 아래에 있는 `Frameworks, Libraries, and Embedded Content` 섹션으로 끌어오기만 하면 됩니다.

<img width="658" alt="스크린샷 2022-02-16 오전 11 28 47" src="https://user-images.githubusercontent.com/10410095/154185013-c6e3f7b5-0b44-47ed-81ea-a63886496afd.png">

### Cocoapods
브랜드페이 iOS SDK는 Cocoapods 패키지로도 제공됩니다. 
```
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    # 생체인증 지원
    pod 'BrandPay/Biometric'
    # 카드 OCR 지원
    pod 'BrandPay/OCR'
end
```
`YOUR_TARGET_NAME`을 적절하게 변경한 후 `Podfile` 파일이 있는 디렉토리에서 아래 명령어를 실행하세요.
```
pod install
```

### Swift Package Manager

https://github.com/tosspayments/BrandPay

## 권한 설정
BrandPay iOS SDK느 카메라 권한과 생체인증 권한 설정ㅇ 필요합니다.

## Web ↔ App간 Message 처리를 위한 설정
```
extension BrandPayWebInterface: WebViewControllerType {

    // var webView: WKWebView! // 선언되어있는 WKWebView instance를 사용합닏.
    
    // 
    func installAppBridges() {
        let biometricMessageHandler = WebScriptMessageHandler()
        biometricMessageHandler.controller = self
        
        biometricMessageHandler.register(appBridge: GetAppInfoAppBridge())
        biometricMessageHandler.register(appBridge: HasBiometricAuthAppBridge())
        biometricMessageHandler.register(appBridge: GetBiometricAuthMethodsAppBridge())
        biometricMessageHandler.register(appBridge: VerifyBiometricAuthAppBridge())
        biometricMessageHandler.register(appBridge: RegisterBiometricAuthAppBridge())
        biometricMessageHandler.register(appBridge: UnregisterBiometricAuthAppBridge())
        webView.configuration.userContentController.add(biometricMessageHandler, name: "ConnectPayAuth")
        
        // * OCR 기능은 앱 패키지 별로 flk license file 로 관리됩니다. 
        let ocrMessageHandler = WebScriptMessageHandler()
        ocrMessageHandler.controller = self
        
        ocrMessageHandler.register(appBridge: ScanOCRCardAppBridge(licenseKeyFile: "tosspayment_20220513.flk"))
        ocrMessageHandler.register(appBridge: IsOCRAvailableAppBridge())
        webView.configuration.userContentController.add(ocrMessageHandler, name: "ConnectPayOcr")        
    }
    
    // Javascript 호출을 해야 Message 처리가 가능합니다.
    func evaluateJavaScriptSafely(javaScriptString: String) {
        webView.evaluateJavaScript(javaScriptString) { (_, _) in
            
        }
    }
}
```
