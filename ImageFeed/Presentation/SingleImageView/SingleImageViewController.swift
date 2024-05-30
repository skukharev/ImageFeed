//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 19.05.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var shareImageButton: UIButton!

    // MARK: - Public Properties
    /// Детальное изображение
    var image: UIImage? {
        didSet {
            guard
                isViewLoaded,
                let image = image
            else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        guard let image = image else { return }
        imageView.frame.size = image.size
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: image)
    }

    // MARK: - IB Actions
    /// Обработчик нажатия кнопки "Поделиться изображением"
    /// - Parameter sender: объект, генерирующий событие
    @IBAction private func shareImageButtonTouchUpInside(_ sender: Any) {
        guard let image = imageView.image else { return }
        let items = [image]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityController, animated: true)
    }

    /// Закрывает модальное окно с детальным изображением
    /// - Parameter sender: объект, вызывающий событие
    @IBAction private func backButtonTouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Private Methods
    /// Подгоняет размер и положение изображения в окне детального просмотра
    /// - Parameter image: Изображение
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    /// Используется для определения визуального объекта, который требуется масштабировать внутри scroll-view
    /// - Parameter scrollView: scroll-view, отображающий изображение
    /// - Returns: Возвращает UIImageView с детальным изображнием, который масштабируется внутри scroll-view.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    /// Обработчик окончания масштабирования содержимого scroll-view
    /// - Parameters:
    ///   - scrollView: scroll-view, отображающий изображение
    ///   - view: контроллер изображения
    ///   - scale: текущий масштаб
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView.bounds.width > imageView.frame.width {
            scrollView.contentInset.left = (scrollView.bounds.width - imageView.frame.width) / 2
        }
        if scrollView.bounds.height > imageView.frame.height {
            scrollView.contentInset.top = (scrollView.bounds.height - imageView.frame.height) / 2
        }
    }
}
