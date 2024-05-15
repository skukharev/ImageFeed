//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 15.05.2024.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    private var isGradientAdded = false

    @IBOutlet private weak var cellButton: UIButton!
    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var cellLabel: UILabel!

    /// Производит настройки размещения ячейки таблицы в соответствии с техническим заданием
    func setupLayout() {
        cellImage.layer.cornerRadius = 16

        if isGradientAdded {
            return
        }
        let colors = [UIColor.ypBlackAlpha0.cgColor, UIColor.ypBlackAlpha20.cgColor, UIColor.ypBlackAlpha0.cgColor]

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
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
