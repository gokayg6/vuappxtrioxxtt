import Foundation

enum AgeGroup: String, Codable, Equatable {
    case minor = "minor"
    case adult = "adult"
}

enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case nonBinary = "non_binary"
    case preferNotToSay = "prefer_not_to_say"
    
    var displayKey: String {
        switch self {
        case .male: return "gender_male"
        case .female: return "gender_female"
        case .nonBinary: return "gender_non_binary"
        case .preferNotToSay: return "gender_prefer_not"
        }
    }
    
    // Custom decoder to handle Turkish values from old data
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Try to map Turkish values to English enum
        switch rawValue.lowercased() {
        case "male":
            self = .male
        case "female":
            self = .female
        case "non_binary", "nonbinary":
            self = .nonBinary
        case "prefer_not_to_say", "prefernottosay":
            self = .preferNotToSay
        // Turkish mappings
        case "erkek":
            self = .male
        case "kadın", "kadin":
            self = .female
        case "diğer", "diger", "other":
            self = .nonBinary
        default:
            print("⚠️ [Gender] Unknown gender value '\(rawValue)', defaulting to prefer_not_to_say")
            self = .preferNotToSay
        }
    }
}

struct User: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var username: String
    var displayName: String
    var dateOfBirth: Date
    var age: Int
    var ageGroup: AgeGroup
    var gender: Gender
    var country: String
    var city: String
    var bio: String?
    var profilePhotoURL: String
    var photos: [UserPhoto]
    var tags: [String]
    var interests: [Interest]
    var isPremium: Bool
    var premiumExpiresAt: Date?
    var isVerified: Bool
    var socialLinks: SocialLinks?
    var lastActiveAt: Date
    var createdAt: Date
    
    // Extended Profile Fields
    var jobTitle: String?
    var company: String?
    var university: String?
    var department: String?
    var height: String?
    var zodiac: String?
    var smoking: String?
    var drinking: String?
    var exercise: String?
    var pets: String?
    var lookingFor: String?
    var wantKids: String?
    var hobbies: [String]?
    
    // Currency
    var diamondBalance: Int?
    
    // Onboarding completion
    var profileCompletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, username, age, gender, country, city, bio, tags, interests
        case displayName = "display_name"
        case dateOfBirth = "date_of_birth"
        case ageGroup = "age_group"
        case profilePhotoURL = "profile_photo_url"
        case photos
        case isPremium = "is_premium"
        case premiumExpiresAt = "premium_expires_at"
        case isVerified = "is_verified"
        case socialLinks = "social_links"
        case lastActiveAt = "last_active_at"
        case createdAt = "created_at"
        
        // Extended Profile Keys
        case jobTitle = "job_title"
        case company
        case university
        case department
        case height
        case zodiac
        case smoking
        case drinking
        case exercise
        case pets
        case lookingFor = "looking_for"
        case wantKids = "want_kids"
        case hobbies
        case diamondBalance = "diamond_balance"
        case profileCompletedAt = "profile_completed_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        displayName = try container.decode(String.self, forKey: .displayName)
        
        // Handle date_of_birth - might be missing or invalid
        if let dob = try? container.decode(Date.self, forKey: .dateOfBirth) {
            dateOfBirth = dob
        } else {
            // Default to 18 years ago if missing
            dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
            print("⚠️ [User] Using default date of birth for user \(id)")
        }
        
        age = try container.decode(Int.self, forKey: .age)
        ageGroup = try container.decode(AgeGroup.self, forKey: .ageGroup)
        gender = try container.decode(Gender.self, forKey: .gender)
        country = try container.decode(String.self, forKey: .country)
        city = try container.decode(String.self, forKey: .city)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        profilePhotoURL = try container.decode(String.self, forKey: .profilePhotoURL)
        
        // Default to empty array if missing (since we use subcollection now)
        photos = try container.decodeIfPresent([UserPhoto].self, forKey: .photos) ?? []
        
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        
        // Interests - support both string array (legacy) and Interest object array
        if let interestObjects = try? container.decodeIfPresent([Interest].self, forKey: .interests) {
            interests = interestObjects
        } else if let interestStrings = try? container.decodeIfPresent([String].self, forKey: .interests) {
            // Convert string array to Interest objects
            interests = interestStrings.map { name in
                let code = name.lowercased().replacingOccurrences(of: " ", with: "_")
                return Interest(
                    id: UUID().uuidString,
                    code: code,
                    name: name,
                    emoji: nil,
                    category: "General"
                )
            }
        } else {
            interests = []
        }
        
        isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
        premiumExpiresAt = try container.decodeIfPresent(Date.self, forKey: .premiumExpiresAt)
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
        socialLinks = try container.decodeIfPresent(SocialLinks.self, forKey: .socialLinks)
        lastActiveAt = try container.decodeIfPresent(Date.self, forKey: .lastActiveAt) ?? Date()
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        
        // Currency
        diamondBalance = try container.decodeIfPresent(Int.self, forKey: .diamondBalance)
        
        // Extended fields
        jobTitle = try container.decodeIfPresent(String.self, forKey: .jobTitle)
        company = try container.decodeIfPresent(String.self, forKey: .company)
        university = try container.decodeIfPresent(String.self, forKey: .university)
        department = try container.decodeIfPresent(String.self, forKey: .department)
        height = try container.decodeIfPresent(String.self, forKey: .height)
        zodiac = try container.decodeIfPresent(String.self, forKey: .zodiac)
        smoking = try container.decodeIfPresent(String.self, forKey: .smoking)
        drinking = try container.decodeIfPresent(String.self, forKey: .drinking)
        exercise = try container.decodeIfPresent(String.self, forKey: .exercise)
        pets = try container.decodeIfPresent(String.self, forKey: .pets)
        lookingFor = try container.decodeIfPresent(String.self, forKey: .lookingFor)
        wantKids = try container.decodeIfPresent(String.self, forKey: .wantKids)
        hobbies = try container.decodeIfPresent([String].self, forKey: .hobbies) ?? []
        profileCompletedAt = try container.decodeIfPresent(Date.self, forKey: .profileCompletedAt)
    }
    
    // Explicit init for mock/creation
    init(id: String, username: String, displayName: String, dateOfBirth: Date, age: Int, ageGroup: AgeGroup, gender: Gender, country: String, city: String, bio: String?, profilePhotoURL: String, photos: [UserPhoto], tags: [String], interests: [Interest], isPremium: Bool, premiumExpiresAt: Date?, isVerified: Bool, socialLinks: SocialLinks?, lastActiveAt: Date, createdAt: Date, jobTitle: String? = nil, company: String? = nil, university: String? = nil, department: String? = nil, height: String? = nil, zodiac: String? = nil, smoking: String? = nil, drinking: String? = nil, exercise: String? = nil, pets: String? = nil, lookingFor: String? = nil, wantKids: String? = nil, hobbies: [String]? = nil, diamondBalance: Int? = nil, profileCompletedAt: Date? = nil) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.dateOfBirth = dateOfBirth
        self.age = age
        self.ageGroup = ageGroup
        self.gender = gender
        self.country = country
        self.city = city
        self.bio = bio
        self.profilePhotoURL = profilePhotoURL
        self.photos = photos
        self.tags = tags
        self.interests = interests
        self.isPremium = isPremium
        self.premiumExpiresAt = premiumExpiresAt
        self.isVerified = isVerified
        self.socialLinks = socialLinks
        self.lastActiveAt = lastActiveAt
        self.createdAt = createdAt
        self.jobTitle = jobTitle
        self.company = company
        self.university = university
        self.department = department
        self.height = height
        self.zodiac = zodiac
        self.smoking = smoking
        self.drinking = drinking
        self.exercise = exercise
        self.pets = pets
        self.lookingFor = lookingFor
        self.wantKids = wantKids
        self.hobbies = hobbies
        self.diamondBalance = diamondBalance
        self.profileCompletedAt = profileCompletedAt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Mock user for guest login
    static func mockGuest() -> User {
        User(
            id: UUID().uuidString,
            username: "guest_user",
            displayName: "Misafir",
            dateOfBirth: Date(timeIntervalSince1970: 946684800),
            age: 25,
            ageGroup: .adult,
            gender: .preferNotToSay,
            country: "Turkey",
            city: "Istanbul",
            bio: "Misafir olarak geziniyorum 👋",
            profilePhotoURL: "https://api.dicebear.com/7.x/avataaars/png?seed=guest",
            photos: [],
            tags: [],
            interests: [],
            isPremium: false,
            premiumExpiresAt: nil,
            isVerified: false,
            socialLinks: nil,
            lastActiveAt: Date(),
            createdAt: Date(),
            jobTitle: nil,
            company: nil,
            university: nil,
            department: nil,
            height: nil,
            zodiac: nil,
            smoking: nil,
            drinking: nil,
            exercise: nil,
            pets: nil,
            lookingFor: nil,
            wantKids: nil,
            hobbies: []
        )
    }
}

