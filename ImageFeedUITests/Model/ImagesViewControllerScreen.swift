//
//  ImagesViewControllerScreen.swift
//  ImageFeedUITests
//
//  Created by Сергей Кухарев on 22.07.2024.
//

import XCTest

struct ImagesViewControllerScreen: Screen {
    // MARK: - Public Properties

    let application: XCUIApplication

    // MARK: - Private Properties

    private let view: ImagesViewControllerElements

    // MARK: - Initializers

    init(application: XCUIApplication) {
        self.application = application
        self.view = ImagesViewControllerElements(application: application)
    }

    /// Тестирование загрузки ленты фотографий и отображения минимум одной ячейки
    /// - Returns: Ссылка на тестируемый экран
    func loadFeed() -> Self {
        sleep(5)
        let tableView = view.tableViewElement()
        XCTAssertTrue(tableView.exists)
        let firstCell = view.getFirstLikableCell()
        XCTAssertNotNil(firstCell)
        guard let firstCell = firstCell else {
            return self
        }
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        return self
    }

    // MARK: - Public Methods

    /// Тестирование жеста «смахивания» вверх по экрану для его скролла
    /// - Returns: Ссылка на тестируемый экран
    func swipeUpFirstVisibleCell() -> Self {
        let firstCell = view.getFirstLikableCell()
        XCTAssertNotNil(firstCell)
        guard let firstCell = firstCell else {
            return self
        }
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        firstCell.swipeUp()
        sleep(3)
        return self
    }

    /// Тестирование лайка на видимой ячейке
    /// - Returns: Ссылка на тестируемый экран
    func setupLikeOnFirstVisibleCell() -> Self {
        let likeableCell = view.getFirstLikableCell()
        XCTAssertNotNil(likeableCell)
        guard let likeableCell = likeableCell else {
            return self
        }
        XCTAssertTrue(likeableCell.waitForExistence(timeout: 10))
        let likeButton = view.likeButtonElement(forCell: likeableCell)
        XCTAssertTrue(likeButton.exists)
        likeButton.tap()
        sleep(3)
        return self
    }

    /// Тестирование клика на видимой ячейке для открытия экрана детального просмотра фотографии
    /// - Returns: Ссылка на тестируемый экран
    func tapOnFirstVisibleCell() -> SingleImageViewControllerScreen {
        let visibleCell = view.getFirstLikableCell()
        XCTAssertNotNil(visibleCell)
        guard let visibleCell = visibleCell else {
            return SingleImageViewControllerScreen(application: application)
        }
        XCTAssertTrue(visibleCell.waitForExistence(timeout: 10))
        visibleCell.tap()
        sleep(10)
        return SingleImageViewControllerScreen(application: application)
    }

    /// Тестирование жеста "смахивания" вниз по экрану для его скролла
    /// - Returns: Ссылка на тестируемый экран
    func swipeDownTableView() -> Self {
        let tableView = view.tableViewElement()
        XCTAssertTrue(tableView.exists)
        tableView.swipeDown()
        sleep(3)
        return self
    }
}
