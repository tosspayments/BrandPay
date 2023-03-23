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
        
        func installAppBridges() {
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
    }
}
