//
//  CardManagerViewControllerTests.swift
//  QuickTutorTests
//
//  Created by Will Saults on 5/2/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import XCTest
@testable import QuickTutor

class CardManagerViewControllerTests: XCTestCase {
    
    var cardManagerViewController: CardManagerViewController!
    
    override func setUp() {
        super.setUp()
        
        cardManagerViewController = CardManagerViewController()
        cardManagerViewController.loadView()
    }
    
    func _testCopy() {
        XCTAssertEqual(cardManagerViewController.noPaymentLabel?.text, "No Payment Method", "No payment label copy matches")
        
        XCTAssertEqual(cardManagerViewController.infoLabel?.text, "To enter sessions, please add a payment method.\nYou will not be charged until you enter a session.\n\nThere are no subscriptions or upfront payments.\nYou only pay for time you need, at a minute-by-minute basis.", "Info label copy should match")
        
        XCTAssertEqual(cardManagerViewController.feeLabel?.text, "You will pay a 10% processing fee for every session you participate in.", "Fee label copy should match")
    }
}
