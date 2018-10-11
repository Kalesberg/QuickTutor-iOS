//
//  TutorAgreementWebView.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class MainLayoutWebView: MainLayoutTitleBackButton {
    let webView = UIWebView()

    override func configureView() {
        addSubview(webView)
        super.configureView()

        webView.scrollView.isScrollEnabled = true
        webView.isUserInteractionEnabled = true
        webView.scalesPageToFit = true
        webView.contentMode = .scaleAspectFill
    }

    override func applyConstraints() {
        super.applyConstraints()

        webView.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

class WebViewVC: BaseViewController {
    override var contentView: MainLayoutWebView {
        return view as! MainLayoutWebView
    }

    override func loadView() {
        view = MainLayoutWebView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    var url: String = ""

    func loadAgreementPdf() {
        let url = URL(string: self.url)

        displayLoadingOverlay()
        if let unwrappedURL = url {
            let request = URLRequest(url: unwrappedURL)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { _, _, error in

                if error == nil {
                    DispatchQueue.main.async {
                        self.contentView.webView.loadRequest(request)
                        self.contentView.webView.scrollView.contentSize.width = 100
                    }
                } else {
                    self.navigationController?.popViewController(animated: true)
                    AlertController.genericErrorAlert(self, title: "Failed to Load", message: "Agreement Document failed to load, try again or visit our website")
                }
            }

            task.resume()
        }
        dismissOverlay()
    }

    private func zoomToFit() {
        let scrollView = contentView.webView.scrollView

        let zoom = contentView.webView.bounds.size.width / scrollView.contentSize.width
        scrollView.minimumZoomScale = zoom
        scrollView.setZoomScale(zoom, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.webView.scalesPageToFit = true
    }
}
