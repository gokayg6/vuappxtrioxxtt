import Foundation

// MARK: - Auth Request Models

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let dateOfBirth: String
    let gender: String
    let country: String
    let city: String
    let latitude: Double?
    let longitude: Double?
    let bio: String?
    let profilePhotoUrl: String?
    let interests: [String]
    let hobbies: [String]?
    let instagramUsername: String?
    let tiktokUsername: String?
    let snapchatUsername: String?
    let appleId: String?
    let googleId: String?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct SocialAuthRequest: Codable {
    let provider: String // "apple" or "google"
    let providerId: String
    let email: String
    let firstName: String?
    let lastName: String?
    let profilePhotoUrl: String?
}

// MARK: - Auth Response Models

struct AuthResponse: Codable {
    let success: Bool
    let data: AuthData?
    let error: String?
}

struct AuthData: Codable {
    let user: AuthUser
    let token: String
    let needsProfileCompletion: Bool?
}

struct AuthUser: Codable {
    let id: String
    let username: String
    let email: String?
    let displayName: String
    let dateOfBirth: String
    let gender: String
    let country: String
    let city: String
    let bio: String?
    let profilePhotoUrl: String
    let zodiacSign: String
    let instagramUsername: String?
    let tiktokUsername: String?
    let snapchatUsername: String?
    let isPremium: Bool
    let isVerified: Bool
    let createdAt: String
    
    // Convert to User model
    func toUser() -> User? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        
        guard let dob = dateFormatter.date(from: dateOfBirth) else {
            return nil
        }
        
        let age = Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
        
        let genderEnum: Gender = {
            switch gender {
            case "male": return .male
            case "female": return .female
            case "non_binary": return .nonBinary
            default: return .preferNotToSay
            }
        }()
        
        let ageGroupEnum: AgeGroup = age < 18 ? .minor : .adult
        
        // Create social links
        var socialLinks: SocialLinks? = nil
        if let instagram = instagramUsername, !instagram.isEmpty {
            if socialLinks == nil { socialLinks = SocialLinks() }
            socialLinks?.instagram = SocialLink(
                username: instagram,
                deeplink: "instagram://user?username=\(instagram)",
                webURL: "https://instagram.com/\(instagram)"
            )
        }
        if let tiktok = tiktokUsername, !tiktok.isEmpty {
            if socialLinks == nil { socialLinks = SocialLinks() }
            socialLinks?.tiktok = SocialLink(
                username: tiktok,
                deeplink: "tiktok://user?username=\(tiktok)",
                webURL: "https://tiktok.com/@\(tiktok)"
            )
        }
        if let snapchat = snapchatUsername, !snapchat.isEmpty {
            if socialLinks == nil { socialLinks = SocialLinks() }
            socialLinks?.snapchat = SocialLink(
                username: snapchat,
                deeplink: "snapchat://add/\(snapchat)",
                webURL: "https://snapchat.com/add/\(snapchat)"
            )
        }
        
        return User(
            id: id,
            username: username,
            displayName: displayName,
            dateOfBirth: dob,
            age: age,
            ageGroup: ageGroupEnum,
            gender: genderEnum,
            country: country,
            city: city,
            bio: bio,
            profilePhotoURL: profilePhotoUrl,
            photos: [],
            tags: [],
            interests: [],
            isPremium: isPremium,
            premiumExpiresAt: nil,
            isVerified: isVerified,
            socialLinks: socialLinks,
            lastActiveAt: Date(),
            createdAt: Date()
        )
    }
}

// MARK: - Registration Data Model

struct RegistrationData {
    // Step 1: Basic Info
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    
    // Step 2: Personal Info
    var dateOfBirth: Date = Date()
    var gender: Gender = .preferNotToSay
    
    // Step 3: Location
    var country: String = ""
    var city: String = ""
    var latitude: Double?
    var longitude: Double?
    
    // Step 4: Profile
    var bio: String = ""
    var profilePhotoUrl: String?
    
    // Step 5: Interests
    var selectedInterests: Set<String> = []
    
    // Step 6: Hobbies
    var hobbies: [String] = []
    
    // Step 7: Social Media
    var instagramUsername: String = ""
    var tiktokUsername: String = ""
    var snapchatUsername: String = ""
    
    // OAuth
    var appleId: String?
    var googleId: String?
    
    enum Gender: String, CaseIterable {
        case male = "male"
        case female = "female"
        case nonBinary = "non_binary"
        case preferNotToSay = "prefer_not_to_say"
        
        var displayName: String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            case .nonBinary: return "Non-binary"
            case .preferNotToSay: return "Prefer not to say"
            }
        }
        
        var icon: String {
            switch self {
            case .male: return "♂"
            case .female: return "♀"
            case .nonBinary: return "⚧"
            case .preferNotToSay: return "○"
            }
        }
    }
    
    func toRegisterRequest() -> RegisterRequest {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        
        return RegisterRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateFormatter.string(from: dateOfBirth),
            gender: gender.rawValue,
            country: country,
            city: city,
            latitude: latitude,
            longitude: longitude,
            bio: bio.isEmpty ? nil : bio,
            profilePhotoUrl: profilePhotoUrl,
            interests: Array(selectedInterests),
            hobbies: hobbies.isEmpty ? nil : hobbies,
            instagramUsername: instagramUsername.isEmpty ? nil : instagramUsername,
            tiktokUsername: tiktokUsername.isEmpty ? nil : tiktokUsername,
            snapchatUsername: snapchatUsername.isEmpty ? nil : snapchatUsername,
            appleId: appleId,
            googleId: googleId
        )
    }
}

// MARK: - Interest Model (using existing Interest from User.swift)

struct InterestsResponse: Codable {
    let interests: [Interest]
    let grouped: [String: [Interest]]
}

// MARK: - Zodiac Signs

enum ZodiacSign: String, CaseIterable {
    case aries, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var emoji: String {
        switch self {
        case .aries: return "♈️"
        case .taurus: return "♉️"
        case .gemini: return "♊️"
        case .cancer: return "♋️"
        case .leo: return "♌️"
        case .virgo: return "♍️"
        case .libra: return "♎️"
        case .scorpio: return "♏️"
        case .sagittarius: return "♐️"
        case .capricorn: return "♑️"
        case .aquarius: return "♒️"
        case .pisces: return "♓️"
        }
    }
    
    var dateRange: String {
        switch self {
        case .aries: return "Mar 21 - Apr 19"
        case .taurus: return "Apr 20 - May 20"
        case .gemini: return "May 21 - Jun 20"
        case .cancer: return "Jun 21 - Jul 22"
        case .leo: return "Jul 23 - Aug 22"
        case .virgo: return "Aug 23 - Sep 22"
        case .libra: return "Sep 23 - Oct 22"
        case .scorpio: return "Oct 23 - Nov 21"
        case .sagittarius: return "Nov 22 - Dec 21"
        case .capricorn: return "Dec 22 - Jan 19"
        case .aquarius: return "Jan 20 - Feb 18"
        case .pisces: return "Feb 19 - Mar 20"
        }
    }
}
