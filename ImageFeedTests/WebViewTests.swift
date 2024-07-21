//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Сергей Кухарев on 17.07.2024.
//
@testable import ImageFeed
import XCTest

enum WebViewTestsError: Error {
    case urlConvertError
}

final class WebViewTests: XCTestCase {
    /// Проверяет, вызывает ли WebViewController метод презентера viewDidLoad
    func testViewControllerCallsViewDidLoad() throws {
        // given
        let webViewController = WebViewController()
        let presenter = WebViewPresenterSpy()
        webViewController.presenter = presenter
        presenter.view = webViewController

        // when
        _ = webViewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    /// Проверяет, вызывает ли webViewPresenter метод вью контроллера load
    func testPresenterCallsLoadRequest() throws {
        // given
        let webViewController = WebViewControllerSpy()
        let authHelper = AuthHelper()
        let sut = WebViewPresenter(authHelper: authHelper)
        webViewController.presenter = sut
        sut.view = webViewController

        // when
        sut.viewDidLoad()

        // then
        XCTAssertTrue(webViewController.presenterDidLoadCalled)
    }

    /// Проверяет, возвращается ли false для значения меньше 1 в методе презентера shouldHideProgress
    func testProgressVisibleWhenLessThenOne() throws {
        // given
        let authHelper = AuthHelper()
        let sut = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6

        // when
        let shouldHideProgress = sut.shouldHideProgress(for: progress)

        // then
        XCTAssertFalse(shouldHideProgress)
    }

    /// Проверяет, возвращается ли true для значения 1 в методе презентера shouldHideProgress
    func testProgressHiddenWhenOne() throws {
        // given
        let authHelper = AuthHelper()
        let sut = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1

        // when
        let shouldHideProgress = sut.shouldHideProgress(for: progress)

        // then
        XCTAssertTrue(shouldHideProgress)
    }

    /// Проверяет, распознаёт ли AuthHelper код из ссылки
    func testCodeFromURL() throws {
        // given
        let testingURLString = "https://unsplash.com/oauth/authorize/native"
        var urlComponents = URLComponents(string: testingURLString)
        urlComponents?.queryItems = [URLQueryItem(name: "code", value: "test code")]
        guard let testingURL = urlComponents?.url else {
            throw WebViewTestsError.urlConvertError
        }
        let sut = AuthHelper()

        // when
        let result = sut.code(from: testingURL)

        // then
        XCTAssertEqual(result, "test code")
    }
}

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    weak var view: WebViewControllerProtocol?
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {
    }

    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewControllerSpy: WebViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var presenterDidLoadCalled = false

    func load(request: URLRequest) {
        presenterDidLoadCalled = true
    }

    func setProgressValue(_ newValue: Float) {
    }

    func setProgressHidden(_ isHidden: Bool) {
    }
}
