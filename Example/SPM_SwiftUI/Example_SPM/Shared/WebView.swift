//
//  WebView.swift
//  Example_SPM
//
//  Created by 김진규 on 2022/02/15.
//

import SwiftUI
import WebKit
import BrandPayBase
import OCRInterface
import BiometricInterface

struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    var url: String = "https://tosspayments.com"
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false  // JavaScript가 사용자 상호 작용없이 창을 열 수 있는지 여부
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator    // 웹보기의 탐색 동작을 관리하는 데 사용하는 개체
        webView.allowsBackForwardNavigationGestures = true    // 가로로 스와이프 동작이 페이지 탐색을 앞뒤로 트리거하는지 여부
        webView.scrollView.isScrollEnabled = true    // 웹보기와 관련된 스크롤보기에서 스크롤 가능 여부
        
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))    // 지정된 URL 요청 개체에서 참조하는 웹 콘텐츠를로드하고 탐색
            context.coordinator.webView = webView
            context.coordinator.installAppBridges()
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Do nothing
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WebViewControllerType {
        
        weak var webView: WKWebView?
        
        // 브리지를 붙인 WebView 는 이 출처만 엽니다. 그 밖의 주소는 외부 브라우저나 앱으로 넘깁니다(README 의 WebView 탐색 제한).
        // tosspayments.com 은 www.tosspayments.com 으로 리다이렉트하므로 둘 다 넣습니다.
        let allowedOrigins: Set<String> = ["https://tosspayments.com", "https://www.tosspayments.com"]
        
        func installAppBridges() {
            // 1.4.0 부터는 같은 출처를 넘깁니다: try WebScriptMessageHandler(allowedOriginRules: allowedOrigins)
            let messageHandler = WebScriptMessageHandler()
            messageHandler.controller = self
            
            messageHandler.register(appBridge: GetAppInfoAppBridge())
            messageHandler.register(appBridge: HasBiometricAuthAppBridge())
            messageHandler.register(appBridge: GetBiometricAuthMethodsAppBridge())
            messageHandler.register(appBridge: VerifyBiometricAuthAppBridge())
            messageHandler.register(appBridge: RegisterBiometricAuthAppBridge())
            messageHandler.register(appBridge: UnregisterBiometricAuthAppBridge())
            webView?.configuration.userContentController.add(messageHandler, name: "ConnectPayAuth")
            
            // * OCR 기능은 앱 패키지 별로 flk license file 로 관리됩니다.
            messageHandler.register(appBridge: ScanOCRCardAppBridge(licenseKeyFile: "tosspayment_20220513.flk"))
            messageHandler.register(appBridge: IsOCRAvailableAppBridge())
            webView?.configuration.userContentController.add(messageHandler, name: "ConnectPayOcr")
        }
        
        func evaluateJavaScriptSafely(javaScriptString: String) {
            webView?.evaluateJavaScriptSafely(javaScriptString, completionHandler: { (_, _) in
                // do nothing
            })
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
            
            // 카드사 앱, 은행 앱 같은 http, https 가 아닌 스킴은 막지 않고 앱으로 넘깁니다.
            // about, data, blob 은 WebView 안에서 쓰는 주소라 넘기지 않습니다.
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
}
