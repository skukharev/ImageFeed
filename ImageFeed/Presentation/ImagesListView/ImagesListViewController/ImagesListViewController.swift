//
//  ViewController.swift
//  imageFeed
//
//  Created by Сергей Кухарев on 05.05.2024.
//

import UIKit

final class ImagesListViewController: UIViewController, ImagesListViewPresenterDelegate {
    // MARK: - Private Properties

    private var presenter: ImagesListViewPresenterProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let defaultImageHeight: CGFloat = 224

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

        tableView.register(ImagesListCell.classForCoder(), forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.rowHeight = defaultImageHeight
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        presenter?.fetchPhotosNextPage()
    }

    // MARK: - Public Methods

    /// Используется для связи вью контроллера с презентером
    /// - Parameter presenter: презентер вью контроллера
    func configure(_ presenter: ImagesListViewPresenterProtocol) {
        self.presenter = presenter
        presenter.viewController = self
    }

    public func updateTableViewAnimated() {
        guard let presenter = presenter else { return }
        let currentNumberOfRows = tableView.numberOfRows(inSection: 0)

        tableView.performBatchUpdates {
            var indexPaths: [IndexPath] = []
            for i in currentNumberOfRows..<presenter.photosCount() {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in
        }
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

    func updateHeightOfTableViewCell(at indexPath: IndexPath) {
        // Убрал вызов из-за неприятных визуальных эффектов при скроллинге ленты, но оставил код из-за требований задачи
        // tableView.reloadRows(at: [indexPath], with: .automatic)
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
        imageListCell.delegate = self
        return imageListCell
    }

    /// Используется для конфигурирования и отображения заданной ячейки таблицы
    /// - Parameters:
    ///   - cell: Отображаемая ячейка
    ///   - indexPath: Путь индекса строки в секции таблицы
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let presenter = presenter else { return }
        presenter.showCell(for: cell, with: indexPath)
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    /// Используется для переопределения высоты заданной строки списка с фотографиями
    /// - Parameters:
    ///   - tableView: Список с фотографиями, наследник UITableView
    ///   - indexPath: Индекс строки, для которой переопределяется высота
    /// - Returns: Возвращает высоту заданной строки табличного списка
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let imageSize = presenter?.getImageSizeByIndexPath(at: indexPath) else { return defaultImageHeight }
        let imageScale = tableView.bounds.width / imageSize.width
        return imageSize.height * imageScale
    }

    /// Обработчик выделения заданной строки - отображает модальный вью контроллер с выделенной фотографией
    /// - Parameters:
    ///   - tableView: Список с фотографиями, наследник UITableView
    ///   - indexPath: Индекс выбранной пользователем строки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presenter = presenter else {
            print(#file, #line, "Презентер для ImagesListViewController не существует")
            return
        }
        let viewController = SingleImageViewController()
        viewController.imageURL = presenter.getImageDetailedURL(at: indexPath)
        present(viewController, animated: true)
    }

    /// Загрузчик следующей порции фотографий в ленту при достижении конца списка
    /// - Parameters:
    ///   - tableView: Список с фотографиями, наследник UITableView
    ///   - cell: Отображаемая ячейка табличного списка
    ///   - indexPath: Индекс ячейки табличного списка
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section != 0 || indexPath.row != tableView.numberOfRows(inSection: 0) - 2 { return }
        if ProcessInfo.processInfo.environment["TEST"] != nil { return }    // Исключение лишних запросов данных при ui-тестировании
        presenter?.fetchPhotosNextPage()
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell, _ completion: @escaping () -> Void) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            completion()
            return
        }
        presenter?.changeLike(for: indexPath.row) { result in
            switch result {
            case .success(let isLiked):
                cell.setIsLiked(photoIsLiked: isLiked)
            default: break
            }
            completion()
        }
    }
}
