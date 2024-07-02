//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 19.05.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
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

    // MARK: - Private Properties

    private lazy var backButton: UIButton = {
        let backButton = UIButton(type: .custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.contentHorizontalAlignment = .center
        backButton.contentVerticalAlignment = .center
        backButton.addTarget(self, action: #selector(backButtonTouchUpInside), for: .touchUpInside)
        return backButton
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.indicatorStyle = .default
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isScrollEnabled = true
        scrollView.bouncesZoom = true
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        return scrollView
    }()

    private lazy var shareImageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ShareButton"), for: .normal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(shareImageButtonTouchUpInside), for: .touchUpInside)
        return button
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.autoresizesSubviews = true
        return imageView
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        createAndLayoutViews()
        showImage()
    }

    // MARK: - IBAction

    /// Обработчик нажатия кнопки "Поделиться изображением"
    /// - Parameter sender: объект, генерирующий событие
    @objc private func shareImageButtonTouchUpInside() {
        guard let image = imageView.image else { return }
        let items = [image]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityController, animated: true)
    }

    // MARK: - Private Methods

    /// Добавляет элементы управления на вью контроллер
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(shareImageButton)
    }

    /// Закрывает модальное окно с детальным изображением
    @objc private func backButtonTouchUpInside() {
        dismiss(animated: true, completion: nil)
    }

    /// Создаёт и размещает элементы управления на вью контроллере
    private func createAndLayoutViews() {
        view.contentMode = .scaleToFill
        view.backgroundColor = .ypBlack
        view.isOpaque = true
        view.clearsContextBeforeDrawing = true
        view.clipsToBounds = false
        view.autoresizesSubviews = true
        addSubviews()
        setupConstraints()
    }

    /// Подгоняет размер и положение изображения в окне детального просмотра
    /// - Parameter image: Изображение
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        scrollView.layoutIfNeeded()                      //Без вызова метода scrollView.bounds.size будет 0
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
        if scrollView.bounds.width > imageView.frame.width {
            scrollView.contentInset.left = (scrollView.bounds.width - imageView.frame.width) / 2
        }
        if scrollView.bounds.height > imageView.frame.height {
            scrollView.contentInset.top = (scrollView.bounds.height - imageView.frame.height) / 2
        }
    }

    /// Размещает элементы управления на вью контроллере
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // Изображение
            imageView.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            // Кнопка "Назад"
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            // Кнопка "Поделиться"
            shareImageButton.widthAnchor.constraint(equalToConstant: 51),
            shareImageButton.heightAnchor.constraint(equalToConstant: 51),
            shareImageButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            shareImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        let imageViewWidthConstraint = imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        imageViewWidthConstraint.priority = UILayoutPriority(rawValue: 250)
        imageViewWidthConstraint.isActive = true
        let imageViewHeightConstraint = imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        imageViewHeightConstraint.priority = UILayoutPriority(rawValue: 250)
        imageViewHeightConstraint.isActive = true
    }

    /// Отображает изображение на вью контроллере
    private func showImage() {
        imageView.image = image
        guard let image = image else { return }
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
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
