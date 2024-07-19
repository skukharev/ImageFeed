//
//  ImagesListViewTests.swift
//  ImageFeedTests
//
//  Created by Сергей Кухарев on 19.07.2024.
//

@testable import ImageFeed
import XCTest

final class ImagesListViewTests: XCTestCase {
    /// Проверяет, вызывает ли вью контроллер при инициализации метод презентера fetchPhotosNextPage() для загрузки данных из Сети
    func testViewControllerCallsFetchPhotosNextPage() throws {
        // given
        let sut = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        sut.configure(presenter)

        // when
        _ = sut.view

        // then
        XCTAssertTrue(presenter.isFetchPhotosNextPageCalled)
    }

    /// Проверяет, загружает ли презентер первую порцию фотографий из Сети
    func testViewPresenterLoadsPhoto() throws {
        // given
        let sut = ImagesListViewPresenter()
        let expectation = expectation(description: "testViewPresenterLoadsPhoto()")
        var photosCount = 0

        // when
        sut.fetchPhotosNextPage()
        NotificationCenter.default.addObserver(forName: ImagesListService.didChangeNotification, object: nil, queue: .main) { notification in
            guard let photos = notification.userInfo?["Photos"] as? [Photo] else { return }
            photosCount = photos.count
            expectation.fulfill()
        }

        // then
        waitForExpectations(timeout: 4)
        XCTAssertGreaterThanOrEqual(photosCount, 0)
    }

    /// Проверяет, вызывает ли презентер метод updateTableViewAnimated контроллера для обновления табличного представления новой порцией загруженных данных из Сети
    func testViewPresenterCallsUpdateTableViewAnimated() throws {
        // given
        let viewController = ImagesListViewControllerSpy()
        let sut = ImagesListViewPresenter()
        sut.viewController = viewController
        let photos: [Photo] = []

        // when
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self, userInfo: ["Photos": photos as Any])

        // then
        XCTAssertTrue(viewController.isUpdateTableViewAnimatedCalled)
    }
}

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var viewController: (any ImageFeed.ImagesListViewPresenterDelegate)?
    var isFetchPhotosNextPageCalled = false

    func changeLike(for row: Int, _ completion: @escaping (Result<Bool, any Error>) -> Void) {
    }

    func fetchPhotosNextPage() {
        isFetchPhotosNextPageCalled = true
    }

    func getImageDetailedURL(at indexPath: IndexPath) -> URL? {
        return nil
    }

    func getImageSizeByIndexPath(at indexPath: IndexPath) -> CGSize {
        return CGSize()
    }

    func photosCount() -> Int {
        return 0
    }

    func showCell(for cell: ImageFeed.ImagesListCell, with indexPath: IndexPath) {
    }
}

final class ImagesListViewControllerSpy: ImagesListViewPresenterDelegate {
    var isUpdateTableViewAnimatedCalled = false

    func updateTableViewAnimated() {
        isUpdateTableViewAnimatedCalled = true
    }

    func updateHeightOfTableViewCell(at indexPath: IndexPath) {
    }
}
