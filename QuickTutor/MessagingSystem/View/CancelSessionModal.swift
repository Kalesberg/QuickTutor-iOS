//
//  CancelSessionModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class CancelSessionModal: CustomModal {
    
    override func handleConfirmButton() {
        delegate?.handleCancel(id: sessionId)
    }
}


