import Foundation

enum DiscoverMode: String, Codable {
    case local = "local"
    case global = "global"
    case forYou = "forYou"
    case doubleDate = "doubleDate"
}

struct DiscoverUser: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let displayName: String
    let age: Int
    let city: String
    let country: String?
    let countryFlag: String?
    let distanceKm: Double?
    let profilePhotoURL: String
    let photos: [UserPhoto]
    let tags: [String]
    let commonInterests: [String]
    let score: Double
    let isBoosted: Bool
    let isVerified: Bool
    let tiktokUsername: String?
    let instagramUsername: String?
    let snapchatUsername: String?
    let isFriend: Bool?
    let bio: String? // Bio eklendi
    
    enum CodingKeys: String, CodingKey {
        case id, age, city, country, tags, score, photos, bio
        case displayName = "display_name"
        case countryFlag = "country_flag"
        case distanceKm = "distance_km"
        case profilePhotoURL = "profile_photo_url"
        case commonInterests = "common_interests"
        case isBoosted = "is_boosted"
        case isVerified = "is_verified"
        case tiktokUsername = "tiktok_username"
        case instagramUsername = "instagram_username"
        case snapchatUsername = "snapchat_username"
        case isFriend = "is_friend"
    }
    
    // Computed properties for social media availability
    var hasTikTok: Bool { tiktokUsername != nil && !tiktokUsername!.isEmpty }
    var hasInstagram: Bool { instagramUsername != nil && !instagramUsername!.isEmpty }
    var hasSnapchat: Bool { snapchatUsername != nil && !snapchatUsername!.isEmpty }
    var hasAnySocialMedia: Bool { hasTikTok || hasInstagram || hasSnapchat }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Convenience init with default values for tiktokUsername and isFriend
    init(
        id: String,
        displayName: String,
        age: Int,
        city: String,
        country: String?,
        countryFlag: String?,
        distanceKm: Double?,
        profilePhotoURL: String,
        photos: [UserPhoto],
        tags: [String],
        commonInterests: [String],
        score: Double,
        isBoosted: Bool,
        isVerified: Bool = false,
        tiktokUsername: String? = nil,
        instagramUsername: String?,
        snapchatUsername: String?,
        isFriend: Bool? = false,
        bio: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.age = age
        self.city = city
        self.country = country
        self.countryFlag = countryFlag
        self.distanceKm = distanceKm
        self.profilePhotoURL = profilePhotoURL
        self.photos = photos
        self.tags = tags
        self.commonInterests = commonInterests
        self.score = score
        self.isBoosted = isBoosted
        self.isVerified = isVerified
        self.tiktokUsername = tiktokUsername
        self.instagramUsername = instagramUsername
        self.snapchatUsername = snapchatUsername
        self.isFriend = isFriend
        self.bio = bio
    }
}

struct DiscoverResponse: Codable {
    let users: [DiscoverUser]
    let nextCursor: String?
    let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case users
        case nextCursor = "next_cursor"
        case hasMore = "has_more"
    }
}

struct TrendingResponse: Codable {
    let users: [DiscoverUser]
}

struct SpotlightResponse: Codable {
    let users: [DiscoverUser]
}

extension DiscoverUser {
    init(user: User) {
        self.id = user.id
        self.displayName = user.displayName
        self.age = user.age
        self.city = user.city
        self.country = user.country
        self.countryFlag = nil // Can be implemented if needed
        self.distanceKm = nil
        self.profilePhotoURL = user.profilePhotoURL
        self.photos = user.photos
        self.tags = user.tags
        self.commonInterests = [] // Can be computed contextually
        self.score = 0
        self.isBoosted = false
        self.isVerified = user.isVerified
        self.tiktokUsername = user.socialLinks?.tiktok?.username
        self.instagramUsername = user.socialLinks?.instagram?.username
        self.snapchatUsername = user.socialLinks?.snapchat?.username
        self.isFriend = false
        self.bio = user.bio
    }
}
    



// MARK: - Mock Data (For Previews & Debug Only)
extension DiscoverUser {
    
