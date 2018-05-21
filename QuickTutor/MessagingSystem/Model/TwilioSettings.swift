//
//  TwilioSettings.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import TwilioVideo

class TwilioSettings: NSObject {
    
    var audioCodec: TVIAudioCodec?
    var videoCodec: TVIVideoCodec?
    
    var maxAudioBitrate = UInt()
    var maxVideoBitrate = UInt()
    
    func getEncodingParameters() -> TVIEncodingParameters?  {
        if maxAudioBitrate == 0 && maxVideoBitrate == 0 {
            return nil
        } else {
            return TVIEncodingParameters(audioBitrate: maxAudioBitrate, videoBitrate: maxVideoBitrate)
        }
    }
    
    private override init() {
        // Can't initialize a singleton
    }
    
    static let shared = TwilioSettings()
}
