//
//  File.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class StoryboardSwitch {
    class var sharedManager : StoryboardSwitch {
        struct Static {
            static let instance = StoryboardSwitch()
        }
        return Static.instance
    }
    func switchTo(storyboard: String, viewcontroller: String ) -> UIViewController {
        let storyboard : UIStoryboard = UIStoryboard(name: storyboard, bundle: nil)
        let registerView : UIViewController = storyboard.instantiateViewController(withIdentifier: viewcontroller) as UIViewController
        return registerView
    }
}
