//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 09.06.2024.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    // MARK: - Public Properties

    weak var delegate: WebViewControllerDelegate?

    // MARK: - IBOutlet

    @IBOutlet weak private var webView: WKWebView!
    @IBOutlet weak private var progressView: UIProgressView!

    // MARK: - Private Properties

    private var observation: NSKeyValueObservation?

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        loadAuthView()

        observation = webView.observe(\WKWebView.estimatedProgress, options: [.new]) { [weak self] _, _ in
            self?.updateProgressView()
        }
    }

    // MARK: - Private Methods

    /// Загружает окно авторизации Unsplash во встроенном браузере
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]

        guard let url = urlComponents.url else {
            assertionFailure("Ошибка сборки URL из строковой константы")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    /// Обрабатывает ответ от страницы аутентификации Unsplash
    /// - Parameter navigationAction: Объект с оттветом страницы аутентификации
    /// - Returns: Возвращает код авторизации при успешной аутентификации; в противном случае - nil
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" }) {
            return codeItem.value
        } else {
            return nil
        }
    }

    /// Используется для обновления состояния элемента, отображающего прогресс загрузки страницы аутентификации
    private func updateProgressView() {
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    /// Используется для обработки редиректа со страницы аутентификации Unsplash
    /// - Parameters:
    ///   - webView: Веб-контроллер
    ///   - navigationAction: Объект с данными о навигации в веб-контроллере
    ///   - decisionHandler: Обработчик события
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
