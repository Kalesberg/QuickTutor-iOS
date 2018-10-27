//
//  LearnerPaymentVC2.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/27/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

//
//  Payment.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import Stripe
import UIKit

class LearnerPaymentView2: MainLayoutTitleBackButton {
	
}


class LearnerPaymentVC2: BaseViewController {
	override var contentView: LearnerPaymentView2 {
		return view as! LearnerPaymentView2
	}

	override func loadView() {
		view = LearnerPaymentView2()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
extension LearnerPaymentVC2 : STPPaymentContextDelegate {
	func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
		<#code#>
	}
	
	func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
		self.activityIndicator.animating = paymentContext.loading
		self.paymentButton.enabled = paymentContext.selectedPaymentMethod != nil
		self.paymentLabel.text = paymentContext.selectedPaymentMethod?.label
		self.paymentIcon.image = paymentContext.selectedPaymentMethod?.image
	}
	
	func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
		<#code#>
	}
	
	func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
		<#code#>
	}
	
	
}
