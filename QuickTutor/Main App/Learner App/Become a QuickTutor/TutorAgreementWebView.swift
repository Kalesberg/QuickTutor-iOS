//
//  TutorAgreementWebView.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorAgreementWebView : MainLayoutTitleBackButton {
    
    let webView = UIWebView()
    
    override func configureView() {
        addSubview(webView)
        super.configureView()
        
        title.label.text = "Tutor Agreement"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.centerX.equalToSuperview()
        }
    }
}


class TutorAgreementWebVC : BaseViewController {
    
    override var contentView: TutorAgreementWebView {
        return view as! TutorAgreementWebView
    }
    
    override func loadView() {
        view = TutorAgreementWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAgreementPdf()
    }
    
    func loadAgreementPdf() {
        let url = URL(string: "https://quicktutor.now.sh/ita.pdf")
        
        displayLoadingOverlay()
        if let unwrappedURL = url {
            
            let request = URLRequest(url: unwrappedURL)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if error == nil {
                    DispatchQueue.main.async {
                        self.contentView.webView.loadRequest(request)
                    }
                } else {
                    self.navigationController?.popViewController(animated: true)
                    AlertController.genericErrorAlert(self, title: "Failed to Load", message: "Agreement Document failed to load, try again or visit our website")
                }
            }
            
            task.resume()
        }
        dismissOverlay()
        print("loaded url")
    }
}
