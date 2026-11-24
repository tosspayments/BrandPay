//
//  ViewController.swift
//  BrandPayOCRExample
//
//  Created by 김진규 on 2021/11/25.
//  Copyright © 2021 com.tosspayments. All rights reserved.
//

import WebKit
import BrandPayBase
import OCRInterface

final class BrandPayWebInterfaceDemoViewController: UIViewController {
    enum Constants {
        // 브리지를 붙인 WebView 는 이 출처만 엽니다. 그 밖의 주소는 외부 브라우저나 앱으로 넘깁니다(README 의 WebView 탐색 제한).
        static let allowedOrigins: Set<String> = ["https://toss.im"]
    }
    lazy var webView: WKWebView = {
        let webView = WKWebView()
        
        return webView
    }()
    var messageHandler: WKScriptMessageHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: "https://toss.im")!))
        
        installAppBridges()
    }
}

extension BrandPayWebInterfaceDemoViewController: WebViewControllerType {
    func evaluateJavaScriptSafely(javaScriptString: String) {
        webView.evaluateJavaScript(javaScriptString) { (_, _) in
            
        }
    }
    
    func installAppBridges() {
        // 1.4.0 부터는 같은 출처를 넘깁니다: try WebScriptMessageHandler(allowedOriginRules: Constants.allowedOrigins)
        let messageHandler = WebScriptMessageHandler()
        messageHandler.controller = self
        messageHandler.register(appBridge: ScanOCRCardAppBridge(licenseKeyFile: ""))
        webView.configuration.userContentController.add(messageHandler, name: "connectPayWebViewAction")
        
        self.messageHandler = messageHandler
    }
}

extension BrandPayWebInterfaceDemoViewController: WKNavigationDelegate {
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
        if let origin = origin(of: url), Constants.allowedOrigins.contains(origin) {
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
