//
//  SingleImageViewControllerElements.swift
//  ImageFeedUITests
//
//  Created by Сергей Кухарев on 22.07.2024.
//

import XCTest

final class SingleImageViewControllerElements {
    // MARK: - Types

    private enum Identifiers {
        static let scrollView = "SingleImageViewController.scrollView"
        static let imageView = "SingleImageViewController.imageView"
        static let backButton = "SingleImageViewController.backButton"
        static let shareImageButton = "SingleImageViewController.shareImageButton"
        static let closeButtonOfTheUIActivityViewController = "Закрыть"
    }

    // MARK: - Private Properties

    private var application: XCUIApplication

    // MARK: - Initializers

    init (application: XCUIApplication) {
        self.application = application
    }

    // MARK: - Public Methods

    func scrollViewElement() -> XCUIElement {
        return application.scrollViews.element(matching: .scrollView, identifier: Identifiers.scrollView)
    }

    func imageViewElement() -> XCUIElement {
        return scrollViewElement().images.element(matching: .image, identifier: Identifiers.imageView)
    }

    func backButtonElement() -> XCUIElement {
        return application.buttons.element(matching: .button, identifier: Identifiers.backButton)
    }

    func shareImageButtonElement() -> XCUIElement {
        return application.buttons.element(matching: .button, identifier: Identifiers.shareImageButton)
    }

    func uiActivityViewControllerCloseButton() -> XCUIElement {
        application.otherElements.containing(.any, identifier: "ActivityListView").element.descendants(matching: .button).matching(identifier: Identifiers.closeButtonOfTheUIActivityViewController).element
    }
}
