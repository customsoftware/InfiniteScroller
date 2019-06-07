//
//  Moderator.swift
//  Infinite
//
//  Created by Kenneth Cluff on 6/5/19.
//  Copyright © 2019 Kenneth Cluff. All rights reserved.
//

import UIKit

struct Badges: Codable {
    var bronze: Int
    var silver: Int
    var gold: Int
}

struct ModeratorList: Codable {
    var items: [Moderator]    
}

struct Moderator: Codable, Hashable {
    static func == (lhs: Moderator, rhs: Moderator) -> Bool {
        return lhs.userID == rhs.userID
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(userID)
    }
    
    var uiDelegate: UIOutlet?
    var badgeCounts: Badges
    var accountID: Int
    var isEmployee: Bool
    var lastModified: Int
    var lastAccess: Int
    var reputationChangeYear: Int
    var reputationChangeQuarter: Int
    var reputationChangeMonth: Int
    var reputationChangeWeek: Int
    var reputationChangeDay: Int
    var reputation: Int
    var creationDate: Int
    var userType: String
    var userID: Int
    var acceptRate: Int?
    var location: String?
    var websiteURL: String
    var link: String
    var profileImageLink: String
    var displayName: String
    var userImage: UIImage? {
        get {
            return _userImage ?? UIImage(named: "IMG_0175")!
        }
        set {
            _userImage = newValue
            uiDelegate?.updateUI(with: .loadFinished)
        }
    }
    private var _userImage: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case badgeCounts = "badge_counts"
        case accountID = "account_id"
        case isEmployee = "is_employee"
        case lastModified = "last_modified_date"
        case lastAccess = "last_access_date"
        case reputationChangeYear = "reputation_change_year"
        case reputationChangeQuarter = "reputation_change_quarter"
        case reputationChangeMonth = "reputation_change_month"
        case reputationChangeWeek = "reputation_change_week"
        case reputationChangeDay = "reputation_change_day"
        case reputation
        case creationDate = "creation_date"
        case userType = "user_type"
        case userID = "user_id"
        case acceptRate = "accept_rate"
        case location
        case websiteURL = "website_url"
        case link
        case profileImageLink = "profile_image"
        case displayName = "display_name"
    }
}

