//
//  OnlineStatusServiceTests.swift
//  QuickTutorTests
//
//  Created by Will Saults on 4/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import XCTest
@testable import QuickTutor

class OnlineStatusServiceTests: XCTestCase {
    var onlineStatusService: OnlineStatusService!
    let offlineStatus = UserStatusType.offline
    let onlineStatus = UserStatusType.online

    override func setUp() {
        super.setUp()
        onlineStatusService = OnlineStatusService.shared
    }

    func testIsActiveBecomesTrueWhenUserIsOnlineAtLessThanAMinute() {
        _ = onlineStatusService.updateActiveStatus(seconds: 0, status: onlineStatus)
        XCTAssertTrue(onlineStatusService.isActive, "isActive should be true when user isOnline and duration is less than a minute")
    }
    
    func testIsActiveBecomesTrueWhenUserIsOnlineAtMoreThanAMinute() {
        _ = onlineStatusService.updateActiveStatus(seconds: 90, status: onlineStatus)
        XCTAssertTrue(onlineStatusService.isActive, "isActive should be true when user isOnline and duration is more than a minute")
    }
    
    func testReturnsActiveNowWhenStatusIsNilAtLessThanAMinute() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 30, status: onlineStatus)
        XCTAssertEqual(actual, "Active now", "Return value matches")
    }
    
    func testReturnsActiveNowWhenUserIsOnlineAtLessThanAMinute() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 59, status: onlineStatus)
        XCTAssertEqual(actual, "Active now", "Return value matches")
    }
    
    func testIsActiveBecomesFalseWhenNotOnlineLessThanOneMinute() {
        onlineStatusService.isActive = true
        _ = onlineStatusService.updateActiveStatus(seconds: 30, status: offlineStatus)
        XCTAssertFalse(onlineStatusService.isActive, "isActive should be false when user is not online and duration is less than a minute")
     }
    
    func testReturnsJustNowWhenUserIsNotOnlineAtLessThanAMinute() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 59, status: offlineStatus)
        XCTAssertEqual(actual, "Just now", "Return value matches")
    }
    
    func testIsActiveBecomesFalseWhenNotOnlineAMinuteOrMoreAndLessThanOneHour() {
        onlineStatusService.isActive = true
        _ = onlineStatusService.updateActiveStatus(seconds: 60, status: offlineStatus)
        XCTAssertFalse(onlineStatusService.isActive, "isActive should be false when user is away for more than a minute and less than an hour")
    }
    
    func testReturnsActive1MinAgoWhenUserIsAwayFor80Seconds() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 80, status: offlineStatus)
        XCTAssertEqual(actual, "Active 1 min ago", "Return value matches")
    }
    
    func testReturnsActive2MinsAgoWhenUserIsAwayFor120Seconds() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 120, status: offlineStatus)
        XCTAssertEqual(actual, "Active 2 mins ago", "Return value matches")
    }
    
    func testReturnsActive59MinsAgoWhenUserIsAwayFor3599Seconds() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 3599, status: offlineStatus)
        XCTAssertEqual(actual, "Active 59 mins ago", "Return value matches")
    }
    
    func testIsActiveBecomesFalseWhenNotOnlineAnHourAgo() {
        onlineStatusService.isActive = true
        _ = onlineStatusService.updateActiveStatus(seconds: 3600, status: offlineStatus)
        XCTAssertFalse(onlineStatusService.isActive, "isActive should be false when user is away for more than an hour and less than a day")
    }
    
    func testReturnsActive1HourAgoWhenUserIsAwayFor3600Seconds() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 3600, status: offlineStatus)
        XCTAssertEqual(actual, "Active 1 hour ago", "Return value matches")
    }
    
    func testReturnsActive2HoursAgoWhenUserIsAwayFor7200Seconds() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 7200, status: offlineStatus)
        XCTAssertEqual(actual, "Active 2 hours ago", "Return value matches")
    }
    
    func testReturnsActive23HoursAgoWhenUserIsAwayFor86399Seconds() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 86399, status: offlineStatus)
        XCTAssertEqual(actual, "Active 23 hours ago", "Return value matches")
    }

    func testIsActiveBecomesFalseWhenNotOnlineADayAgo() {
        onlineStatusService.isActive = true
        _ = onlineStatusService.updateActiveStatus(seconds: 86400, status: offlineStatus)
        XCTAssertFalse(onlineStatusService.isActive, "isActive should be false when user is away for more than a day")
    }
    
    func testReturnsActive1DayAgoWhenUserIsAwayFor86400Seconds() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 86400, status: offlineStatus)
        XCTAssertEqual(actual, "Active 1 day ago", "Return value matches")
    }
    
    func testReturnsActive2DaysAgoWhenUserIsAwayFor172800Seconds() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 172800, status: offlineStatus)
        XCTAssertEqual(actual, "Active 2 days ago", "Return value matches")
    }
    
    func testReturnsEmptyStringWhenUserIsAwayFor3DaysOrMore() {
        let actual = onlineStatusService.updateActiveStatus(seconds: 259200, status: offlineStatus)
        XCTAssertEqual(actual, "", "Return value matches")
    }
}
