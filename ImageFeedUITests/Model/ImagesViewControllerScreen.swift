//
//  ImagesViewControllerScreen.swift
//  ImageFeedUITests
//
//  Created by Сергей Кухарев on 22.07.2024.
//

import XCTest

struct ImagesViewControllerScreen: Screen {
    // MARK: - Types

    private enum Identifiers {
        static let tableView = "ImagesViewController.tableView"
        static let cellButton = "cellButton"
    }

    // MARK: - Public Properties

    let application: XCUIApplication

    // MARK: - Public Methods

    /// Тестирование загрузки ленты фотографий и отображения минимум одной ячейки
    /// - Returns: Ссылка на тестируемый экран
    func loadFeed() -> Self {
        sleep(5)
        let tableView = tableViewElement()
        XCTAssertTrue(tableView.exists)
        let firstCell = getFirstLikableCell()
        XCTAssertNotNil(firstCell)
        guard let firstCell = firstCell else {
            return self
        }
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        return self
    }

    /// Тестирование жеста «смахивания» вверх по экрану для его скролла
    /// - Returns: Ссылка на тестируемый экран
    func swipeUpFirstVisibleCell() -> Self {
        let firstCell = getFirstLikableCell()
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
        let likeableCell = getFirstLikableCell()
        XCTAssertNotNil(likeableCell)
        guard let likeableCell = likeableCell else {
            return self
        }
        XCTAssertTrue(likeableCell.waitForExistence(timeout: 10))
        let likeButton = likeButtonElement(forCell: likeableCell)
        XCTAssertTrue(likeButton.exists)
        likeButton.tap()
        sleep(3)
        return self
    }

    /// Тестирование клика на видимой ячейке для открытия экрана детального просмотра фотографии
    /// - Returns: Ссылка на тестируемый экран
    func tapOnFirstVisibleCell() -> SingleImageViewControllerScreen {
        let visibleCell = getFirstLikableCell()
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
        let tableView = tableViewElement()
        XCTAssertTrue(tableView.exists)
        tableView.swipeDown()
        sleep(3)
        return self
    }

    // MARK: - Private Methods

    private func tableViewElement() -> XCUIElement {
        return application.tables.element(matching: NSPredicate(format: "identifier == '\(Identifiers.tableView)'"))
    }

    private func likeButtonElement(forCell: XCUIElement) -> XCUIElement {
        return forCell.children(matching: .button).element(
            matching: NSPredicate(format: "identifier == '\(Identifiers.cellButton)'")
        )
    }

    private func getFirstLikableCell() -> XCUIElement? {
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
