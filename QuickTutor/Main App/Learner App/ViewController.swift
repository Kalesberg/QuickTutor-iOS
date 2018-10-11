//
//  ViewController.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import SnapKit
import UIKit
class ViewControllerView: BaseView {
    var view = UIView()
    override func configureView() {
        addSubview(view)
        super.configureView()

        view.backgroundColor = .red

        applyConstraints()
    }

    override func applyConstraints() {
        view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}

class ViewController: BaseViewController {
    override var contentView: ViewControllerView {
        return view as! ViewControllerView
    }

    override func loadView() {
        view = ViewControllerView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
