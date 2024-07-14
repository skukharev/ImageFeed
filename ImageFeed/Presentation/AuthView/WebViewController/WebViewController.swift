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

    // MARK: - Private Properties

    private var observation: NSKeyValueObservation?

    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = .ypBlack
        return progressView
    }()
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .ypWhite
        return webView
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        createAndLayoutViews()
        webView.navigationDelegate = self
        loadAuthView()

        observation = webView.observe(\WKWebView.estimatedProgress, options: [.new]) { [weak self] _, _ in
            self?.updateProgressView()
        }
    }

    // MARK: - Private Methods

    /// Создаёт элементы управления
    private func addSubViews() {
        view.addSubview(webView)
        view.addSubview(progressView)
    }

    /// Устанавливает цвет фона заголовка верхней панели навигации в соответствии с дизайн-макетом проекта
    private func configureNavigationController() {
        let barItemBackgroundColor = UIColor.ypWhite
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = barItemBackgroundColor
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
            navigationItem.compactAppearance = appearance
        } else {
            navigationController?.navigationBar.barTintColor = barItemBackgroundColor
        }
    }

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        addSubViews()
        setupConstraints()
        configureNavigationController()
    }

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

    /// Устанавливает констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Индикатор загрузки
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            // Веб-браузер
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0)
        ])
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
