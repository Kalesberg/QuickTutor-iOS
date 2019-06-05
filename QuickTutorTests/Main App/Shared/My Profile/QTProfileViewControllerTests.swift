//
//  QTProfileViewControllerTests.swift
//  QuickTutorTests
//
//  Created by Will Saults on 4/10/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import XCTest
import CoreLocation
@testable import QuickTutor

class QTProfileViewControllerTests: XCTestCase {
    var profileViewController: QTProfileViewController!

    override func setUp() {
        super.setUp()
        
        profileViewController = QTProfileViewController()
        
        let latitude: CLLocationDegrees = 29.699375
        let longitude: CLLocationDegrees = -91.20677
        
        profileViewController.currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        profileViewController.loadViewIfNeeded()
    }

    func testFindDistanceForTheSameLocation() {
        let latitude: CLLocationDegrees = 29.699375
        let longitude: CLLocationDegrees = -91.20677
        
        let tutorLocation = TutorLocation(dictionary: ["l" : [latitude, longitude]])
        
        let actualDistance = profileViewController.findDistance(location: tutorLocation)
        
        XCTAssert(actualDistance == 0, "Distance is zero when the same location is used")
    }
    
    func testFindDistanceForDifferentLocations() {
        let latitude: CLLocationDegrees = 33.028385
        let longitude: CLLocationDegrees = -97.086720
        
        let tutorLocation = TutorLocation(dictionary: ["l" : [latitude, longitude]])
        
        let actualDistance = profileViewController.findDistance(location: tutorLocation)
        
        XCTAssertEqual(actualDistance, 416.33002345614335, "Distance matches")
    }
    
    func testFormatDistanceOfZero() {
        let actualLabelText = profileViewController.formatDistance(0)
        
        XCTAssertEqual(actualLabelText, "0 miles away", "Text matches when distance is zero")
    }
    
    func testFormatDistanceOfOne() {
        let actualLabelText = profileViewController.formatDistance(1)
        
        XCTAssertEqual(actualLabelText, "1 mile away", "Text matches when distance is one")
    }
    
    func testFormatDistanceOf432() {
        let actualLabelText = profileViewController.formatDistance(432)
        
        XCTAssertEqual(actualLabelText, "432 miles away", "Text matches when distance is 432")
    }
    
    func testFormatDistanceOf432WithDecimal() {
        let actualLabelText = profileViewController.formatDistance(432.67)
        
        XCTAssertEqual(actualLabelText, "432.7 miles away", "Text matches when distance is 432.67")
    }
    
    func testFormatDistanceOf1791() {
        let actualLabelText = profileViewController.formatDistance(1791)
        
        XCTAssertEqual(actualLabelText, "1.8k miles from you", "Text matches when distance is 1791")
    }
    
    func testFormatDistanceOf1791WithDecimal() {
        let actualLabelText = profileViewController.formatDistance(1791.21)
        
        XCTAssertEqual(actualLabelText, "1.8k miles from you", "Text matches when distance is 1791.21")
    }
    
    func testFormatDistanceOf13419() {
        let actualLabelText = profileViewController.formatDistance(13419)
        
        XCTAssertEqual(actualLabelText, "13.4k miles from you", "Text matches when distance is 13419")
    }
    
    func testFormatDistanceOf13419WithDecimal() {
        let actualLabelText = profileViewController.formatDistance(13419.55)
        
        XCTAssertEqual(actualLabelText, "13.4k miles from you", "Text matches when distance is 13419.55")
    }
}
