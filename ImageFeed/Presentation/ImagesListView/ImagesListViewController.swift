//
//  ViewController.swift
//  imageFeed
//
//  Created by Сергей Кухарев on 05.05.2024.
//

import UIKit

final class ImagesListViewController: UIViewController, ImagesListViewPresenterDelegate {
    // MARK: - Private Properties

    private var presenter: ImagesListViewPresenter?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorEffect = .none
        tableView.separatorInset = .zero
        tableView.allowsSelection = true
        tableView.alwaysBounceVertical = true
        tableView.insetsContentViewsToSafeArea = true
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.backgroundColor = .ypBlack
        return tableView
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        createAndLayoutViews()
        presenter = ImagesListViewPresenter(viewController: self)

        tableView.register(ImagesListCell.classForCoder(), forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

    // MARK: - Private Methods

    private func addSubviews() {
        view.addSubview(tableView)
    }

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

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    /// Используется для определения количества строк в секции
    /// - Parameters:
    ///   - tableView: Табличное представление со списком фото
    ///   - section: Индекс секции в списке
    /// - Returns: Возвращает количество строк в секции списка
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = presenter else { return 1 }
        return presenter.photosCount()
    }

    /// Используется для определения ячейки, которую требуется отобразить в заданной позиции табличного представления
    /// - Parameters:
    ///   - tableView: Табличное представление со списком фото
    ///   - indexPath: Путь индекса строки в списке, для которой необходимо вернуть сконфигурированную ячейку
    /// - Returns: Заполненный необходимыми данными экземпляр ImagesListCell, отображающий ячейку с фото из Unsplash
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            print(#fileID, #function, #line, "Ошибка приведения типов")
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }

    /// Используется для конфигурирования и отображения заданной ячейки таблицы
    /// - Parameters:
    ///   - cell: Отображаемая ячейка
    ///   - indexPath: Путь индекса строки в секции таблицы
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.setupCellPresentation()
        guard let presenter = presenter else { return }
        let cellViewModel = presenter.convert(row: indexPath.row)
        cell.showCellViewModel(cellViewModel)
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = presenter?.getImageByCellIndex(row: indexPath.row) else { return 0 }

        let imageScale = tableView.bounds.width / image.size.width
        return image.size.height * imageScale
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = SingleImageViewController()
        guard let presenter = presenter else {
            assertionFailure("Ошибка инициализации ImagesListViewPresenter")
            return
        }
        let image = UIImage(named: presenter.photosName[indexPath.row])
        viewController.image = image
        present(viewController, animated: true)
    }
}
