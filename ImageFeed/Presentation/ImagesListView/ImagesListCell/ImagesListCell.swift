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
    static let cellImageAnimationKey = "CellImageAnimationLocations"

    var image: UIImage? {
        return cellImage.image
    }

    weak var delegate: ImagesListCellDelegate?

    // MARK: - Private Properties

    private var isGradientAdded = false
    private var activeLikeButtonImage = UIImage(named: ImagesListCell.activeLikeButtonName) ?? UIImage()
    private var noActiveLikeButtonImage = UIImage(named: ImagesListCell.noActiveLikeButtonName) ?? UIImage()
    private var cellImageGradient: CAGradientLayer?
    private var cellImageGradientAnimation: CABasicAnimation?

    private lazy var cellButton: UIButton = {
        let cellButton = UIButton(type: .custom)
        setIsLiked(photoIsLiked: false)
        cellButton.contentHorizontalAlignment = .center
        cellButton.contentVerticalAlignment = .center
        cellButton.translatesAutoresizingMaskIntoConstraints = false
        cellButton.addTarget(self, action: #selector(cellButtonTouchUpInside), for: .touchUpInside)
        cellButton.addTarget(self, action: #selector(cellButtonTouchDown), for: .touchDown)
        cellButton.addTarget(self, action: #selector(cellButtonTouchUpOutside), for: .touchUpOutside)
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
        contentView.layoutIfNeeded()

        if let gradient = cellImageGradient {
            let cellImageAnimation = CABasicAnimation(keyPath: "locations")
            cellImageAnimation.duration = 1.0
            cellImageAnimation.repeatCount = .infinity
            cellImageAnimation.fromValue = [0, 0.1, 0.3]
            cellImageAnimation.toValue = [0, 0.8, 1]

            gradient.frame = CGRect(origin: .zero, size: CGSize(width: cellImage.frame.width, height: cellImage.frame.height))
            cellImage.layer.addSublayer(gradient)
            gradient.add(cellImageAnimation, forKey: ImagesListCell.cellImageAnimationKey)
        }

        if isGradientAdded {
            return
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.ypBlackAlpha0.cgColor, UIColor.ypBlackAlpha20.cgColor, UIColor.ypBlackAlpha0.cgColor]
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradientLayer, at: 0)

        isGradientAdded = true
    }

    /// Устанавливает изображение кнопки установки/снятия лайка в соответствии состоянием фотографии в Unsplash
    /// - Parameter photoIsLiked: Состояние лайка фотографии в Unsplash
    func setIsLiked(photoIsLiked: Bool) {
        DispatchQueue.main.async {
            let cellButtonImage = photoIsLiked ? self.activeLikeButtonImage : self.noActiveLikeButtonImage
            self.cellButton.setImage(cellButtonImage, for: .normal)
        }
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
            self.cellImage.layer.removeAnimation(forKey: ImagesListCell.cellImageAnimationKey)
            self.cellImageGradient?.removeFromSuperlayer()
            switch result {
            case .success(let image):
                handler(.success(image))
            case .failure(let error):
                print(#fileID, #function, #line, "Ошибка загрузки изображения ленты с url: \(String(describing: model.thumbImageUrl)), текст ошибки: \(error.localizedDescription)")
                handler(.failure(error))
            }
        }
        setIsLiked(photoIsLiked: model.isLiked)
        cellLabel.text = model.dateLabel
}

    // MARK: - Private Methods

    /// Добавляет элементы управления на вью контроллер
    private func addSubviews() {
        contentView.addSubview(cellImage)
        contentView.addSubview(cellButton)
        contentView.addSubview(gradientView)
        contentView.addSubview(cellLabel)
    }

    /// Обработчик нажатия на кнопку "Поставить/снять лайк"
    /// - Parameter sender: объект, генерирующий событие
    @objc private func cellButtonTouchDown(_ sender: UIButton) {
        UIView.animateKeyframes(withDuration: 0.2, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                sender.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
        }
    }

    /// Обработчик отжатия кнопки "Поставкить/снять лайк" вне границ кнопки
    /// - Parameter sender: объект, генерирующий событие
    @objc private func cellButtonTouchUpOutside(_ sender: UIButton) {
        UIView.animateKeyframes(withDuration: 0.2, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                sender.transform = .identity
            }
        }
    }

    /// Обработчик нажатия кнопки "Поставить/снять лайк"
    /// - Parameter sender: объект, генерирующий событие
    @objc private func cellButtonTouchUpInside(_ sender: UIButton) {
        UIView.animateKeyframes(withDuration: 0.2, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                sender.transform = .identity
            }
        }
        guard let delegate = delegate else { return }

        sender.isEnabled = false
        if #available(iOS 17.5, *) {
            let impact = UIImpactFeedbackGenerator(style: .heavy, view: self)
            impact.impactOccurred()
        } else {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }
        UIBlockingProgressHUD.show()
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: [.repeat]) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                sender.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
                sender.transform = .identity
            }
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.2) {
                sender.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.2) {
                sender.transform = .identity
            }
        }
        delegate.imageListCellDidTapLike(self) {
            DispatchQueue.main.async {
                sender.layer.removeAllAnimations()
                UIBlockingProgressHUD.dismiss()
                sender.isEnabled = true
            }
        }
    }

    /// Добавляет элементы управления и их констрейнты на вью контроллере
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

        cellImageGradient = CAGradientLayer()
        if let gradient = cellImageGradient {
            gradient.frame = CGRect(origin: .zero, size: CGSize(width: cellImage.frame.width, height: cellImage.frame.height))
            gradient.locations = [0, 0.1, 0.3]
            gradient.colors = [
                UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
                UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
                UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.cornerRadius = 16
            gradient.masksToBounds = true
        }
    }

    /// Инициализирует констрейнты элементов управления вью контроллера
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

    // MARK: - UITableViewCell

    /// Отменяет асинхронную загрузку изображения в случае, когда ячейка готовится с сокрытию с экрана
    override func prepareForReuse() {
        super.prepareForReuse()

        cellImage.kf.cancelDownloadTask()
        cellImage.layer.removeAnimation(forKey: ImagesListCell.cellImageAnimationKey)
        cellImageGradient?.removeFromSuperlayer()
    }
}
