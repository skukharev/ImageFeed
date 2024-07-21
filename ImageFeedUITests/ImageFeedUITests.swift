//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Сергей Кухарев on 19.07.2024.
//
@testable import ImageFeed
import XCTest

final class ImageFeedUITests: XCTestCase {
    private var app = XCUIApplication() // переменная приложения
    #warning("Перед тестированием ввести имя реквизиты учётной записи в Unsplash")
    private enum Credentials {
        static let userLogin = ""
        static let userPassword = ""
    }

    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        app.launchEnvironment = ["TEST": "true"]
        app.launch() // запускаем приложение перед каждым тестом
    }

    /// Тестирование сценария авторизации пользователя
    func testAuth() throws {
        // тестируем сценарий авторизации
        // Нажать кнопку авторизации
        /* У приложения мы получаем список кнопок на экране и получаем нужную кнопку по тексту на ней. Далее вызываем функцию tap() для нажатия на этот элемент
        */
        app.buttons["LoginButton"].tap()
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["WebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText(Credentials.userLogin)
        app.toolbars["Toolbar"].buttons["Далее"].tap()              // webView.swipeUp() не приводит к сокрытию клавиатуры на экране iPhone 15 Pro Max
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText(Credentials.userPassword)
        print(app.debugDescription)
        // Нажать кнопку логина
        webView.buttons["Login"].tap()
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    /// Тестирование сценария использования ленты фотографий
    func testFeed() throws {
        // тестируем сценарий ленты
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        sleep(3)
        // Поставить лайк в ячейке верхней картинки
        let likeButton = cell.buttons["cellButton"]
        XCTAssertTrue(likeButton.exists)
        likeButton.tap()
        sleep(3)
        // Отменить лайк в ячейке верхней картинки
        let cancelLikeButton = cell.buttons["cellButton"]
        XCTAssertTrue(cancelLikeButton.exists)
        cancelLikeButton.tap()
        sleep(3)
        // Нажать на верхнюю ячейку
        cell.tap()
        // Подождать, пока картинка открывается на весь экран
        sleep(25)
        // Увеличить картинку
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        image.pinch(withScale: 3, velocity: 1)
        sleep(5)
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(3)
        // Вернуться на экран ленты
        app.buttons["backButton"].tap()
        sleep(3)
        // Сделать жест «смахивания» вверх по экрану для его скролла
        let tableView = tablesQuery.element(boundBy: 0)
        tableView.swipeUp()
        sleep(3)
    }

    /// Тестирование сценария использования ленты фотографий (продвинутое)
    func testFeedAdvanced() throws {
        let imagesViewControllerPage = ImagesViewControllerPage(application: app)
        // Подождать, пока открывается и загружается экран ленты
        let tableView = imagesViewControllerPage.tableViewElement()
        XCTAssertTrue(tableView.exists)
        let firstCell = imagesViewControllerPage.getFirstLikableCell()
        XCTAssertNotNil(firstCell)
        guard let firstCell = firstCell else { return }
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        sleep(3)
        // Сделать жест «смахивания» вверх по экрану для его скролла
        firstCell.swipeUp()
        sleep(3)
        // Поставить лайк в ячейке картинки
        let likeableCell = imagesViewControllerPage.getFirstLikableCell()
        XCTAssertNotNil(likeableCell)
        guard let likeableCell = likeableCell else { return }
        XCTAssertTrue(likeableCell.waitForExistence(timeout: 10))
        let likeButton = imagesViewControllerPage.likeButtonElement(forCell: likeableCell)
        XCTAssertTrue(likeButton.exists)
        likeButton.tap()
        sleep(3)
        // Отменить лайк в ячейке картинки
        likeButton.tap()
        sleep(3)
        // Нажать на эту ячейку
        likeableCell.tap()
        // Подождать, пока картинка открывается на весь экран
        sleep(25)
        // Увеличить картинку на экране детального просмотра изображения
        let singleImageViewControllerPage = SingleImageViewControllerPage(application: app)
        let image = singleImageViewControllerPage.imageViewElement()
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        image.pinch(withScale: 3, velocity: 1)
        sleep(5)
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(3)
        // Нажать на кнопку действий с изображением
        let shareImageButton = singleImageViewControllerPage.shareImageButtonElement()
        XCTAssertTrue(shareImageButton.exists)
        shareImageButton.tap()
        sleep(5)
        // Закрыть диалоговое окно действий с изображением
        let copyActionElement = singleImageViewControllerPage.uiActivityViewControllerCopyElement()
        XCTAssertTrue(copyActionElement.exists)
        copyActionElement.tap()
        // Вернуться на экран ленты
        let backButton = singleImageViewControllerPage.backButtonElement()
        XCTAssertTrue(backButton.exists)
        backButton.tap()
        sleep(3)
        // Сделать жест «смахивания» вниз по экрану для его скролла
        tableView.swipeDown()
    }

    /// Тестирование отображения профиля пользователя, выход из профиля
    func testProfile() throws {
        // тестируем сценарий профиля
        // Перейти на экран профиля
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(1)
        let isAlertExists = app.alerts["Что-то пошло не так("].exists
        if isAlertExists {
            app.alerts["Что-то пошло не так("].scrollViews.otherElements.buttons["OK"].tap()
        }
        sleep(1)
        // Проверить, что на нём отображаются ваши персональные данные
        if isAlertExists {
            XCTAssertTrue(app.staticTexts["Екатерина Новикова"].exists)
            XCTAssertTrue(app.staticTexts["@ekaterina_nov"].exists)
        } else {
            XCTAssertTrue(app.staticTexts["Sergei Kukharev"].exists)
            XCTAssertTrue(app.staticTexts["@skukharev"].exists)
        }
        // Нажать кнопку логаута
        app.buttons["ExitButton"].tap()
        sleep(1)
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        sleep(1)
        // Проверить, что открылся экран авторизации
        XCTAssertTrue(app.buttons["LoginButton"].exists)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
    }
}

final class ImagesViewControllerPage {
    // MARK: - Private Properties

    private var application: XCUIApplication

    // MARK: - Initializers

    init (application: XCUIApplication) {
        self.application = application
    }

    // MARK: - Public Methods

    func tableViewElement() -> XCUIElement {
        return application.tables.element(matching: .table, identifier: "ImagesViewController.tableView")
    }

    func likeButtonElement(forCell: XCUIElement) -> XCUIElement {
        return forCell.children(matching: .button).element(
            matching: NSPredicate(format: "identifier == 'cellButton'")
        )
    }

    func getFirstLikableCell() -> XCUIElement? {
        let cellsCount = tableViewElement().children(matching: .cell).count
        if cellsCount == 0 {
            return nil
        }
        for i in 0...cellsCount - 1 {
            let cell = tableViewElement().children(matching: .cell).element(boundBy: i)
            let likeButton = likeButtonElement(forCell: cell)
            if likeButton.exists && likeButton.isHittable {
                return cell
            }
        }
        return nil
    }
}

final class SingleImageViewControllerPage {
    // MARK: - Private Properties

    private var application: XCUIApplication

    // MARK: - Initializers

    init (application: XCUIApplication) {
        self.application = application
    }

    // MARK: - Public Methods

    func scrollViewElement() -> XCUIElement {
        return application.scrollViews.element(matching: .scrollView, identifier: "SingleImageViewController.scrollView")
    }

    func imageViewElement() -> XCUIElement {
        return scrollViewElement().images.element(matching: .image, identifier: "SingleImageViewController.imageView")
    }

    func backButtonElement() -> XCUIElement {
        return application.buttons.element(matching: .button, identifier: "SingleImageViewController.backButton")
    }

    func shareImageButtonElement() -> XCUIElement {
        return application.buttons.element(matching: .button, identifier: "SingleImageViewController.shareImageButton")
    }

    func uiActivityViewControllerCopyElement() -> XCUIElement {
        return application.collectionViews.containing(.cell, identifier: "Скопировать").element
    }
}
