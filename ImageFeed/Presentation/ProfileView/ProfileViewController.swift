//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 18.05.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    // MARK: - Public Properties

    weak var delegate: ProfileViewControllerDelegate?

    // MARK: - Private Properties

    /// Фото профиля
    private lazy var profilePhoto: UIImageView = {
        let profilePhoto = UIImageView()
        profilePhoto.image = UIImage(named: "ProfilePhoto") ?? UIImage()
        profilePhoto.translatesAutoresizingMaskIntoConstraints = false
        return profilePhoto
    }()

    /// Кнопка выхода из профиля
    private lazy var exitButton: UIButton = {
        let exitButton = UIButton(type: .system)
        exitButton.setImage(UIImage(named: "ExitButton"), for: .normal)
        exitButton.tintColor = .ypRed
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.addTarget(self, action: #selector(exitButonTouchUpInside), for: .touchUpInside)
        return exitButton
    }()

    /// Имя пользователя
    private lazy var userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.textColor = .ypWhite
        userNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return userNameLabel
    }()

    /// Логин пользователя
    private lazy var userLoginLabel: UILabel = {
        let userLoginLabel = UILabel()
        userLoginLabel.textColor = .ypGray
        userLoginLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        userLoginLabel.text = "@ekaterina_nov"
        userLoginLabel.translatesAutoresizingMaskIntoConstraints = false
        return userLoginLabel
    }()

    /// Комментарии пользователя
    private lazy var userCommentsLabel: UILabel = {
        let userCommentsLabel = UILabel()
        userCommentsLabel.textColor = .ypWhite
        userCommentsLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        userCommentsLabel.text = "Hello, world!"
        userCommentsLabel.translatesAutoresizingMaskIntoConstraints = false
        return userCommentsLabel
    }()

    private var profilePhotoGradient: CAGradientLayer?
    private var userNameLabelGradient: CAGradientLayer?
    private var userLoginLabelGradient: CAGradientLayer?
    private var userCommentsLabelGradient: CAGradientLayer?

    private var presenter: ProfileViewPresenter?

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = ProfileViewPresenter(viewController: self)
        createAndLayoutViews()
        presenter?.loadProfileData()
    }

    // MARK: - Private Methods

    /// Создаёт элементы управления в контроллере профиля пользователя
    private func addSubviews() {
        view.addSubview(profilePhoto)
        view.addSubview(exitButton)
        view.addSubview(userNameLabel)
        view.addSubview(userLoginLabel)
        view.addSubview(userCommentsLabel)
    }

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .ypBlack
        addSubviews()
        setupConstraints()
        setupAnimations()
    }

    /// Создаёт градиент для заданного визуального элемента с заданным радиусом скругления
    /// - Parameters:
    ///   - view: Элемент управления, для которого создаётся градиент
    ///   - withCornerRadius: Радиус скругления градиента
    /// - Returns: Слой с градиентом
    private func addGradientToView(_ view: UIView, withCornerRadius: CGFloat) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        view.layoutIfNeeded()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: view.frame.height))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = withCornerRadius
        gradient.masksToBounds = true
        view.layer.addSublayer(gradient)

        return gradient
    }

    /// Обработчик нажатия кнопки "Выйти из профиля"
    /// - Parameter sender: объект, генерирующий событие
    @objc private func exitButonTouchUpInside(_ sender: UIButton) {
        if #available(iOS 17.5, *) {
            let impact = UIImpactFeedbackGenerator(style: .heavy, view: self.view)
            impact.impactOccurred()
        } else {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }

        let alert = UIAlertController(title: "Пока, пока!", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter?.logoutProfile()
            self?.delegate?.didProfileLogout(self)
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        alert.preferredAction = alert.actions[safe: 1]
        self.present(alert, animated: true)
    }

    /// Добавляет градиенты и их анимацию к элементам управления
    private func setupAnimations() {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]

        profilePhotoGradient = addGradientToView(profilePhoto, withCornerRadius: 35)
        profilePhotoGradient?.add(gradientChangeAnimation, forKey: "profilePhotoGradient")

        userNameLabelGradient = addGradientToView(userNameLabel, withCornerRadius: 9)
        userNameLabelGradient?.add(gradientChangeAnimation, forKey: "userNameLabelGradient")

        userLoginLabelGradient = addGradientToView(userLoginLabel, withCornerRadius: 9)
        userLoginLabelGradient?.add(gradientChangeAnimation, forKey: "userLoginLabelGradient")

        userCommentsLabelGradient = addGradientToView(userCommentsLabel, withCornerRadius: 9)
        userLoginLabelGradient?.add(gradientChangeAnimation, forKey: "userLoginLabelGradient")
    }

    /// Создаёт и размещает элементы управления в контроллере профиля пользователя
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Фото профиля
            profilePhoto.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profilePhoto.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            profilePhoto.widthAnchor.constraint(equalToConstant: 70),
            profilePhoto.heightAnchor.constraint(equalToConstant: 70),
            // Кнопка выхода из профиля
            exitButton.centerYAnchor.constraint(equalTo: profilePhoto.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            // Имя пользователя
            userNameLabel.topAnchor.constraint(equalTo: profilePhoto.bottomAnchor, constant: 8),
            userNameLabel.leftAnchor.constraint(equalTo: profilePhoto.leftAnchor),
            // Логин пользователя
            userLoginLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            userLoginLabel.leftAnchor.constraint(equalTo: profilePhoto.leftAnchor),
            // Комментарии пользователя
            userCommentsLabel.topAnchor.constraint(equalTo: userLoginLabel.bottomAnchor, constant: 8),
            userCommentsLabel.leftAnchor.constraint(equalTo: profilePhoto.leftAnchor)
        ])
    }
}

// MARK: - ProfileViewPresenterDelegate

extension ProfileViewController: ProfileViewPresenterDelegate {
    func showLoadingProfileError(withError: Error) {
        UIBlockingProgressHUD.dismiss()

        let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось получить данные профиля пользователя", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    func showUserData(userProfile: UnsplashCurrentUserProfile) {
        UIBlockingProgressHUD.dismiss()
        userNameLabelGradient?.removeFromSuperlayer()
        userLoginLabelGradient?.removeFromSuperlayer()
        userCommentsLabelGradient?.removeFromSuperlayer()

        userNameLabel.text = userProfile.firstName
        if let lastName = userProfile.lastName {
            userNameLabel.text?.append(contentsOf: " " + lastName)
        }
        userLoginLabel.text = "@" + userProfile.username
        userCommentsLabel.text = userProfile.bio ?? ""
    }

    func updateAvatar(withURL url: URL) {
        guard let imagePlaceholder = UIImage(named: "ProfilePlaceholder") else {
            assertionFailure("Ошибка загрузки изображения ProfilePlaceholder из ресурсов проекта")
            return
        }

        UIBlockingProgressHUD.show()
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        profilePhoto.kf.indicatorType = .activity
        profilePhoto.kf.setImage(with: url, placeholder: imagePlaceholder, options: [.processor(processor), .cacheSerializer(FormatIndicatedCacheSerializer.png)]) { result in
            UIBlockingProgressHUD.dismiss()
            self.profilePhotoGradient?.removeFromSuperlayer()

            switch result {
            case .success: break
            case .failure(let error):
                print(#fileID, #function, #line, "Ошибка загрузки изображения профиля с url: \(url), текст ошибки: \(error.localizedDescription)")
            }
        }
    }
}
