BrandPay
https://tosspayments.com

<img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-333333.svg" alt="Supported Platforms: iOS"/>

[![Version](https://img.shields.io/cocoapods/v/BrandPay.svg?style=flat)](https://cocoapods.org/pods/BrandPay)
<!-- [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/tosspayments/ios-BrandPay) -->
<a href="https://github.com/apple/swift-package-manager" alt="RxSwift on Swift Package Manager" title="RxSwift on Swift Package Manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>

# 브랜드페이 iOS SDK 
브랜드페이 iOS SDK를 추가하고 메서드를 사용하는 방법을 알아봅니다.

> ⚠️ **[Deprecated] Card OCR (2026-06-09)**
> 앱 카드 OCR(`FinCubeOcrSDK`, `OCRInterface`, `BrandPay/OCR`)은 Web OCR 로 옮겨야 합니다.
> 앱 OCR 은 아직 동작하지만 더 이상 권장하지 않습니다.
> 옮기는 방법: [OCR SDK 에서 Web OCR 로 옮기기](#ocr-sdk-에서-web-ocr-로-옮기기)
> OCR 관련 문의: [토스페이먼츠 개발자 커뮤니티](https://developers.tosspayments.com/go/techchat)

## 지원
- Xcode 12.x
- Swift 5.x
- iOS 11.0

## SDK 추가
브랜드페이 iOS SDK는 Manual, Cocoapods, Swift Package Manager를 지원합니다.

### XCFreameworks
아래와 같이 프레임워크를 제공하고 있습니다.
```
# Base
Library/BrandPayBase.xcframework

# 생체인증 지원
Library/BiometricInterface.xcframework

# 카드 OCR 지원 (Deprecated, 2026-06-09)
Library/FinCubeOcrSDK.xcframework
Library/OCRInterface.xcframework
```

필요한 프레임워크를 `Target` 의 `General` 탭 아래에 있는 `Frameworks, Libraries, and Embedded Content` 섹션으로 끌어오기만 하면 됩니다.

<img width="658" alt="스크린샷 2022-02-16 오전 11 28 47" src="https://user-images.githubusercontent.com/10410095/154185013-c6e3f7b5-0b44-47ed-81ea-a63886496afd.png">

### Cocoapods
브랜드페이 iOS SDK는 Cocoapods 패키지로도 제공됩니다. 

> CocoaPods trunk 가 2026-12-02 부터 읽기 전용이라 CocoaPods 로는 1.4.0 까지만 제공합니다. 이후 버전은 Swift Package Manager 로 설치하세요. ([CocoaPods 공지](https://blog.cocoapods.org/CocoaPods-Specs-Repo/))

```
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    # 생체인증 지원
    pod 'BrandPay/Biometric'
    # 카드 OCR 지원 (Deprecated, 2026-06-09)
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
BrandPay iOS SDK는 카메라 권한과 생체인증 권한 설정이 필요합니다.

## Web ↔ App간 Message 처리를 위한 설정
```
extension BrandPayWebInterface: WebViewControllerType {

    // var webView: WKWebView! // 선언되어있는 WKWebView instance를 사용합니다.
    
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
        
        // * [Deprecated, 2026-06-09] OCR 기능은 WebOCR 도입으로 deprecated 되었습니다.
        // * 기존 OCR은 앱 패키지 별로 flk license file 로 관리됩니다. 
        let ocrMessageHandler = WebScriptMessageHandler()
        ocrMessageHandler.controller = self
        
        ocrMessageHandler.register(appBridge: ScanOCRCardAppBridge(licenseKeyFile: "tosspayment_20220513.flk"))
        ocrMessageHandler.register(appBridge: IsOCRAvailableAppBridge())
        webView.configuration.userContentController.add(ocrMessageHandler, name: "ConnectPayOcr")        
    }
    
    // WebViewControllerType 이 요구해 구현은 남깁니다. 1.4.0 부터 SDK 브리지 응답은 이 함수를 거치지 않고 메시지를 보낸 WebView 에서 실행됩니다.
    func evaluateJavaScriptSafely(javaScriptString: String) {
        webView.evaluateJavaScript(javaScriptString) { (_, _) in
            
        }
    }
    
    // SDK 내부에서 발생하는 에러를 받을 수 있는 콜백입니다. 
    func onErrorOccurred(_ error: NSError) {
        // 1. NSError → BrandpayBiometricAuthError 변환
        guard let biometricAuthError = BrandpayBiometricAuthError.from(error) else {
            return
        }
        
        // 2. 확인할 수 있는 정보
        let message   = biometricAuthError.errorDescription    // 에러 메시지
        let traceId   = biometricAuthError.traceId             // 추적용 ID
        let underlying = biometricAuthError.underlyingError     // 발생한 원본 내부 에러
        
        // 3. 에러 타입별 분기 처리
        switch biometricAuthError {
            
        case .secureStorageInitFailed:
            // 내부 보안 저장소 초기화 실패
            
        case .secureStorageOpFailed:
            // 보안 저장소 읽기/쓰기 실패
            
        case .cryptoFailed:
            // 암호화/복호화 실패
            
        case .biometricAPIFailed:
            // 시스템 생체인증 API 호출 실패
        }
    }
}
```

### OCR 라이선스 파일
앱 OCR 라이선스 파일(.flk)은 앱 번들 ID 별로 발급되므로 다른 앱의 파일은 쓸 수 없습니다. 저장소에도 넣지 않습니다.

```
1. 자기 앱 번들 ID 로 발급받은 라이선스 파일을 앱 타깃의 Copy Bundle Resources 에 넣는다
2. 그 파일 이름을 ScanOCRCardAppBridge(licenseKeyFile:) 에 넘긴다
```

예제는 파일 이름을 `BrandPayWebExample/ViewController.swift` 와 `BrandPayObjcExample/ViewController.m` 의 `ScanOCRCardAppBridge` 등록 줄에서 넘깁니다. 예제 저장소에는 라이선스 파일이 없고 `.gitignore` 가 `*.flk` 를 무시합니다. 예제에서 OCR 을 쓰려면 발급받은 파일을 `Example/Cocoapod_UIKit/BrandPayWebExample/Assets/` 에 두고 등록 줄의 파일 이름을 그 이름으로 바꿉니다. 빌드 단계 Copy Local OCR License 가 이 폴더의 .flk 를 앱 번들에 넣고, 파일이 없으면 OCR 없이 빌드됩니다.

앱 OCR 은 deprecated 입니다. 새로 붙이기보다 [OCR SDK 에서 Web OCR 로 옮기기](#ocr-sdk-에서-web-ocr-로-옮기기)를 따릅니다.

## 1.4.0 보안 변경 안내
1.4.0 부터 브리지 동작 조건과 생체 인증 토큰 저장 방식이 바뀝니다. CocoaPods 는 1.4.0 까지 제공하고, 그 뒤 버전은 Swift Package Manager 나 XCFrameworks 로 받으세요.

### 브리지 동작 조건
브리지(`ConnectPayAuth`, `ConnectPayOcr`)는 같은 출처를 강제합니다. https 는 기본으로 경고만 남기고, 앱이 `allowedOriginRules` 를 넘기면 강제합니다.

```
적용 버전: 1.4.0 이상

모든 앱에 강제 (같은 출처)
- 브리지를 부른 프레임의 출처(scheme, host, port)가 WebView 최상위 문서의 출처와 같다
- 최상위 문서가 다른 주소로 탐색하는 동안에는 프레임의 출처가 지금 떠 있는 문서의 출처와도 같다
- about:blank, srcdoc iframe 과 about:blank 최상위 문서(팝업 등)는 물려받은 출처로 비교한다
- 포트를 생략한 주소와 기본 포트(https 443, http 80)를 적은 주소는 같은 출처다

https 는 기본으로 강제하지 않는다 (경고)
- https 가 아닌 최상위 문서(http, 루프백 http, capacitor:// 같은 앱 스킴)에서도 동작한다
- 이때 Xcode 콘솔에 https 경고를 남긴다. 같은 최상위 문서 출처에서는 한 번만 남긴다

https 선택 강제 (allowedOriginRules)
- 앱이 WebScriptMessageHandler(allowedOriginRules:) 로 규칙을 넘기면 최상위 문서 출처가 규칙 중 하나와 맞아야 한다
- 규칙은 https 만 받으므로 https 가 아닌 최상위 문서는 거부된다

거부
- 최상위 문서와 출처가 다른 iframe
- 최상위 문서 출처를 알 수 없는 메시지(file 페이지, about:blank 최상위 문서 안의 iframe 등)
- allowedOriginRules 를 넘긴 앱에서 최상위 문서 출처가 규칙에 없는 메시지
```

- 결제 SDK 를 띄우는 가맹점 페이지는 https 로 여는 것을 권장합니다.
- 브리지를 쓰는 화면을 iframe 에 넣으면 그 iframe 을 최상위 문서와 같은 출처로 둡니다.
- 브리지 등록 코드와 웹에서 부르는 방식은 바뀌지 않습니다. `allowedOriginRules` 는 선택입니다.
- 거부된 호출의 웹 응답은 아래와 같습니다.

```
- 브리지를 부른 프레임이 최상위 문서와 같은 출처(scheme, host, port)면 기존 onError 로 응답한다
  allowedOriginRules 위반:
    생체 인증: {"code": "BIOMETRIC_FAILED", "message": "BrandPay 브리지는 WebView 최상위 문서와 같은 출처의 프레임에서만 동작합니다. 앱이 넘긴 허용 출처(allowedOriginRules)에 이 페이지의 출처가 있는지 확인하세요."}
    카드 스캔: {"code": "OCR_FAILED", "message": "BrandPay 브리지는 WebView 최상위 문서와 같은 출처의 프레임에서만 동작합니다. 앱이 넘긴 허용 출처(allowedOriginRules)에 이 페이지의 출처가 있는지 확인하세요."}
  그 밖의 거부(file 페이지 등):
    생체 인증: {"code": "BIOMETRIC_FAILED", "message": "BrandPay 브리지는 WebView 최상위 문서와 같은 출처의 프레임에서만 동작합니다."}
    카드 스캔: {"code": "OCR_FAILED", "message": "BrandPay 브리지는 WebView 최상위 문서와 같은 출처의 프레임에서만 동작합니다."}
- 최상위 문서와 출처가 다른 iframe 에는 응답하지 않는다. Xcode 콘솔 문구만 남는다
```

### 허용 출처 규칙 (allowedOriginRules)
https 를 강제하려면 `WebScriptMessageHandler` 를 만들 때 허용 출처를 넘깁니다. 브리지를 붙인 핸들러마다 넘깁니다.

```
적용 버전: 1.4.0 이상
Swift:       public convenience init(allowedOriginRules: Set<String>) throws
Objective-C: initWithAllowedOriginRules:error:

규칙 문법
https://host           host 가 정확히 같고 port 가 443
https://host:port      host 가 정확히 같고 port 가 같다
https://*.host         host 의 하위 도메인만(host 자체는 아님), port 가 443
https://*.host:port    host 의 하위 도메인만, port 가 같다

- https 만 받는다. path, query, 끝의 / 는 넣지 않는다
- 대소문자를 구분하지 않는다
- 같은 출처 조건은 규칙과 별개로 그대로 적용된다
- 규칙이 비었거나 형식이 틀리면 생성자가 아래 오류를 던진다
  allowedOriginRules 가 비어 있습니다.
  allowedOriginRules 는 https://host[:port] 또는 https://*.host[:port] 형식이어야 합니다: <규칙>
```

```swift
func installAppBridges() throws {
    // example.com 과 그 하위 도메인(443 포트)에서만 브리지가 동작합니다.
    let allowedOriginRules: Set<String> = [
        "https://example.com",
        "https://*.example.com",
    ]

    let biometricMessageHandler = try WebScriptMessageHandler(allowedOriginRules: allowedOriginRules)
    biometricMessageHandler.controller = self
    // register(appBridge:) 와 userContentController.add 는 위 설정 예시와 같습니다.

    let ocrMessageHandler = try WebScriptMessageHandler(allowedOriginRules: allowedOriginRules)
    ocrMessageHandler.controller = self
    // register(appBridge:) 와 userContentController.add 는 위 설정 예시와 같습니다.
}
```

`allowedOriginRules` 는 https 출처만 받습니다. 앱 스킴(`capacitor://` 등)이나 루프백 http(`127.0.0.1`, `localhost`) 페이지를 쓰는 앱이 규칙을 넘기면 브리지가 모두 거부됩니다. 이런 앱은 규칙을 넘기지 않고 `WKNavigationDelegate` 로 외부 이동을 막습니다([WebView 탐색 제한](#webview-탐색-제한)).

`allowedOriginRules` 를 넘기지 않으면 브리지는 최상위 문서의 출처를 가리지 않습니다. WebView 가 어느 페이지로 이동하든, 그 페이지와 같은 출처의 프레임이 부르면 브리지가 동작합니다. 운영 환경에서는 아래 둘 중 하나를 적용합니다.

- `allowedOriginRules` 로 가맹점 페이지의 출처를 넘깁니다.
- [WebView 탐색 제한](#webview-탐색-제한)으로 가맹점 페이지 밖으로의 이동을 막습니다.

팝업(`window.open`)으로 만든 WKWebView 도 같은 configuration 을 쓰면 브리지가 붙습니다. 팝업에는 브랜드페이 화면이나 카드사 인증이 열리므로 [WebView 탐색 제한](#webview-탐색-제한)의 가맹점 출처 검사를 걸지 않고, http, https 가 아닌 스킴만 앱으로 넘깁니다. `allowedOriginRules` 를 넘긴 앱에서는 팝업 안의 브리지 호출이 거부됩니다.

### 생체 인증 재등록
```
적용 버전: 1.4.0 이상

- 기기의 생체 정보를 바꾸면(지문 추가나 삭제, 얼굴 추가나 삭제) 저장된 생체 인증 토큰이 무효가 된다
- 토큰이 무효가 되면 생체 인증이 실패하고, 고객이 생체 인증을 다시 등록해야 한다
```

- 1.3.2 이하에서 등록한 토큰은 1.4.0 에서 처음 생체 인증에 성공할 때 새 저장 방식으로 옮겨집니다. 이때는 다시 등록하지 않아도 됩니다.

### WebView 탐색 제한
브리지를 붙인 WebView 는 가맹점이 정한 자기 페이지 출처만 엽니다. 그 밖의 주소는 `decidePolicyFor` 에서 `.cancel` 하고 외부 브라우저(`UIApplication.shared.open`)에 넘깁니다. `allowedOriginRules` 에 같은 출처를 넣습니다. SDK 버전과 관계없이 적용합니다. [허용 출처 규칙](#허용-출처-규칙-allowedoriginrules) 을 함께 보세요.

브랜드페이 화면 도메인은 허용 목록에 넣지 않습니다. 브리지는 가맹점 페이지의 결제 SDK 가 부르고, 브랜드페이 화면은 iframe 이나 팝업 안에서 열려 브리지를 직접 부르지 않습니다.

```
- allowedOrigins 에는 결제 SDK 를 띄우는 가맹점 페이지의 출처를 "scheme://host[:port]" 로 넣는다. 기본 포트(https 443, http 80)와 path 는 넣지 않는다
- allowedOrigins 에 있는 출처는 WebView 에서 연다
- 그 밖의 http, https 가 아닌 스킴(카드사 앱, 은행 앱)은 막지 않고 UIApplication.shared.open 으로 앱에 넘긴다. WebView 안에서 쓰는 about, data, blob 은 넘기지 않는다
- iframe 안의 탐색(브랜드페이 화면, 카드사 인증)은 이 검사에서 제외한다
- 메인 프레임에서 allowedOrigins 밖의 http, https 주소는 decisionHandler(.cancel) 하고 UIApplication.shared.open 으로 외부 브라우저에 넘긴다
- 메인 프레임의 그 밖의 주소(about, data, blob)는 decisionHandler(.cancel) 로 막는다
- 1.4.0 부터 같은 출처를 allowedOriginRules 로도 넘긴다
```

가맹점 페이지를 앱 스킴(예: `capacitor://`)이나 루프백 http(`127.0.0.1`, `localhost`)로 띄우는 앱은 그 출처를 `allowedOrigins` 에만 넣고 `allowedOriginRules` 는 넘기지 않습니다. `allowedOriginRules` 는 https 출처만 받기 때문입니다. 이런 앱은 이 제한으로 브리지가 열리는 페이지를 가맹점 페이지로 좁힙니다.

```swift
final class PaymentViewController: UIViewController, WKNavigationDelegate {

    // var webView: WKWebView! // 브리지를 붙인 WKWebView instance를 사용합니다.

    // 결제 SDK 를 띄우는 가맹점 페이지의 출처를 "scheme://host[:port]" 로 넣습니다. 기본 포트는 적지 않습니다.
    private let allowedOrigins: Set<String> = [
        "https://shop.example.com",
        // "capacitor://localhost", "http://localhost:8080" // 이 주소로 가맹점 페이지를 띄우는 앱만 넣고, allowedOriginRules 는 넘기지 않습니다.
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: "https://shop.example.com/order")!))
    }

    func installAppBridges() throws {
        // 1.4.0 부터 브리지에도 같은 출처를 넘깁니다. register(appBridge:) 와 userContentController.add 는 위 설정 예시와 같습니다.
        let biometricMessageHandler = try WebScriptMessageHandler(allowedOriginRules: allowedOrigins)
        let ocrMessageHandler = try WebScriptMessageHandler(allowedOriginRules: allowedOrigins)
    }

    // "scheme://host[:port]" 를 만듭니다. 기본 포트는 적지 않습니다.
    private func origin(of url: URL) -> String? {
        guard let scheme = url.scheme?.lowercased(), let host = url.host?.lowercased() else {
            return nil
        }
        let defaultPorts = ["https": 443, "http": 80]
        if let port = url.port, port != defaultPorts[scheme] {
            return "\(scheme)://\(host):\(port)"
        }
        return "\(scheme)://\(host)"
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url,
              let scheme = url.scheme?.lowercased() else {
            decisionHandler(.cancel)
            return
        }

        // allowedOrigins 에 있는 출처는 WebView 에서 엽니다.
        if let origin = origin(of: url), allowedOrigins.contains(origin) {
            decisionHandler(.allow)
            return
        }

        // 그 밖의 카드사 앱, 은행 앱 같은 http, https 가 아닌 스킴은 막지 않고 앱으로 넘깁니다.
        // about, data, blob 은 WebView 안에서 쓰는 주소라 넘기지 않습니다(iframe 의 about:blank 등).
        let webViewSchemes: Set<String> = ["http", "https", "about", "data", "blob"]
        if !webViewSchemes.contains(scheme) {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        // iframe 안의 탐색(브랜드페이 화면, 카드사 인증)은 이 검사에서 제외합니다.
        if let frame = navigationAction.targetFrame, !frame.isMainFrame {
            decisionHandler(.allow)
            return
        }

        // 메인 프레임에서 allowedOrigins 밖의 http, https 주소는 외부 브라우저에 넘깁니다.
        if scheme == "http" || scheme == "https" {
            UIApplication.shared.open(url)
        }
        decisionHandler(.cancel)
    }
}
```

### 증상과 해결
브리지가 메시지를 거부하면 Xcode 콘솔에 아래 문구가 나옵니다. 앞 문장은 고정이고, 뒤에 거부 사유와 두 출처가 붙습니다. 최상위 문서 출처를 알 수 없으면 `없음` 이 들어갑니다.

```
BrandPay 브리지는 WebView 최상위 문서와 같은 출처의 프레임에서만 동작합니다. 거부 사유: <사유>, 최상위 문서 출처: <scheme>://<host>[:<port>], 프레임 출처: <protocol>://<host>[:<port>]
```

`allowedOriginRules` 위반으로 거부하면 고정 문장 뒤에 확인 안내가 붙습니다.

```
BrandPay 브리지는 WebView 최상위 문서와 같은 출처의 프레임에서만 동작합니다. 앱이 넘긴 허용 출처(allowedOriginRules)에 이 페이지의 출처가 있는지 확인하세요. 거부 사유: top origin not in allowedOriginRules, 최상위 문서 출처: <scheme>://<host>[:<port>], 프레임 출처: <protocol>://<host>[:<port>]
```

https 가 아닌 최상위 문서에서 동작하면 아래 경고가 나옵니다. 브리지는 동작합니다.

```
BrandPay 브리지가 https 가 아닌 페이지에서 동작하고 있습니다. https 로 옮기세요. 최상위 문서 출처: <scheme>://<host>[:<port>]
```

| 거부 사유 | 뜻 | 해결 |
|---|---|---|
| `top url missing` | 최상위 문서 주소나 host 가 없습니다. file 페이지, about:blank 최상위 문서 안의 iframe 이 여기에 해당합니다. | 페이지를 host 가 있는 주소(https 권장)로 엽니다. |
| `frame scheme differs from top url` | 브리지를 부른 프레임의 scheme 이 최상위 문서와 다릅니다(https 페이지 안의 http iframe 등). | 브리지를 쓰는 화면을 최상위 문서와 같은 scheme 으로 둡니다. |
| `frame host differs from top url` | 브리지를 부른 프레임의 host 가 최상위 문서와 다릅니다. | 브리지를 쓰는 화면을 최상위 문서와 같은 host 로 둡니다. |
| `frame port differs from top url` | 브리지를 부른 프레임의 port 가 최상위 문서와 다릅니다. | 브리지를 쓰는 화면을 최상위 문서와 같은 port 로 둡니다. |
| `frame origin differs from committed document` | 최상위 문서가 다른 주소로 탐색하는 동안, 지금 떠 있는 문서와 출처가 다른 iframe 이 브리지를 불렀습니다. | 브리지를 쓰는 iframe 을 최상위 문서와 같은 출처로 두고, 탐색이 끝난 뒤 부릅니다. |
| `top origin not in allowedOriginRules` | 최상위 문서 출처가 앱이 넘긴 `allowedOriginRules` 의 어느 규칙과도 맞지 않습니다. https 가 아닌 페이지도 여기에 해당합니다. | 페이지 출처를 규칙에 넣거나, 규칙에 있는 https 출처로 페이지를 엽니다. |

| 증상 | Xcode 콘솔 문구 | 해결 |
|---|---|---|
| 생체 인증이나 카드 스캔이 동작하지 않음 | 거부 문구 | 거부 사유 표를 따릅니다. 브리지를 쓰는 화면을 WebView 최상위 문서와 같은 출처(scheme, host, port)로 둡니다. |
| `allowedOriginRules` 를 넘긴 뒤 생체 인증이나 카드 스캔이 동작하지 않음 | 허용 출처 확인 안내가 붙은 거부 문구 | 최상위 문서 출처를 규칙에 넣습니다. 페이지가 https 인지 확인합니다. |
| `WebScriptMessageHandler(allowedOriginRules:)` 가 오류를 던짐 | 없음 | 규칙을 `https://host[:port]`, `https://*.host[:port]` 형식으로 고칩니다. 빈 집합은 넘기지 않습니다. |
| Xcode 콘솔에 https 경고가 나옴 | https 경고 문구 | 브리지는 동작합니다. 페이지를 https 로 옮깁니다. |
| 생체 정보를 바꾼 뒤 생체 인증이 실패함 | 없음 | 고객이 생체 인증을 다시 등록합니다. |
| 가맹점 페이지가 WebView 가 아니라 외부 브라우저에서 열림 | 없음 | 그 페이지의 `scheme://host[:port]` 를 `allowedOrigins` 에 넣고, https 페이지면 `allowedOriginRules` 에도 넣습니다. |

## OCR SDK 에서 Web OCR 로 옮기기

1. 앱 카드 OCR 은 Web OCR 로 옮겨야 합니다. 지금 SDK 는 앱 OCR 을 계속 동작시키지만 더 이상 권장하지 않습니다.
2. 왜 옮기나: Web OCR 은 앱에 OCR 엔진을 넣지 않아 앱 크기가 줄고(iOS 앱 OCR 엔진 기준 약 8MB: FinCubeOcrSDK arm64 실행 코드 6.0MB(bitcode 제외), 가중치 1.9MB, OCRInterface 0.2MB — 앱 빌드로 잰 값이 아니라 라이브러리 파일 기준 추정), OCR 엔진 갱신을 앱 배포 없이 받습니다.
3. 무엇이 필요하나: 앱 OCR 과 Web OCR 모두 사용 계약(라이선스)이 필요합니다. Web OCR 은 담당 매니저나 [토스페이먼츠 개발자 커뮤니티](https://developers.tosspayments.com/go/techchat)로 문의해 사용을 연 뒤 옮깁니다.

### Web OCR 이 뜨는 조건

결제 화면의 카드 등록에서 아래가 모두 맞을 때 Web OCR 이 뜹니다.

- 앱이 OCR 브리지(`window.webkit.messageHandlers.ConnectPayOcr`)를 붙이지 않았습니다. 브리지가 있고 기기에 카메라가 있으면 결제 화면은 앱 카드 스캔을 먼저 씁니다.
- 가맹점 페이지가 JS SDK 를 띄울 때 `features.cardOCR.active` 를 `true` 로 넘겼습니다. 기본값은 `false` 입니다. 결제위젯은 `brandpay.features.cardOCR.active` 입니다.
- 가맹점이 Web OCR 사용 계약을 마쳐 토스페이먼츠가 사용을 열었습니다. Web OCR 은 라이선스 계약이 필요한 기능이라 가맹점이 직접 켤 수는 없습니다.

브리지가 없는데 나머지 조건이 맞지 않으면 스캔이 없는 기본 카드 입력 화면이 뜹니다. 카드 추가와 결제는 그대로 됩니다. 옛 이름 `connectPayWebViewAction` 만 붙인 앱은 3초 기다린 뒤 브리지가 없는 것으로 봅니다.

### 옮기는 순서

1. 가맹점 페이지에서 JS SDK 옵션 `features.cardOCR.active` 를 `true` 로 켭니다. `autoStart: true` 를 함께 넘기면 카드 등록 화면이 열리자마자 스캔을 시작합니다.
2. Web OCR 사용은 계약이 필요하니 담당 매니저나 [토스페이먼츠 개발자 커뮤니티](https://developers.tosspayments.com/go/techchat)로 문의합니다. 문의할 때 쓸 클라이언트 키(`test_ck_`, `live_ck_` 로 시작)를 알려 주고, 시크릿 키는 적지 않습니다. 사용이 확정된 뒤 다음 단계로 갑니다.
3. 테스트 앱에서 아래 [지울 것](#지울-것)의 필수 항목(OCR 브리지 등록)을 지우고, [카메라 권한](#카메라-권한)을 확인한 빌드로 카드 등록 화면에 Web OCR 이 뜨는지 확인합니다.
4. 배포합니다.

1, 2 가 끝나기 전에 OCR 브리지 등록을 먼저 지우면 스캔이 없는 기본 카드 입력 화면이 뜹니다. 카드 추가와 결제는 그대로 됩니다.

```js
// 1. 브랜드페이 JS SDK v1
const brandpay = BrandPay(clientKey, customerKey, {
  redirectUrl,
  features: { cardOCR: { active: true } }, // autoStart: true 를 더하면 화면이 열리자마자 스캔합니다.
});

// 1. 토스페이먼츠 JS SDK v2 브랜드페이
const brandpayV2 = TossPayments(clientKey).brandpay({
  customerKey,
  redirectUrl,
  features: { cardOCR: { active: true } },
});

// 1. 결제위젯
const widgets = TossPayments(clientKey).widgets({
  customerKey,
  brandpay: { redirectUrl, features: { cardOCR: { active: true } } },
});
```

### 지울 것

#### 필수: OCR 브리지 등록

OCR 브리지가 붙어 있으면 결제 화면이 `ConnectPayOcr` 핸들러를 보고 앱 카드 스캔을 쓰므로 Web OCR 이 뜨지 않습니다. 아래를 지웁니다. 생체 인증(`ConnectPayAuth`)은 그대로 둡니다.

- `ConnectPayOcr` 핸들러 등록(`userContentController.add(..., name: "ConnectPayOcr")`)
- `ScanOCRCardAppBridge` 와 `IsOCRAvailableAppBridge` 등록
- 앱이 `connectPayWebViewAction` 이름으로도 붙였다면 그 등록
- 더는 쓰지 않는 `import OCRInterface`

```swift
import WebKit
import BrandPayBase
import BiometricInterface
// import OCRInterface  // 지웁니다.

func installAppBridges() {
    let biometricMessageHandler = WebScriptMessageHandler()
    biometricMessageHandler.controller = self
    // 생체 인증 브리지 등록과 userContentController.add(..., name: "ConnectPayAuth") 는 그대로 둡니다.

    // 아래 OCR 등록을 모두 지웁니다.
    // let ocrMessageHandler = WebScriptMessageHandler()
    // ocrMessageHandler.controller = self
    // ocrMessageHandler.register(appBridge: ScanOCRCardAppBridge(licenseKeyFile: "<라이선스 파일>.flk"))
    // ocrMessageHandler.register(appBridge: IsOCRAvailableAppBridge())
    // webView.configuration.userContentController.add(ocrMessageHandler, name: "ConnectPayOcr")
    // webView.configuration.userContentController.add(ocrMessageHandler, name: "connectPayWebViewAction") // 옛 이름을 쓰는 앱
}
```

Objective-C 앱은 `#import <OCRInterface/OCRInterface-Swift.h>`, `ScanOCRCardAppBridge`, `IsOCRAvailableAppBridge` 등록과 `addScriptMessageHandler:... name:@"ConnectPayOcr"` 를 지웁니다.

#### 선택: 라이브러리와 라이선스 파일 정리

아래는 남겨도 Web OCR 동작에는 영향이 없습니다. 지우면 앱 크기가 줄고, 공개되는 앱 안에 OCR 라이선스 파일이 남지 않습니다. 위의 필수 항목을 먼저 지운 뒤에 지웁니다.

```
- OCRInterface, FinCubeOcrSDK: OCRInterface.xcframework, FinCubeOcrSDK.xcframework 를 Frameworks, Libraries, and Embedded Content 에서 지운다
- CocoaPods: Podfile 에서 pod 'BrandPay/OCR' 를 지우고 pod install 한다. pod 'BrandPay/Biometric' 은 둔다
- Swift Package Manager: BrandPayOCR 제품을 지운다. BrandPayWeb 은 OCR 타깃이 묶여 있으므로 BrandPayBiometric 으로 바꾼다
- 라이선스 파일(.flk): 타깃의 Copy Bundle Resources 와 프로젝트에서 지운다
```

지울 때도 카메라 권한 `NSCameraUsageDescription` 은 Info.plist 에 그대로 둡니다(아래 [카메라 권한](#카메라-권한)).

지운 뒤에도 빌드는 그대로 됩니다. 카드 등록 화면은 조건이 맞으면 Web OCR 을, 아니면 스캔이 없는 기본 카드 입력 화면을 띄웁니다.

### 카메라 권한

Web OCR 은 WebView 안의 결제 화면이 카메라를 엽니다. iOS 에서는 아래를 확인합니다.

- 앱의 카메라 권한: Info.plist 의 `NSCameraUsageDescription` 은 지우지 않습니다. 카메라 권한은 WebKit 이 묻습니다.
- 인라인 재생: `WKWebViewConfiguration.allowsInlineMediaPlayback` 을 `true` 로 두는 것을 권장합니다. WKWebView 를 만들기 전에 설정합니다.
- WebView 의 권한 요청 처리: `WKUIDelegate` 의 `requestMediaCapturePermissionFor`(iOS 15 이상)를 직접 구현한 앱만 해당합니다. 구현하지 않은 앱은 WebKit 기본 확인 창이 뜨므로 할 일이 없습니다. 구현한 앱은 카메라를 켠 프레임이 결제 화면(`https://connect.tosspayments.com`)일 때 `.grant` 나 `.prompt` 로 두고, 그 밖의 요청은 거부합니다.
- 결제 화면을 담는 iframe 의 카메라 허용(`allow="camera"`)은 JS SDK 가 옵션이 켜졌을 때 넣습니다. 가맹점이 할 일은 없습니다.

```swift
let configuration = WKWebViewConfiguration()
configuration.allowsInlineMediaPlayback = true
let webView = WKWebView(frame: .zero, configuration: configuration)
```

```swift
// WKUIDelegate 의 카메라 권한 처리를 직접 구현한 앱만 해당합니다.
@available(iOS 15.0, *)
func webView(
    _ webView: WKWebView,
    requestMediaCapturePermissionFor origin: WKSecurityOrigin,
    initiatedByFrame frame: WKFrameInfo,
    type: WKMediaCaptureType,
    decisionHandler: @escaping (WKPermissionDecision) -> Void
) {
    // 카메라를 켠 프레임이 결제 화면(connect)이면 막지 않습니다.
    // .prompt 는 WebKit 확인 창을 띄우고, .grant 는 확인 창 없이 켭니다.
    let securityOrigin = frame.securityOrigin
    if type == .camera,
       securityOrigin.protocol == "https",
       securityOrigin.host == "connect.tosspayments.com" {
        decisionHandler(.prompt)
        return
    }
    // 그 밖의 요청은 거부합니다. 앱이 다른 페이지에서 카메라나 마이크를 쓰면 그 처리를 이 자리에 둡니다.
    decisionHandler(.deny)
}
```

### 스캔이 안 되는 기기

- WebView 가 카메라를 여는 `navigator.mediaDevices.getUserMedia` 는 iOS 14.3 부터 WKWebView 에 있습니다. iOS 11.0 부터 14.2 까지는 스캔 버튼을 누르면 카메라가 없다는 알림이 뜨고, 카드 번호를 직접 넣어야 합니다. `autoStart: true` 면 화면이 열리자마자 알림이 뜹니다.
- 사용자가 카메라 권한을 거부하면 결제 화면이 카메라 권한이 필요하다는 안내를 띄웁니다. 카드 번호를 직접 넣는 것은 그대로 됩니다.
- 앱 카드 스캔은 iOS 11.0 부터 동작하므로, 옮기면 iOS 14.3 미만 사용자는 스캔을 쓰지 못합니다. 그 사용자 비중을 보고 옮길 시점과 `autoStart` 를 정합니다.

### 옮긴 뒤 확인

- Xcode 콘솔에 아래 OCR 경고가 남지 않습니다. 1.4.0 은 OCR 브리지(`ScanOCRCardAppBridge`, `IsOCRAvailableAppBridge`)를 만들 때 이 문구를 경고 레벨로 프로세스당 한 번 남기므로, 문구가 나오면 OCR 연동이 남아 있는 것입니다. 1.3.2 이하는 이 문구를 남기지 않습니다.

```
BrandPay 앱 카드 OCR(OCRInterface, FinCubeOcrSDK)은 deprecated 되었습니다. 기능은 지금처럼 동작하지만, 가급적 Web OCR 로 옮기는 것을 권장합니다. Web OCR 도 앱 OCR 처럼 별도 계약이 필요하니 담당 매니저나 토스페이먼츠 개발자 커뮤니티(https://developers.tosspayments.com/go/techchat)로 문의하세요.
```

- 카드 등록 화면에서 Web OCR 스캔이 열리고 카드 번호가 채워집니다.
- 카메라 권한을 거부했을 때 안내가 뜨고, 카드 번호를 직접 넣어 등록할 수 있습니다.

### 문의

Web OCR 사용 계약과 OCR 관련 문의는 담당 매니저나 [토스페이먼츠 개발자 커뮤니티](https://developers.tosspayments.com/go/techchat)로 합니다.
