//
//  ViewController.swift
//  imageFeed
//
//  Created by Сергей Кухарев on 05.05.2024.
//

import UIKit

final class ImagesListViewController: UIViewController, ImagesListViewPresenterDelegate {
    // MARK: - IB Outlets
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Private Properties
    private var presenter: ImagesListViewPresenter?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = ImagesListViewPresenter(viewController: self)

        tableView.register(UINib(nibName: ImagesListCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let presenter = presenter
            else {
                print(#fileID, #function, #line, "Неверный приёмник сегвея ShowSingleImage")
                return
            }

            let image = UIImage(named: presenter.photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate {
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = presenter?.getImageByCellIndex(row: indexPath.row) else { return 0 }

        let imageScale = tableView.bounds.width / image.size.width
        return image.size.height * imageScale
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.setupLayout()
        guard let presenter = presenter else { return }
        let cellViewModel = presenter.convert(row: indexPath.row)
        cell.showCellViewModel(cellViewModel)
    }
}
