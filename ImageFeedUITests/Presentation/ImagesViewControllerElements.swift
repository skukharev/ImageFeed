//
//  ImagesViewControllerElements.swift
//  ImageFeedUITests
//
//  Created by Сергей Кухарев on 22.07.2024.
//

import XCTest

final class ImagesViewControllerElements {
    // MARK: - Types

    private enum Identifiers {
        static let tableView = "ImagesViewController.tableView"
        static let cellButton = "cellButton"
    }

    // MARK: - Private Properties

    private var application: XCUIApplication

    // MARK: - Initializers

    init (application: XCUIApplication) {
        self.application = application
    }

    // MARK: - Public Methods

    func tableViewElement() -> XCUIElement {
        return application.tables.element(matching: NSPredicate(format: "identifier == '\(Identifiers.tableView)'"))
    }

    func likeButtonElement(forCell: XCUIElement) -> XCUIElement {
        return forCell.children(matching: .button).element(
            matching: NSPredicate(format: "identifier == '\(Identifiers.cellButton)'")
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
