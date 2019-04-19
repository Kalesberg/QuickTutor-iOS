//
//  ChangeEmailVCTests.swift
//  QuickTutorTests
//
//  Created by Will Saults on 4/18/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import XCTest
@testable import QuickTutor

class ChangeEmailVCTests: XCTestCase {
    var changeEmailViewController: ChangeEmailVC!
    var contentView: ChangeEmailView!

    override func setUp() {
        super.setUp()
        
        changeEmailViewController = ChangeEmailVC()
        contentView = changeEmailViewController.contentView

        changeEmailViewController.loadViewIfNeeded()
    }

    override func tearDown() {
    }

    func testLabelText() {
        XCTAssertEqual(contentView.subtitle.text, "Enter new Email address")
    }
    
    func testButtonTextText() {
        XCTAssertEqual(contentView.verifyEmailButton.title(for: .normal), "Save Email")
    }
}
