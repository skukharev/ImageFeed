//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Сергей Кухарев on 19.07.2024.
//
import XCTest

final class ImageFeedUITests: XCTestCase {
    private var app = XCUIApplication() // переменная приложения
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
        _ = ImagesViewControllerScreen(application: app)
            // Подождать, пока открывается и загружается экран ленты
            .loadFeed()
            // Сделать жест «смахивания» вверх по экрану для его скролла
            .swipeUpFirstVisibleCell()
            // Поставить лайк в ячейке картинки
            .setupLikeOnFirstVisibleCell()
            // Поставить лайк в ячейке картинки
            .setupLikeOnFirstVisibleCell()
            // Нажать на эту ячейку
            .tapOnFirstVisibleCell()
            // Увеличить картинку на экране детального просмотра изображения
            .zoomInImage()
            // Уменьшить картинку
            .zoomOutImage()
            // Нажать на кнопку действий с изображением
            .tapOnShareImageButton()
            // Закрыть диалоговое окно действий с изображением
            .closeUIActionViewController()
            // Вернуться на экран ленты
            .returnOnImagesFeed()
            // Сделать жест «смахивания» вниз по экрану для его скролла
            .swipeDownTableView()
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

        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .deleteOnSuccess
        add(attachment)

        app.terminate()
    }
}
