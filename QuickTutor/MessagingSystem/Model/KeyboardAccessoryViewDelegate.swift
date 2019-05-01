//
//  KeyboardAccessoryViewDelegate.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/28/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Foundation

protocol KeyboardAccessoryViewDelegate {
    func handleMessageSend(message: UserMessage)
    func handleSendingImage()
    func shareUsernameForUserId()
    func handleSessionRequest()
    func handleFileUpload()
}
