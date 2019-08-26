//
//  TutorModel.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/27/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

struct FeaturedDetails {
	let subject : String
	let price : Int
}

class AWTutor: AWLearner {
    var tBio: String!
    var region: String!
    var policy: String?
    var acctId: String!
    var topSubject: String?
    var featuredSubject: String?
    
    var price: Int!
    var secondsTaught: Int!
    var distance: Int!
    var quickCallPrice: Int!
    var preference: Int!
    var tNumSessions: Int!
    
    var tRating: Double!
    var earnings: Double!
    
    var isVisible: Bool!
    
    var subjects: [String]?
    
    var selected: [Selected] = []
    var reviews: [Review]?
    var location: TutorLocation?
    var learners: [String] = []
	
    var hasPayoutMethod: Bool = true
	
	var featuredDetails : FeaturedDetails?
    
    var experienceSubject: String?
    var experiencePeriod: Float?
	
    // Used for active tutors section
    var isConnected: Bool?
    
    override init(dictionary: [String: Any]) {
        super.init(dictionary: dictionary)
        policy = dictionary["pol"] as? String ?? ""
        region = dictionary["rg"] as? String ?? ""
        topSubject = dictionary["tp"] as? String ?? ""
        tBio = dictionary["tbio"] as? String ?? ""
        acctId = dictionary["act"] as? String ?? ""
        username = dictionary["usr"] as? String ?? ""
        price = dictionary["p"] as? Int ?? 0
        secondsTaught = dictionary["hr"] as? Int ?? 0
        distance = dictionary["dst"] as? Int ?? 75
        quickCallPrice = dictionary["quick_calls"] as? Int ?? -1
        
        preference = dictionary["prf"] as? Int ?? 3
        tNumSessions = dictionary["nos"] as? Int ?? 0
        isVisible = ((dictionary["h"] as? Int) == 0) ? true : false
        tRating = dictionary["tr"] as? Double ?? 5.0
        earnings = dictionary["ern"] as? Double ?? 0.0
        featuredSubject = dictionary["sbj"] as? String ?? ""
        profilePicUrl = URL(string: dictionary["img"] as? String ?? "")

        experienceSubject = dictionary["exp-subject"] as? String ?? ""
        experiencePeriod = dictionary["exp-period"] as? Float ?? 0.5
        
        if let images = dictionary["img"] as? [String : String] {
            images.forEach({ (key, value) in
                self.images[key] = value
            })
        }
        
        if let avatarUrl = images.filter({!$0.value.isEmpty}).first?.value {
            profilePicUrl = URL(string: avatarUrl)
        } else {
            profilePicUrl = Constants.AVATAR_PLACEHOLDER_URL
        }
    }
    
    func copy(learner: AWLearner) -> AWTutor {
        // User's variables
        self.username = learner.username
        self.profilePicUrl = learner.profilePicUrl
        self.uid = learner.uid
        self.type = learner.type
        self.isOnline = learner.isOnline
        self.rating = learner.rating
        
        // Leaner's variables
        self.name = learner.name
        self.bio = learner.bio
        self.birthday = learner.birthday
        self.email = learner.email
        self.phone = learner.phone
        self.lNumSessions = learner.lNumSessions
        self.customer = learner.customer
        self.lHours = learner.lHours
        self.school = learner.school
        self.languages = learner.languages
        self.lReviews = learner.lReviews
        self.lRating = learner.lRating
        self.savedTutorIds = learner.savedTutorIds
        self.interests = learner.interests
        return self
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func categoryReviews(_ category: String) -> [Review] {
        guard let reviews = reviews else { return [] }
        return reviews.filter({ category == SubjectStore.shared.findCategoryBy(subject: $0.subject) })
    }
}
