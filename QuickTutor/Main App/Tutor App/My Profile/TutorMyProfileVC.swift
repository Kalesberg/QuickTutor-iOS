//
//  MyProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseUI
import Foundation
import UIKit

protocol UpdatedTutorCallBack: class {
    func tutorWasUpdated(tutor: AWTutor!)
}
