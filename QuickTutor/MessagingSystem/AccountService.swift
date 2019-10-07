//
//  File.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/1/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase
import Foundation
import Stripe

class AccountService {
    static let shared = AccountService()
    private(set) var currentUser: User!

    var currentUserType: UserType = .learner {
        didSet {
            UserDefaults.standard.set(currentUserType == .learner, forKey: "showHomePage")
        }
    }

    private init() {
        loadUser()
    }
    
    func logout() {
        currentUser = nil
    }

    func loadUser(isFacebookLogin: Bool = false) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserFetchService.shared.getUserWithUid(uid) { userIn in
            guard let user = userIn else { return }
            user.isFacebookLogin = isFacebookLogin
            self.currentUser = user
        }
    }
    
    func updateFCMTokenIfNeeded() {
        if let fcmToken = Messaging.messaging().fcmToken {
            self.saveFCMToken(fcmToken)
        }
    }
    
    func saveFCMToken(_ token: String?) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("account").child(uid).child("fcmToken").setValue(token)
    }
}

class SessionService {
    static let shared = SessionService()
    var session: Session?
    var rating = 0

    private init() {}
}

class UserStatusService {
    static let shared = UserStatusService ()
    
    func getUserStatuses (completion: @escaping ([UserStatus]) -> Void) {
        Database.database().reference().child("userStatus").observe(.value) { snapshot in
            var statuses = [UserStatus]()
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String:Any], let status = dict["status"] as? Int else { continue }
                statuses.append(UserStatus(childSnapshot.key, status: status))
            }
            completion (statuses)
        }
    }
    
    func getUserStatus (_ userId: String, completion: @escaping (UserStatus?) -> Void) {
        Database.database().reference().child("userStatus").child(userId).observe(.value) { snapshot in
            guard let dict = snapshot.value as? [String:Any], let status = dict["status"] as? Int else {
                completion (nil)
                return
            }
            completion (UserStatus(userId, status: status))
        }
    }
    
    func updateUserStatus (_ userId: String, status: UserStatusType) {
        let dbRef = Database.database().reference().child("userStatus").child(userId)
        switch status {
        case .offline:
            dbRef.removeValue()
            break
        case .away:
            dbRef.updateChildValues(["status" : status.rawValue])
            break
        case .online:
            dbRef.setValue(["status" : status.rawValue])
            break
        }
    }
}

class CardService {
    static let shared = CardService()
    
    func checkForPaymentMethod() {
        guard let learner = CurrentUser.shared.learner, !learner.customer.isEmpty else {
            return
        }
        
        StripeService.retrieveCustomer(cusID: CurrentUser.shared.learner.customer) { customer, error in
            if error == nil {
                guard let customer = customer, let cards = customer.sources as? [STPCard] else {
                    return
                }
                learner.hasPayment = !cards.isEmpty || Stripe.deviceSupportsApplePay()
            }
        }
    }
}

class ConnectionService {
    static let shared = ConnectionService()
    
    func getConnectionStatus(partnerId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("connections").child(uid).child(userTypeString).child(partnerId).observeSingleEvent(of: .value) { snapshot in
            if let _ = snapshot.value as? Int {
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    func checkConnectionRequestStatus(partnerId: String, completion: ((String?) -> ())?) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        
        Database.database().reference()
            .child("conversations")
            .child(uid)
            .child(userTypeString)
            .child(partnerId)
            .queryLimited(toLast: 1)
            .observeSingleEvent(of: .value) { snapshot1 in
                guard let children = snapshot1.children.allObjects as? [DataSnapshot], let child = children.first else {
                    completion?(nil)
                    return
                }
                
                MessageService.shared.getMessageById(child.key) { message in
                    guard let requestId = message.connectionRequestId, message.type == .connectionRequest else {
                        completion?(nil)
                        return
                    }
                    
                    // Check connection request.
                    Database.database().reference().child("connectionRequests").child(requestId).observeSingleEvent(of: .value) { snapshot in
                        guard let value = snapshot.value as? [String: Any] else {
                            completion?(nil)
                            return
                        }
                        guard let status = value["status"] as? String else {
                            completion?(nil)
                            return
                        }
                        
                        if let completion = completion {
                            completion(status)
                        }
                    }
                }
            }
    }
}
