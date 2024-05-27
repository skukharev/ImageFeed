//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 19.05.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var shareImageButton: UIButton!

    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            guard let image = image else { return }
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        guard let image = image else { return }
        imageView.frame.size = image.size
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: image)
    }

    @IBAction func backButtonTouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
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
    }

    @IBAction func shareImageButtonTouchUpInside(_ sender: Any) {
        guard let image = imageView.image else { return }
        let items = [image]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityController, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView.bounds.width > imageView.frame.width {
            scrollView.contentInset.left = (scrollView.bounds.width - imageView.frame.width) / 2
        }
        if scrollView.bounds.height > imageView.frame.height {
            scrollView.contentInset.top = (scrollView.bounds.height - imageView.frame.height) / 2
        }
    }
}
