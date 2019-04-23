//
//  TutorBioVCTests.swift
//  QuickTutorTests
//
//  Created by Will Saults on 4/22/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import XCTest
@testable import QuickTutor

class TutorBioVCTests: XCTestCase {
    var tutorBioVC: TutorBioVC!

    override func setUp() {
        super.setUp()
        
        tutorBioVC = TutorBioVC()
    }
    
    func testBioIsCorrect() {
        tutorBioVC.contentView.textView.text = "Lorem ipsum dolo"
        
        let isBioCorrect = tutorBioVC.isBioCorrectLength()
        
        XCTAssertTrue(isBioCorrect, "Bio should be correct")
        XCTAssertTrue(tutorBioVC.contentView.errorLabel.isHidden, "Bio error should not be visible")
    }
    
    func testBioBecomesCorrect() {
        tutorBioVC.contentView.textView.text = "Lorem ipsum dolo"
        
        var isBioCorrect = tutorBioVC.isBioCorrectLength(didTapNext: true)
        XCTAssertFalse(isBioCorrect, "Bio should not be correct")
        
        tutorBioVC.contentView.textView.text = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit."
        
        isBioCorrect = tutorBioVC.isBioCorrectLength()
        
        XCTAssertTrue(isBioCorrect, "Bio should be correct")
        XCTAssertTrue(tutorBioVC.contentView.errorLabel.isHidden, "Bio error should not be visible")
    }
    
    func testBioIsCorrectWhenLessThan501Characters() {
        tutorBioVC.contentView.textView.text = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa"
        
        let isBioCorrect = tutorBioVC.isBioCorrectLength()
        
        XCTAssertTrue(isBioCorrect, "Bio should be correct")
        XCTAssertTrue(tutorBioVC.contentView.errorLabel.isHidden, "Bio error should not be visible")
    }

    func testBioErrorMessageAppearsWhenTextIsMoreThan500Characters() {
        tutorBioVC.contentView.textView.text = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus"
        
        let isBioCorrect = tutorBioVC.isBioCorrectLength()
        
        XCTAssertFalse(isBioCorrect, "Bio should not be correct")
        XCTAssertEqual(tutorBioVC.contentView.errorLabel.text, "Bio can not exceed 500 characters", "Bio error text should match")
        XCTAssertFalse(tutorBioVC.contentView.errorLabel.isHidden, "Bio error should be visible")
    }
    
    func testLessThan20CharactersErrorMessageAppearsWhenUserTapsNext() {
        tutorBioVC.contentView.textView.text = "Lorem ipsum dolor s"
        
        let isBioCorrect = tutorBioVC.isBioCorrectLength(didTapNext: true)
        
        XCTAssertFalse(isBioCorrect, "Bio should not be correct")
        XCTAssertEqual(tutorBioVC.contentView.errorLabel.text, "Bio must be at least 20 characters", "Bio error text should match")
        XCTAssertFalse(tutorBioVC.contentView.errorLabel.isHidden, "Bio error should be visible")
    }
}
