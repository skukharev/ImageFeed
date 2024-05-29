//
//  ViewController.swift
//  imageFeed
//
//  Created by Сергей Кухарев on 05.05.2024.
//

import UIKit

final class ImagesListViewController: UIViewController, ImagesListViewPresenterDelegate {
    @IBOutlet private weak var tableView: UITableView!

    private var presenter: ImagesListViewPresenter?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

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
                print("Module ImagesListViewController->func (for segue: UIStoryboardSegue, sender: Any?)) -> Неверный приёмник сегвея ShowSingleImage")
                return
            }

            let image = UIImage(named: presenter.photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate {
    /// Используется для определения количества строк в секции
    /// - Parameters:
    ///   - tableView: Список
    ///   - section: Индекс секции в списке
    /// - Returns: Возвращает количество строк в секции списка
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = presenter else { return 1 }
        return presenter.photosCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            print("Module ImagesListViewController->extension ImagesListViewController->func (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell - ошибка приведения типов")
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
