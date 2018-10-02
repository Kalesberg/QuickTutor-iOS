//
//  ProfileImages.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class ProfileImageScrollPopOver: BaseViewController {
    var imageView = UIImageView()
    var exitButton = UIView()

    let horizontalScrollView = UIScrollView()
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var images: [UIImage] = []
    var pageControl: UIPageControl = UIPageControl(frame: CGRect(x: 50, y: 300, width: 200, height: 50))

    override func viewDidLoad() {
        contentView.addSubview(horizontalScrollView)
        super.viewDidLoad()

        horizontalScrollView.isUserInteractionEnabled = false
        horizontalScrollView.isHidden = true

        configurePageControl()

        horizontalScrollView.delegate = self
        horizontalScrollView.isPagingEnabled = true
        horizontalScrollView.showsHorizontalScrollIndicator = false

        horizontalScrollView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.35)
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView.navbar.snp.bottom).inset(-15)
        }
        contentView.layoutIfNeeded()
        for index in 1 ..< 5 {
            let subView = UIImageView()
            if let image = LocalImageCache.localImageManager.getImage(number: String(index)) {
                subView.image = image
            } else {
                // set to some arbitrary image.
            }
            subView.scaleImage()
            horizontalScrollView.addSubview(subView)
            subView.snp.makeConstraints({ make in
                make.top.equalToSuperview()
                make.height.equalToSuperview()
                make.width.equalToSuperview()
                if index != 1 {
                    make.left.equalTo(horizontalScrollView.subviews[index - 2].snp.right)
                } else {
                    make.centerX.equalToSuperview()
                }
            })

            contentView.layoutIfNeeded()
        }

        horizontalScrollView.contentSize = CGSize(width: horizontalScrollView.frame.size.width * 4, height: horizontalScrollView.frame.size.height)
        pageControl.addTarget(self, action: #selector(changePage(sender:)), for: UIControlEvents.valueChanged)
    }

    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = Colors.learnerPurple
        view.addSubview(pageControl)

        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(horizontalScrollView.snp.bottom).inset(-10)
        }
    }

    // MARK: TO CHANGE WHILE CLICKING ON PAGE CONTROL

    @objc func changePage(sender _: AnyObject) {
        let x = CGFloat(pageControl.currentPage) * horizontalScrollView.frame.size.width
        horizontalScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    private func configureView() {
        view.addSubview(imageView)
        view.addSubview(pageControl)

        view.layer.opacity = 0.4
        view.layer.backgroundColor = UIColor.black.cgColor
    }

    private func applyConstraints() {}
}

extension ProfileImageScrollPopOver: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_: UIScrollView) {
        let pageNumber = round(horizontalScrollView.contentOffset.x / horizontalScrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}

extension ProfileImageScrollPopOver: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .overCurrentContext
    }
}
