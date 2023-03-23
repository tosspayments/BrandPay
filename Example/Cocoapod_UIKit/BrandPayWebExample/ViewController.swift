//
//  ViewController.swift
//  BrandPayWebInterface
//
//  Created by 김진규 on 2021/11/26.
//  Copyright © 2021 com.tosspayments. All rights reserved.
//

import WebKit
import BrandPayBase
import BiometricInterface
import OCRInterface

final class BrandPayWebInterfaceDemoViewController: UIViewController {
    enum Constants {
        static let latestURL: String = "LastestURL"
    }
    lazy var webView: WKWebView = {
        let webView = WKWebView()
        
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        setupRightBarButton()
        
        installAppBridges()
    }
    
    private func setupWebView() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        webView.navigationDelegate = self
        
        let urlString = UserDefaults.standard.string(forKey: Constants.latestURL) ?? "https://tosspayments.com"
        webView.load(URLRequest(url: URL(string: urlString)!))
    }
    private func setupRightBarButton() {
        navigationController?.navigationBar.isTranslucent = false
        let item = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapRightBarButton(_:)))
        navigationItem.rightBarButtonItem = item
    }
    
    @objc func didTapRightBarButton(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Test URL을 입력하세요.",
            message: "클립보드의 내용이 URL일 경우 자동으로 붙여 넣습니다.",
            preferredStyle: .alert
        )
        alertController.addTextField(configurationHandler: { textField in
            if let pasteBoardString = UIPasteboard.general.string,
               !pasteBoardString.isEmpty, URL(string: pasteBoardString) != nil {
                textField.text = pasteBoardString
            }
        })
        alertController.addAction(
            UIAlertAction(title: "취소", style: .cancel, handler: nil)
        )
        alertController.addAction(
            UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
                if let urlString = alertController.textFields?.first?.text,
                   let url = URL(string: urlString) {
                    UserDefaults.standard.set(urlString, forKey: Constants.latestURL)
                    self?.webView.load(URLRequest(url: url))
                }
            })
        )
        present(alertController, animated: true, completion: nil)
    }
}

extension BrandPayWebInterfaceDemoViewController: WebViewControllerType {
    func installAppBridges() {
        let messageHandler = WebScriptMessageHandler()
        messageHandler.controller = self
        
        messageHandler.register(appBridge: GetAppInfoAppBridge())
        messageHandler.register(appBridge: HasBiometricAuthAppBridge())
        messageHandler.register(appBridge: GetBiometricAuthMethodsAppBridge())
        messageHandler.register(appBridge: VerifyBiometricAuthAppBridge())
        messageHandler.register(appBridge: RegisterBiometricAuthAppBridge())
        messageHandler.register(appBridge: UnregisterBiometricAuthAppBridge())
        webView.configuration.userContentController.add(messageHandler, name: "ConnectPayAuth")
        
//         * OCR 기능은 앱 패키지 별로 flk license file 로 관리됩니다.
        messageHandler.register(appBridge: ScanOCRCardAppBridge(licenseKeyFile: "tosspayment_20220513.flk"))
        messageHandler.register(appBridge: IsOCRAvailableAppBridge())
        webView.configuration.userContentController.add(messageHandler, name: "ConnectPayOcr")
        
        // Deprecated: ConnectPayAuth, ConnectPayOcr 두개의 javascript object 로 나뉘어졌음
        webView.configuration.userContentController.add(messageHandler, name: "connectWebViewAction")
    }
    
    func evaluateJavaScriptSafely(javaScriptString: String) {
        webView.evaluateJavaScript(javaScriptString) { (_, _) in
            
        }
    }
}

extension BrandPayWebInterfaceDemoViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showAlert(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showAlert(error.localizedDescription)
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "로드 실패", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
