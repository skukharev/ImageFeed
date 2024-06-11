//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 15.05.2024.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet private weak var cellButton: UIButton!
    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var cellLabel: UILabel!

    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"

    // MARK: - Private Properties
    private var isGradientAdded = false

    // MARK: - Public Methods
    /// Производит настройки размещения ячейки таблицы в соответствии с техническим заданием
    func setupLayout() {
        cellImage.layer.cornerRadius = 16

        if isGradientAdded {
            return
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.ypBlackAlpha0.cgColor, UIColor.ypBlackAlpha20.cgColor, UIColor.ypBlackAlpha0.cgColor]
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradientLayer, at: 0)

        isGradientAdded = true
    }

    /// Выводит на экран содержимое ячейки
    /// - Parameter model: заполненная вью модель ячейки таблицы
    func showCellViewModel(_ model: ImagesListCellViewModel) {
        cellImage.image = model.image
        cellButton.setImage(model.likeButtonImage, for: .normal)
        cellLabel.text = model.dateLabel
    }
}
