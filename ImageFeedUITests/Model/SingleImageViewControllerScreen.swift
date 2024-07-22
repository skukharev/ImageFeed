//
//  SingleImageViewControllerScreen.swift
//  ImageFeedUITests
//
//  Created by Сергей Кухарев on 22.07.2024.
//

import XCTest

struct SingleImageViewControllerScreen: Screen {
    // MARK: - Public Properties

    let application: XCUIApplication

    // MARK: - Private Properties

    private let view: SingleImageViewControllerElements

    // MARK: - Initializers

    init(application: XCUIApplication) {
        self.application = application
        self.view = SingleImageViewControllerElements(application: application)
    }
    // MARK: - Public Methods

    /// Тестирование увеличения детального изображения
    /// - Returns: Ссылка на тестируемый экран
    func zoomInImage() -> Self {
        let image = view.imageViewElement()
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        image.pinch(withScale: 3, velocity: 1)
        sleep(5)
        return self
    }

    /// Тестирование уменьшения детального изображения
    /// - Returns: Ссылка на тестируемый экран
    func zoomOutImage() -> Self {
        let image = view.imageViewElement()
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(3)
        return self
    }

    /// Тестирование нажатия на кнопку поделиться изображением
    /// - Returns: Ссылка на тестируемый экран
    func tapOnShareImageButton() -> Self {
        let shareImageButton = view.shareImageButtonElement()
        XCTAssertTrue(shareImageButton.exists)
        shareImageButton.tap()
        sleep(5)
        return self
    }

    /// Тестирование закрытия стандартного окна действий с изображением
    /// - Returns: Ссылка на тестируемый экран
    func closeUIActionViewController() -> Self {
        let closeButton = view.uiActivityViewControllerCloseButton()
        XCTAssertTrue(closeButton.exists)
        closeButton.tap()
        sleep(1)
        return self
    }

    /// Тестирование нажатия на кнопку возврата на главный экран с лентой изображений
    /// - Returns: Ссылка на тестируемый экран
    func returnOnImagesFeed() -> ImagesViewControllerScreen {
        let backButton = view.backButtonElement()
        XCTAssertTrue(backButton.exists)
        backButton.tap()
        sleep(3)
        return ImagesViewControllerScreen(application: application)
    }
}
