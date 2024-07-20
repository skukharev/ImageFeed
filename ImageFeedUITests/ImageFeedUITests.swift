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

    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        app.launch() // запускаем приложение перед каждым тестом
    }

    func testAuth() throws {
        // тестируем сценарий авторизации
        // Нажать кнопку авторизации
        /* У приложения мы получаем список кнопок на экране и получаем нужную кнопку по тексту на ней. Далее вызываем функцию tap() для нажатия на этот элемент
        */
        app.buttons["Authenticate"].tap()
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        #warning("Вставить логин Unsplash перед тестированием")
        loginTextField.typeText("")
        app.toolbars["Toolbar"].buttons["Далее"].tap()              // webView.swipeUp() не приводит к сокрытию клавиатуры на экране iPhone 15 Pro Max
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        sleep(1)
        #warning("Вставить пароль Unsplash перед тестированием")
        passwordTextField.typeText("")
        print(app.debugDescription)
        // Нажать кнопку логина
        webView.buttons["Login"].tap()
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        // тестируем сценарий ленты
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        // Поставить лайк в ячейке верхней картинки
        let likeButton = cell.buttons["NoActiveLikeButton"]
        XCTAssertTrue(likeButton.exists)
        XCTAssertTrue(likeButton.isHittable)
        likeButton.tap()
        sleep(3)
        // Отменить лайк в ячейке верхней картинки
        let cancelLikeButton = cell.buttons["ActiveLikeButton"]
        XCTAssertTrue(cancelLikeButton.exists)
        XCTAssertTrue(cancelLikeButton.isHittable)
        cancelLikeButton.tap()
        sleep(3)
        // Нажать на верхнюю ячейку
        cell.tap()
        // Подождать, пока картинка открывается на весь экран
        sleep(45)
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
        // Сделать жест «смахивания» вверх по экрану для его скролла
        cell.swipeUp()
        sleep(3)
    }

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
        XCTAssertTrue(app.buttons["Authenticate"].exists)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
    }
}
