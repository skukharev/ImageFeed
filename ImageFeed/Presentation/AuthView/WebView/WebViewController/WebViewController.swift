//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 09.06.2024.
//

import UIKit
import WebKit

final class WebViewController: UIViewController, WebViewControllerProtocol {
    // MARK: - Public Properties

    weak var delegate: WebViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?

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
        presenter?.viewDidLoad()
        presenter?.didUpdateProgressValue(0)

        observation = webView.observe(\WKWebView.estimatedProgress, options: [.new]) { [weak self] _, estimatedProgress in
            self?.presenter?.didUpdateProgressValue(estimatedProgress.newValue ?? 0)
        }
    }

    // MARK: - Public Methods

    func load(request: URLRequest) {
        webView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
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
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    /// Используется для обработки редиректа со страницы аутентификации Unsplash
    /// - Parameters:
    ///   - webView: Веб-контроллер
    ///   - navigationAction: Объект с данными о навигации в веб-контроллере
    ///   - decisionHandler: Обработчик события
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
            let code = presenter?.code(from: url) {
            delegate?.webViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
