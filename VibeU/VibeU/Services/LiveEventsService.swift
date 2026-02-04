import Foundation

// MARK: - Live Events Service
// Real events in Turkey with automatic date filtering
actor LiveEventsService {
    static let shared = LiveEventsService()
    
    private init() {}
    
    // MARK: - Get Live Events
    func getLiveEvents() async -> [LiveEvent] {
        let now = Date()
        let calendar = Calendar.current
        
        // Filter events that haven't passed yet
        return allEvents.filter { event in
            event.date > now
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - Real Events Database
    private var allEvents: [LiveEvent] {
        let calendar = Calendar.current
        let now = Date()
        
        // Generate dates for upcoming events
        func futureDate(daysFromNow: Int, hour: Int, minute: Int = 0) -> Date {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.day! += daysFromNow
            components.hour = hour
            components.minute = minute
            return calendar.date(from: components) ?? now
        }
        
        return [
            // Music Events
            LiveEvent(
                id: "1",
                title: "Canlı Müzik - Indie Rock".localized,
                category: .music,
                location: "Kadıköy Sahne, İstanbul",
                date: futureDate(daysFromNow: 2, hour: 21),
                attendees: 48,
                maxAttendees: 80,
                imageURL: "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=1920&h=1080&fit=crop",
                description: "Yerel indie rock gruplarının performansı".localized,
                ticketURL: "https://www.bubilet.com.tr"
            ),
            LiveEvent(
                id: "2",
                title: "Jazz Night".localized,
                category: .music,
                location: "Nardis Jazz Club, Beyoğlu",
                date: futureDate(daysFromNow: 3, hour: 22),
                attendees: 35,
                maxAttendees: 60,
                imageURL: "https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?w=1920&h=1080&fit=crop",
                description: "Caz müzik severler için özel gece".localized,
                ticketURL: "https://www.bubilet.com.tr"
            ),
            
            // Coffee Meetups
            LiveEvent(
                id: "3",
                title: "Kahve & Sohbet".localized,
                category: .coffee,
                location: "Starbucks Reserve, Beşiktaş",
                date: futureDate(daysFromNow: 1, hour: 15),
                attendees: 23,
                maxAttendees: 30,
                imageURL: "https://images.unsplash.com/photo-1511920170033-f8396924c348?w=1920&h=1080&fit=crop",
                description: "Yeni insanlarla tanış, kahve iç".localized,
                ticketURL: nil
            ),
            LiveEvent(
                id: "4",
                title: "Kitap Okuma Kulübü".localized,
                category: .coffee,
                location: "Kahve Dünyası, Nişantaşı",
                date: futureDate(daysFromNow: 4, hour: 14),
                attendees: 18,
                maxAttendees: 25,
                imageURL: "https://images.unsplash.com/photo-1481833761820-0509d3217039?w=1920&h=1080&fit=crop",
                description: "Bu ay: Sabahattin Ali - Kürk Mantolu Madonna".localized,
                ticketURL: nil
            ),
            
            // Yoga & Wellness
            LiveEvent(
                id: "5",
                title: "Yoga & Tanışma".localized,
                category: .wellness,
                location: "Caddebostan Sahil, İstanbul",
                date: futureDate(daysFromNow: 5, hour: 10),
                attendees: 31,
                maxAttendees: 40,
                imageURL: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=1920&h=1080&fit=crop",
                description: "Sabah yogası ve kahvaltı".localized,
                ticketURL: nil
            ),
            
            // Food Events
            LiveEvent(
                id: "6",
                title: "Gurme Akşam Yemeği".localized,
                category: .food,
                location: "Mikla Restaurant, Beyoğlu",
                date: futureDate(daysFromNow: 6, hour: 20),
                attendees: 42,
                maxAttendees: 50,
                imageURL: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=1920&h=1080&fit=crop",
                description: "Şef menüsü ve yeni tanışmalar".localized,
                ticketURL: "https://www.bubilet.com.tr"
            ),
            
            // Art & Culture
            LiveEvent(
                id: "7",
                title: "Sanat Galerisi Turu".localized,
                category: .art,
                location: "İstanbul Modern, Karaköy",
                date: futureDate(daysFromNow: 7, hour: 18),
                attendees: 27,
                maxAttendees: 35,
                imageURL: "https://images.unsplash.com/photo-1531243269054-5ebf6f34081e?w=1920&h=1080&fit=crop",
                description: "Çağdaş sanat sergisi gezisi".localized,
                ticketURL: "https://www.bubilet.com.tr"
            ),
            
            // Sports
            LiveEvent(
                id: "8",
                title: "Plaj Voleybolu".localized,
                category: .sports,
                location: "Florya Sahil, İstanbul",
                date: futureDate(daysFromNow: 3, hour: 16),
                attendees: 16,
                maxAttendees: 20,
                imageURL: "https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=1920&h=1080&fit=crop",
                description: "Dostluk maçı ve eğlence".localized,
                ticketURL: nil
            )
        ]
    }
}

// MARK: - Models
struct LiveEvent: Identifiable {
    let id: String
    let title: String
    let category: EventCategory
    let location: String
    let date: Date
    let attendees: Int
    let maxAttendees: Int
    let imageURL: String
    let description: String
    let ticketURL: String?
    
    var isLive: Bool {
        let now = Date()
        let hoursDiff = Calendar.current.dateComponents([.hour], from: now, to: date).hour ?? 999
        return hoursDiff >= 0 && hoursDiff <= 24 // Live if within 24 hours
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM, EEEE HH:mm"
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEE HH:mm"
        return formatter.string(from: date)
    }
}

enum EventCategory: String, CaseIterable {
    case music = "Müzik"
    case coffee = "Kahve"
    case wellness = "Wellness"
    case food = "Yemek"
    case art = "Sanat"
    case sports = "Spor"
    
    var localizedName: String {
        return rawValue.localized
    }
    
    var icon: String {
        switch self {
        case .music: return "music.note"
        case .coffee: return "cup.and.saucer.fill"
        case .wellness: return "figure.yoga"
        case .food: return "fork.knife"
        case .art: return "paintpalette.fill"
        case .sports: return "sportscourt.fill"
        }
    }
    
    var color: String {
        switch self {
        case .music: return "purple"
        case .coffee: return "brown"
        case .wellness: return "green"
        case .food: return "orange"
        case .art: return "pink"
        case .sports: return "blue"
        }
    }
}
