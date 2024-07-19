//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Сергей Кухарев on 18.07.2024.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    /// Проверяет, вызывает ли ProfileViewController метод презентера loadProfileData() для загрузки профиля пользователя из Сети
    func testViewControllerCallsLoadProfileData() throws {
        // given
        let sut = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        sut.configure(presenter)

        // when
        _ = sut.view

        // then
        XCTAssertTrue(presenter.isLoadProfileDataCalled)
    }

    /// Проверяет, вызывает ли ProfileViewController метод презентера didLogoutButtonPressed для выхода пользователя из профиля
    func testViewControllerCallsLogoutButtonPressedEvent() throws {
        // given
        let sut = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        sut.configure(presenter)
        let button = UIButton()

        // when
        _ = sut.view
        sut.exitButonTouchUpInside(button)

        // then
        XCTAssertTrue(presenter.isLogoutButtonPressCalled)
    }

    /// Проверяет. вызывает ли ProfileViewPresenter метод вью контроллера updateAvatar для загрузки изображения профиля пользователя после пол
    func testViewPresenterCallsUpdateAvatar() throws {
        // given
        let viewController = ProfileViewControllerSpy()
        let sut = ProfileViewPresenter()
        sut.viewController = viewController
        let avatarURL: String? = "https://practicum.yandex.ru"

        // when
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": avatarURL as Any])

        // then
        XCTAssertTrue(viewController.isUpdateAvatarCalled)
    }

    /// Проверяет, вызвает ли ProfileViewPresenter после успешной загрузки данных профиля пользователя из Сети метод showUserData вью контроллера для отображения данных
    func testViewPresenterCallsShowUserData() throws {
        // given
        let expectation = expectation(description: "testViewPresenterCallsShowUserData()")
        let viewController = ProfileViewControllerSpy()
        viewController.showUserDataExpectation = expectation
        let sut = ProfileViewPresenter()
        sut.viewController = viewController

        // when
        sut.loadProfileData()

        // then
        waitForExpectations(timeout: 3)
        XCTAssertTrue(viewController.isShowUserDataCalled)
    }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    weak var viewController: ProfileViewPresenterDelegate?
    var isLoadProfileDataCalled = false
    var isLogoutButtonPressCalled = false

    func didLogoutButtonPressed() {
        isLogoutButtonPressCalled = true
    }

    func loadProfileData() {
        isLoadProfileDataCalled = true
    }
}

final class ProfileViewControllerSpy: ProfileViewPresenterDelegate {
    var isUpdateAvatarCalled = false
    var isShowUserDataCalled = false
    var showUserDataExpectation: XCTestExpectation?

    func showUserData(userProfile: ImageFeed.UnsplashCurrentUserProfile) {
        isShowUserDataCalled = true
    }

    func updateAvatar(withURL url: URL) {
        isUpdateAvatarCalled = true
        showUserDataExpectation?.fulfill()
    }

    func showAlert(_ alert: UIAlertController) {
    }

    func didProfileLogout() {
    }
}
