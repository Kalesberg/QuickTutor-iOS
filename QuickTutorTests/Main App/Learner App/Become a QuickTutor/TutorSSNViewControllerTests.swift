//
//  SSNViewControllerTests.swift
//  QuickTutorTests
//
//  Created by Will Saults on 4/29/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import XCTest
@testable import QuickTutor

class TutorSSNViewControllerTests: XCTestCase {
    var tutorSSNViewController: TutorSSNViewController!

    override func setUp() {
        super.setUp()
        
        tutorSSNViewController = TutorSSNViewController()
        tutorSSNViewController.loadView()
        tutorSSNViewController.viewDidLoad()
        
        tutorSSNViewController.ssnAreaNumberTextField?.text = "445"
        tutorSSNViewController.ssnGroupNumberTextField?.text = "12"
        tutorSSNViewController.ssnSerialNumberTextField?.text = "2032"
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testValidSSN() {
        let isValid = tutorSSNViewController.checkForValidSSN()
        XCTAssertTrue(isValid, "445-12-2032 results in a valid SSN number")
    }
    
    func testSSNWitoutArea() {
        tutorSSNViewController.ssnAreaNumberTextField?.text = ""
        
        let isValid = tutorSSNViewController.checkForValidSSN()
        XCTAssertFalse(isValid, "-12-2032 results in an invalid SSN number")
    }
    
    func testSSNWitoutGroup() {
        tutorSSNViewController.ssnGroupNumberTextField?.text = ""
        
        let isValid = tutorSSNViewController.checkForValidSSN()
        XCTAssertFalse(isValid, "445--2032 results in an invalid SSN number")
    }
    
    func testSSNWitoutSerial() {
        tutorSSNViewController.ssnSerialNumberTextField?.text = ""
        
        let isValid = tutorSSNViewController.checkForValidSSN()
        XCTAssertFalse(isValid, "445-12- results in an invalid SSN number")
    }
    
    func testInValidSSNArea666() {
        tutorSSNViewController.ssnAreaNumberTextField?.text = "666"
        
        let isValid = tutorSSNViewController.checkForValidSSN()
        XCTAssertFalse(isValid, "666-12-1234 results in an in-valid SSN number")
    }
    
    func testInValidSSNArea900() {
        tutorSSNViewController.ssnAreaNumberTextField?.text = "900"
        
        let isValid = tutorSSNViewController.checkForValidSSN()
        XCTAssertFalse(isValid, "900-12-1234 results in an in-valid SSN number")
    }
    
    func testInValidSSNArea990() {
        tutorSSNViewController.ssnAreaNumberTextField?.text = "990"
        
        let isValid = tutorSSNViewController.checkForValidSSN()
        XCTAssertFalse(isValid, "990-12-1234 results in an in-valid SSN number")
    }
    
    func testInValidSSNArea999() {
        tutorSSNViewController.ssnAreaNumberTextField?.text = "999"
        
        let isValid = tutorSSNViewController.checkForValidSSN()
        XCTAssertFalse(isValid, "990-12-1234 results in an in-valid SSN number")
    }
    
    func testInValidSSNAreaIs000() {
        tutorSSNViewController.ssnAreaNumberTextField?.text = "000"
        
        let isValid = tutorSSNViewController.checkForValidSSN()
        XCTAssertFalse(isValid, "000-12-2032 results in an in-valid SSN number")
    }
    
    func testInValidSSNGroupIs00() {
        tutorSSNViewController.ssnGroupNumberTextField?.text = "00"
        
        let isValid = tutorSSNViewController.checkForValidSSN()
        XCTAssertFalse(isValid, "445-00-2032 results in an in-valid SSN number")
    }
    
    func testInValidSSNSerialIs000() {
        tutorSSNViewController.ssnAreaNumberTextField?.text = "0000"
        
        let isValid = tutorSSNViewController.checkForValidSSN()
        XCTAssertFalse(isValid, "445-12-0000 results in an in-valid SSN number")
    }
}