struct UserPhoto: Identifiable, Codable, Equatable {
    let id: String
    let url: String
    let thumbnailURL: String?
    let orderIndex: Int
    let isPrimary: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, url
        case thumbnailURL = "thumbnail_url"
        case orderIndex = "order_index"
        case isPrimary = "is_primary"
        
        // Legacy keys check
        case thumbnailURLLegacy = "thumbnailUrl" // camelCase
        case orderIndexLegacy = "orderIndex"
        case isPrimaryLegacy = "isPrimary"
    }
    
    init(id: String, url: String, thumbnailURL: String?, orderIndex: Int, isPrimary: Bool) {
        self.id = id
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.orderIndex = orderIndex
        self.isPrimary = isPrimary
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        url = try container.decode(String.self, forKey: .url)
        
        // Robust decoding: Try snake_case first, then legacy camelCase
        if let thumb = try? container.decodeIfPresent(String.self, forKey: .thumbnailURL) {
            thumbnailURL = thumb
        } else {
            thumbnailURL = try container.decodeIfPresent(String.self, forKey: .thumbnailURLLegacy)
        }
        
        if let index = try? container.decodeIfPresent(Int.self, forKey: .orderIndex) {
            orderIndex = index
        } else {
            orderIndex = try container.decodeIfPresent(Int.self, forKey: .orderIndexLegacy) ?? 0
        }
        
        if let primary = try? container.decodeIfPresent(Bool.self, forKey: .isPrimary) {
            isPrimary = primary
        } else {
            isPrimary = try container.decodeIfPresent(Bool.self, forKey: .isPrimaryLegacy) ?? false
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(thumbnailURL, forKey: .thumbnailURL)
        try container.encode(orderIndex, forKey: .orderIndex)
        try container.encode(isPrimary, forKey: .isPrimary)
    }
}

struct SocialLinks: Codable, Equatable {
    var tiktok: SocialLink?
    var instagram: SocialLink?
    var snapchat: SocialLink?
    var twitter: SocialLink?
    var spotify: SocialLink?
}

struct SocialLink: Codable, Equatable {
    let username: String
    let deeplink: String
    let webURL: String
    
    enum CodingKeys: String, CodingKey {
        case username, deeplink
        case webURL = "web_url"
    }
}

struct Interest: Identifiable, Codable, Equatable {
    let id: String
    let code: String
    let name: String
    let emoji: String?
    let category: String
    
    var localizedName: String {
        return name
    }
}
