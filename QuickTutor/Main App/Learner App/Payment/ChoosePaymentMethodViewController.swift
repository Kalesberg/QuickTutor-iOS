//
//  ChoosePaymentMethodViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 8/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Stripe

class ChoosePaymentMethodViewController: QTBaseCustomDialog {

    var didClickBtnAddDebitOrCreditCard: ((Any) -> ())?
    var didClickBtnAddPaypal: ((Any) -> ())?
    var didClickBtnLinkApplePay: ((Any) -> ())?
    
    @IBOutlet weak var btnAddDebitOrCreditCard: UIButton!
    @IBOutlet weak var btnAddPaypal: UIButton!
    @IBOutlet weak var btnLinkApplePay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnLinkApplePay.isHidden = Stripe.deviceSupportsApplePay()
    }

    @IBAction func onClickBtnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickBtnAddDebitOrCreditCard(_ sender: Any) {
        didClickBtnAddDebitOrCreditCard?(sender)
    }
    
    @IBAction func onClickBtnAddPaypal(_ sender: Any) {
        didClickBtnAddPaypal?(sender)
    }
    
    @IBAction func onClickBtnLinkApplePay(_ sender: Any) {
        didClickBtnLinkApplePay?(sender)
    }
    
}
