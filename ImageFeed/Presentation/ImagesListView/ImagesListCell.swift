//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 15.05.2024.
//

import Foundation
import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    // MARK: - Public Properties

    static let reuseIdentifier = "ImagesListCell"
    static let stubImageName = "ImageStub"
    static let noActiveLikeButtonName = "NoActiveLikeButton"
    static let activeLikeButtonName = "ActiveLikeButton"

    var image: UIImage? {
        return cellImage.image
    }

    // MARK: - Private Properties

    private var isLiked = false
    private var photoId: String?
    private var isGradientAdded = false
    private var activeLikeButtonImage = UIImage(named: ImagesListCell.activeLikeButtonName) ?? UIImage()
    private var noActiveLikeButtonImage = UIImage(named: ImagesListCell.noActiveLikeButtonName) ?? UIImage()

    private lazy var cellButton: UIButton = {
        let cellButton = UIButton(type: .custom)
        if isLiked {
            cellButton.setImage(activeLikeButtonImage, for: .normal)
        } else {
            cellButton.setImage(noActiveLikeButtonImage, for: .normal)
        }
        cellButton.contentHorizontalAlignment = .center
        cellButton.contentVerticalAlignment = .center
        cellButton.translatesAutoresizingMaskIntoConstraints = false
        cellButton.addTarget(self, action: #selector(cellButtonTouchUpInside), for: .touchUpInside)
        return cellButton
    }()

    private lazy var cellImage: UIImageView = {
        let cellImage = UIImageView()
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        cellImage.layer.cornerRadius = 16
        cellImage.contentMode = .scaleAspectFill
        cellImage.isOpaque = true
        cellImage.clearsContextBeforeDrawing = true
        cellImage.clipsToBounds = true
        cellImage.autoresizesSubviews = true
        return cellImage
    }()

    private lazy var gradientView: UIView = {
        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.contentMode = .scaleToFill
        gradientView.isOpaque = true
        gradientView.clearsContextBeforeDrawing = true
        gradientView.clipsToBounds = false
        gradientView.autoresizesSubviews = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.ypBlackAlpha0.cgColor, UIColor.ypBlack.cgColor, UIColor.ypBlackAlpha0.cgColor]
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        return gradientView
    }()

    private lazy var cellLabel: UILabel = {
        let cellLabel = UILabel()
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        cellLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        cellLabel.textColor = .ypWhite
        return cellLabel
    }()

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createAndLayoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    /// Производит настройки размещения ячейки таблицы в соответствии с техническим заданием
    func setupCellPresentation() {
        if isGradientAdded {
            return
        }
        contentView.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.ypBlackAlpha0.cgColor, UIColor.ypBlackAlpha20.cgColor, UIColor.ypBlackAlpha0.cgColor]
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradientLayer, at: 0)

        isGradientAdded = true
    }

    /// Выводит на экран содержимое ячейки
    /// - Parameter model: заполненная вью модель ячейки таблицы
    func showCellViewModel(_ model: ImagesListCellViewModel, handler: @escaping (Result<RetrieveImageResult, Error>) -> Void) {
        guard let stubImage = UIImage(named: ImagesListCell.stubImageName) else {
            assertionFailure("Ошибка загрузки изображения ImageStub из ресурсов проекта")
            return
        }
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: model.thumbImageUrl, placeholder: stubImage, options: [.cacheSerializer(FormatIndicatedCacheSerializer.png)]) { result in
            switch result {
            case .success(let image):
                handler(.success(image))
            case .failure(let error):
                print(#fileID, #function, #line, "Ошибка загрузки изображения ленты с url: \(String(describing: model.thumbImageUrl)), текст ошибки: \(error.localizedDescription)")
                handler(.failure(error))
            }
        }
        cellButton.setImage(model.likeButtonImage, for: .normal)
        cellLabel.text = model.dateLabel
        isLiked = model.isLiked
        photoId = model.photoId
    }

    // MARK: - Private Methods

    private func addSubviews() {
        contentView.addSubview(cellImage)
        contentView.addSubview(cellButton)
        contentView.addSubview(gradientView)
        contentView.addSubview(cellLabel)
    }

    private func createAndLayoutViews() {
        contentMode = .scaleToFill
        backgroundColor = .ypBlack
        selectionStyle = .none              // Без этого свойства отображается белая полоска при выделении ячейки
        contentView.contentMode = .center
        contentView.backgroundColor = .ypBlack
        contentView.semanticContentAttribute = .unspecified
        contentView.accessibilityRespondsToUserInteraction = true
        contentView.isMultipleTouchEnabled = true
        contentView.alpha = 1
        contentView.clearsContextBeforeDrawing = true
        contentView.clipsToBounds = true
        contentView.autoresizesSubviews = true
        addSubviews()
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Изображение
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            // Кнопка лайка
            cellButton.widthAnchor.constraint(equalToConstant: 44),
            cellButton.heightAnchor.constraint(equalToConstant: 44),
            cellButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            cellButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            // Область затенения под текстом с датой
            gradientView.heightAnchor.constraint(equalToConstant: 30),
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor),
            // Текст с датой
            cellLabel.widthAnchor.constraint(equalToConstant: 152),
            cellLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            cellLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8)
        ])
    }

    /// Обработчик нажатия кнопки "Поставить/снять лайк"
    /// - Parameter sender: объект, генерирующий событие
    @objc private func cellButtonTouchUpInside(_ sender: UIButton) {
        guard let photoId = photoId else { return }

        sender.isEnabled = false
        if #available(iOS 17.5, *) {
            let impact = UIImpactFeedbackGenerator(style: .heavy, view: self)
            impact.impactOccurred()
        } else {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }
        ImagesListService.shared.changeLike(photoId: photoId, isLike: !isLiked) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    if let self = self {
                        self.isLiked.toggle()
                        if self.isLiked {
                            self.cellButton.setImage(self.activeLikeButtonImage, for: .normal)
                        } else {
                            self.cellButton.setImage(self.noActiveLikeButtonImage, for: .normal)
                        }
                    }
                }
                print("Лайк/дизлайк успешно установлен")
            case .failure(let error):
                print(#fileID, #function, #line, "Ошибка установка/снятия лайка для фотографии, текст ошибки, \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                sender.isEnabled = true
            }
        }
    }

    // MARK: - UITableViewCell

    /// Отменяет асинхронную загрузку изображения в случае, когда ячейка готовится с сокрытию с экрана
    override func prepareForReuse() {
        super.prepareForReuse()

        cellImage.kf.cancelDownloadTask()
    }
}