    // MARK: - Turkish Users (40 total: 35 female, 5 male)
    static var turkishUsers: [DiscoverUser] {
        let femaleNames = ["Elif", "Zeynep", "Ayşe", "Selin", "Melis", "Deniz", "İrem", "Ceren", "Gizem", "Burcu",
                           "Damla", "Esra", "Gamze", "Hazal", "Iclal", "Jale", "Kübra", "Leman", "Merve", "Nazlı",
                           "Özge", "Pınar", "Rüya", "Sude", "Tuğba", "Ülkü", "Vildan", "Yaren", "Zara", "Ayla",
                           "Beste", "Cansu", "Defne", "Ecrin", "Fulya"]
        let maleNames = ["Ahmet", "Burak", "Can", "Deniz", "Emre"]
        let cities = ["İstanbul", "Ankara", "İzmir", "Antalya", "Bursa", "Trabzon"]
        
        let femalePhotos = [
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800",
            "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800",
            "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800",
            "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800",
            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800",
            "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800",
            "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800",
            "https://images.unsplash.com/photo-1502767089025-6572583495b9?w=800"
        ]
        
        let malePhotos = [
            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800",
            "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800"
        ]
        
        var users: [DiscoverUser] = []
        
        // Female users (35)
        for i in 0..<35 {
            users.append(DiscoverUser(
                id: "tr_f_\(i)",
                displayName: femaleNames[i % femaleNames.count],
                age: Int.random(in: 19...28),
                city: cities.randomElement()!,
                country: "Türkiye",
                countryFlag: "🇹🇷",
                distanceKm: Double.random(in: 1...30),
                profilePhotoURL: femalePhotos[i % femalePhotos.count],
                photos: [UserPhoto(id: "p_tr_f_\(i)", url: femalePhotos[i % femalePhotos.count], thumbnailURL: nil, orderIndex: 0, isPrimary: true)],
                tags: ["Müzik", "Seyahat", "Spor"].shuffled().prefix(2).map { $0 },
                commonInterests: ["Müzik"],
                score: Double.random(in: 70...95),
                isBoosted: i < 3,
                tiktokUsername: i % 3 == 0 ? "user\(i)" : nil,
                instagramUsername: "insta\(i)",
                snapchatUsername: i % 2 == 0 ? "snap\(i)" : nil,
                isFriend: false,
                bio: "Merhaba! 🌟"
            ))
        }
        
        // Male users (5)
        for i in 0..<5 {
            users.append(DiscoverUser(
                id: "tr_m_\(i)",
                displayName: maleNames[i],
                age: Int.random(in: 20...30),
                city: cities.randomElement()!,
                country: "Türkiye",
                countryFlag: "🇹🇷",
                distanceKm: Double.random(in: 1...30),
                profilePhotoURL: malePhotos[i % malePhotos.count],
                photos: [UserPhoto(id: "p_tr_m_\(i)", url: malePhotos[i % malePhotos.count], thumbnailURL: nil, orderIndex: 0, isPrimary: true)],
                tags: ["Spor", "Oyun", "Müzik"].shuffled().prefix(2).map { $0 },
                commonInterests: ["Spor"],
                score: Double.random(in: 60...85),
                isBoosted: false,
                tiktokUsername: nil,
                instagramUsername: "insta_m\(i)",
                snapchatUsername: nil,
                isFriend: false,
                bio: "Selam! 👋"
            ))
        }
        
        return users.shuffled()
    }
    
    // MARK: - Global Users (20 total: 17 female, 3 male)
    static var globalUsers: [DiscoverUser] {
        let globalData: [(name: String, country: String, flag: String, city: String)] = [
            ("Emma", "United States", "🇺🇸", "New York"),
            ("Sophie", "United Kingdom", "🇬🇧", "London"),
            ("Marie", "France", "🇫🇷", "Paris"),
            ("Giulia", "Italy", "🇮🇹", "Rome"),
            ("Anna", "Germany", "🇩🇪", "Berlin"),
            ("Isabella", "Spain", "🇪🇸", "Madrid"),
            ("Olivia", "Australia", "🇦🇺", "Sydney"),
            ("Yuki", "Japan", "🇯🇵", "Tokyo"),
            ("Elena", "Russia", "🇷🇺", "Moscow"),
            ("Kim", "South Korea", "🇰🇷", "Seoul"),
            ("Sarah", "Canada", "🇨🇦", "Toronto"),
            ("Eva", "Netherlands", "🇳🇱", "Amsterdam"),
            ("Ingrid", "Sweden", "🇸🇪", "Stockholm"),
            ("Katrine", "Denmark", "🇩🇰", "Copenhagen"),
            ("Bianca", "Brazil", "🇧🇷", "São Paulo"),
            ("Priya", "India", "🇮🇳", "Mumbai"),
            ("Valentina", "Mexico", "🇲🇽", "Mexico City"),
            // Males
            ("James", "United States", "🇺🇸", "Los Angeles"),
            ("Oliver", "United Kingdom", "🇬🇧", "Manchester"),
            ("Lucas", "Germany", "🇩🇪", "Munich")
        ]
        
        let femalePhotos = [
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800",
            "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800",
            "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800",
            "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800",
            "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800"
        ]
        
        let malePhotos = [
            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800"
        ]
        
        var users: [DiscoverUser] = []
        
        for (i, data) in globalData.enumerated() {
            let isMale = i >= 17
            let photo = isMale ? malePhotos[0] : femalePhotos[i % femalePhotos.count]
            
            users.append(DiscoverUser(
                id: "global_\(i)",
                displayName: data.name,
                age: Int.random(in: 19...28),
                city: data.city,
                country: data.country,
                countryFlag: data.flag,
                distanceKm: Double.random(in: 100...5000),
                profilePhotoURL: photo,
                photos: [UserPhoto(id: "p_g_\(i)", url: photo, thumbnailURL: nil, orderIndex: 0, isPrimary: true)],
                tags: ["Travel", "Music", "Art"].shuffled().prefix(2).map { $0 },
                commonInterests: ["Travel"],
                score: Double.random(in: 65...90),
                isBoosted: i < 2,
                tiktokUsername: i % 4 == 0 ? "global\(i)" : nil,
                instagramUsername: "insta_\(data.name.lowercased())",
                snapchatUsername: nil,
                isFriend: false,
                bio: "Hello from \(data.city)! 🌍"
            ))
        }
        
        return users.shuffled()
    }
    
    // MARK: - Combined Mock Data
    static var mockUsers: [DiscoverUser] {
        return turkishUsers
    }
    
    static var allMockUsers: [DiscoverUser] {
        return turkishUsers + globalUsers
    }
    
    static var likedYouUsers: [DiscoverUser] {
        Array(turkishUsers.prefix(5))
    }
    
    static var newUsers: [DiscoverUser] {
        Array(turkishUsers.suffix(5))
    }
}
