import SwiftUI
import Observation
import FirebaseAuth

enum AuthState: Equatable {
    case loading
    case onboarding
    case unauthenticated
    case authenticated
    case needsProfileSetup // Yeni durum - kayıt sonrası profil tamamlama
}

enum AppTheme: String, CaseIterable {
    case dark = "dark"
    case light = "light"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .dark: return "Koyu"
        case .light: return "Açık"
        case .system: return "Sistem"
        }
    }
    
    var icon: String {
        switch self {
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }
}

enum AppLanguage: String, CaseIterable {
    case turkish = "tr"
    case english = "en"
    case spanish = "es"
    case portuguese = "pt"
    case french = "fr"
    
    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        case .spanish: return "Español"
        case .portuguese: return "Português"
        case .french: return "Français"
        }
    }
    
    var flag: String {
        switch self {
        case .turkish: return "🇹🇷"
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        case .portuguese: return "🇧🇷"
        case .french: return "🇫🇷"
        }
    }
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

// MARK: - Localization Bundle Override
nonisolated(unsafe) private var bundleKey: UInt8 = 0
// Initialize with saved language or default to "tr"
nonisolated(unsafe) private var currentLanguageCode: String = UserDefaults.standard.string(forKey: "appLanguage") ?? "tr"

final class LocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle(path: path) else {
            // Fallback: Manual dictionary check
            if let translation = ManualTranslations.translate(key: key, language: currentLanguageCode) {
                return translation
            }
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func setLanguage(_ language: String) {
        currentLanguageCode = language
        defer {
            object_setClass(Bundle.main, LocalizedBundle.self)
        }
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// Hardcoded translations - EXTENDED
struct ManualTranslations {
    static func translate(key: String, language: String) -> String? {
        switch language {
        case "en": return en[key]
        case "es": return es[key]
        case "fr": return fr[key]
        case "pt": return pt[key]
        default: return nil
        }
    }
    
    static let en: [String: String] = [
        "Hızlı Tanış": "Speed Date",
    "Kör Randevu": "Blind Date",
    "Ses Tanış": "Voice Match",
    "Burç Eşleş": "Astro Match",
    "Vibe Quiz": "Vibe Quiz",
    
    // Categories
    "Oyun Arkadaşı": "Gaming Buddy",
    "Müzik Eşleş": "Music Match",
    "Kitap Kulübü": "Book Club",
    "Gurme Deneyimi": "Gourmet Experience",
    "Seyahat Arkadaşı": "Travel Buddy",
    
    // Descriptions (Short)
    "Birlikte oynayacak arkadaş bul": "Find a friend to play with",
    "Müzik zevkine göre eşleş": "Match by music taste",
    "Aynı kitabı okuyan insanlarla tanış": "Meet people reading the same book",
    "100+ restoran, rezervasyon yap, eşleş": "100+ restaurants, reserve, match",
    "Dünyayı birlikte keşfet": "Explore the world together",
    
    // Speed Date / Blind Date UI
    "Eşleşme Bulundu! 🎉": "Match Found! 🎉",
    "Eşleşme Aranıyor...": "Searching for Match...",
    "Sizin için en uygun kişi bulunuyor": "Finding the best match for you",
    "Hepsi Bu Kadar!": "That's All!",
    "Yeni kullanıcılar için tekrar gel": "Come back for new users",
    "Gizemli Kişi": "Mysterious Person",
    "Tanışalım mı?": "Shall we meet?",
    "VibeU Eşleşmesi": "VibeU Match",
    "Fotoğrafsız tanış": "Meet without photos",
    
    // Voice Match UI
    "Ses Eşleşmesi! 🎙️": "Voice Match! 🎙️",
    "Konuşacak Biri Aranıyor...": "Looking for someone to talk to...",
    "Sesine kulak verecek biri bulunuyor": "Finding someone to listen...",
    "Kaydı İptal Et": "Cancel Recording",
    "Kaydediliyor...": "Recording...",
    "30 saniyelik sesli mesaj kaydet": "Record 30s voice message",
    "Durdur": "Stop",
    "Kayda Başla": "Start Recording",
    "Sesli Mesajı Dinle": "Listen to Message",
    
    // Astro Match UI
    "Yıldızlar Eşleşti! ✨": "Stars Matched! ✨",
    "Burç Uyumu Aranıyor...": "Searching for Astro Compatibility...",
    "Yıldız haritanız karşılaştırılıyor": "Comparing star charts...",
    
    // Vibe Quiz UI
    "8 soruluk kişilik testini tamamla ve ruh eşini bul!": "Complete the 8-question quiz to find your soulmate!",
    "Teste Başla": "Start Quiz",
    "Soru": "Question",
    "Kişilik Tipin": "Your Personality Type",
    "Eşleşmeye Başla": "Start Matching",
    "Maceracı": "Adventurer",
    "Düşünür": "Thinker",
    "Yaratıcı": "Creative",
    "Sosyal": "Social",
    "Yeni deneyimlere açık, enerjik ve sosyal birisin!": "You are open to new experiences, energetic and social!",
    "Derin, sakin ve analitik bir kişiliğe sahipsin!": "You have a deep, calm, and analytical personality!",
    "Hayal gücü kuvvetli, özgün ve ilham vericisin!": "You have a strong imagination, unique and inspiring!",
    "İnsanlarla olmayı seven, enerjik ve eğlencelisin!": "You love being with people, energetic and fun!",
    "Benzersiz bir kişiliğe sahipsin!": "You have a unique personality!",
    
    // Likes View
    "Gelen Arkadaşlık İstekleri": "Incoming Friend Requests",
    "istek daha": "more requests",
    "kişi seni beğendi!": "people liked you!",
    "Premium ile kimlerin beğendiğini gör": "See who liked you with Premium",
    "Beğenenler": "Likes",
    
    // Common
    "Tamam": "OK",
    "İptal": "Cancel",
    "Gönder": "Send",
    "Kaydet": "Save",

        "Premium'a Geç": "Go Premium",
        "Sınırsız beğeni, reklamsız kullanım, özel özellikler": "Unlimited likes, ad-free experience, special features",
        "Premium'u Keşfet": "Discover Premium",
        "Daha sonra": "Later",
        "İzle ve Devam Et": "Watch and Continue",
        "Yaklaşan Etkinlikler": "Upcoming Events",
        "Macera": "Adventure",
        "Romantik": "Romantic",
        "Sakin": "Chill",
        "Bugün Nasıl Hissediyorsun?": "How do you feel today?",
        "Ruh Eşini Bul": "Find Your Soulmate",
        "Başla": "Start",
        "Sana Özel": "For You",
        "Paylaş": "Share",
        "Çift Randevu": "Double Date",
        "Reklam izleniyor...": "Watching ad...",
        "Reklam Süresi": "Ad Break",

        "Sınırsız beğeni gönder": "Send unlimited likes",
        "Gizli profil görüntüleme": "Private profile viewing",
        "Öncelikli eşleşme": "Priority matching",
        "Reklamsız deneyim": "Ad-free experience",
        // Profile & Settings

        "VibeU Gold": "VibeU Gold",
        "Filtreler": "Filters",

        "Arkadaşlarınla birlikte eşleş": "Match with your friends",
        "DAHA FAZLA AL": "GET MORE",
        "GÖRÜNTÜLE": "VIEW",

        "Super Like ile öne çık ve eşleşme şansını 3 kat artır!": "Stand out with Super Like and triple your match chance!",

        "Seni Beğenenler": "People Who Liked You",
        // Discover
        "Bakiye:": "Balance:",
        "Premium ile reklamsız kullan": "Go ad-free with Premium",
        "Son Zamanlarda Aktif": "Recently Active",
        "Arkadaşlık isteği gönderildi!": "Friend request sent!",
        "Yetersiz elmas (100 gerekli)": "Insufficient diamonds (100 required)",
        "Yetersiz elmas! Arkadaşlık isteği göndermek için 10 elmas gerekli.": "Insufficient diamonds! 10 diamonds required to send friend request.",
        "Super Like + Arkadaşlık isteği gönderildi!": "Super Like + Friend request sent!",
        

        "Arkadaşlık isteği gönderdi": "sent a friend request",
        "Tüm İstekler": "All Requests",

        // QR Profile
        "Hikayende Paylaş": "Share to Story",
        "QR Profilim": "My QR Profile",
        "Kaydedildi ✓": "Saved ✓",
        "QR kod fotoğraflarına kaydedildi.": "QR code saved to photos.",
        "Arkadaş Ekle": "Add Friend",
        "QR kod veya AirDrop ile arkadaşlarını ekle": "Add friends via QR or AirDrop",
        "QR Kodunu Göster": "Show QR Code",
        "Arkadaşların seni tarayarak ekleyebilir": "Friends can scan to add you",
        "QR Kod Tara": "Scan QR Code",
        "Arkadaşının QR kodunu tara ve ekle": "Scan friend's QR to add",
        "Yakındakileri Bul": "Find Nearby",
        "AirDrop ile yakındaki VibeU kullanıcılarını bul": "Find nearby VibeU users via AirDrop",
        "Yakındaki Kullanıcılar": "Nearby Users",
        "Bu QR kodu arkadaşlarına göster": "Show this QR code to friends",
        "QR Kodum": "My QR Code",
        "QR Kodu çerçevenin içine hizalayın": "Align QR code within frame",
        
        // Explore
        "Keşfet": "Explore",
        "Göz At": "Browse",


        "Kişilik testine göre eşleş": "Match based on personality test",
        "Birlikte oyna": "Play together",
        "Aynı zevk": "Same taste",
        "Yemek keşfi": "Food discovery",
        "Aynı kitap": "Same book",

        "Yakında yeni etkinlikler...": "New events coming soon...",
        "CANLI": "LIVE",

        "Özel Deneyimler": "Exclusive Experiences",

        "Gurme": "Foodie",
        
        // Live Events (Mock)
        "Canlı Müzik - Indie Rock": "Live Music - Indie Rock",
        "Yerel indie rock gruplarının performansı": "Performance by local indie rock bands",
        "Jazz Night": "Jazz Night",
        "Caz müzik severler için özel gece": "Special night for jazz lovers",
        "Kahve & Sohbet": "Coffee & Chat",
        "Yeni insanlarla tanış, kahve iç": "Meet new people, drink coffee",
        "Kitap Okuma Kulübü": "Book Reading Club",
        "Bu ay: Sabahattin Ali - Kürk Mantolu Madonna": "This month: Sabahattin Ali - Madonna in a Fur Coat",
        "Yoga & Tanışma": "Yoga & Meetup",
        "Sabah yogası ve kahvaltı": "Morning yoga and breakfast",
        "Gurme Akşam Yemeği": "Gourmet Dinner",
        "Şef menüsü ve yeni tanışmalar": "Chef's menu and new meetings",
        "Sanat Galerisi Turu": "Art Gallery Tour",
        "Çağdaş sanat sergisi gezisi": "Contemporary art exhibition tour",
        "Plaj Voleybolu": "Beach Volleyball",
        "Dostluk maçı ve eğlence": "Friendly match and fun",
        "Müzik": "Music",
        "Kahve": "Coffee",
        "Wellness": "Wellness",
        "Yemek": "Food",
        "Sanat": "Art",
        "Spor": "Sports",

        // Time Units
        "1 Hafta": "1 Week",
        "1 Ay": "1 Month",
        "6 Ay": "6 Months",
        "Hafta": "Week",
        "Ay": "Month",
        "Yıl": "Year",

        // Profile & Premium
        "Mevcut:": "Current:",
        "30 dakika boyunca profilini öne çıkar ve 10 kat daha fazla görüntülenme al!": "Highlight your profile for 30 min and get 10x more views!",
        "adet": "pcs",
        "EN İYİ FİYAT": "BEST PRICE",
        "Tüm premium özelliklere eriş!": "Access all premium features!",
        "Sınırsız Beğeni": "Unlimited Likes",
        "5 Super Like / Gün": "5 Super Likes / Day",
        "1 Boost / Ay": "1 Boost / Month",
        "Seni Kimlerin Beğendiğini Gör": "See Who Liked You",
        "Geri Alma": "Rewind",
        "Konum Değiştir": "Change Location",
        "Gizli Mod": "Incognito Mode",
        "EN POPÜLER": "MOST POPULAR",
        "Satın Al -": "Purchase -",
        "Abonelik otomatik olarak yenilenir. İstediğin zaman iptal edebilirsin.": "Subscription renews automatically. Cancel anytime.",
        "Premium Aktif! 🎉": "Premium Activated! 🎉",
        "Harika!": "Great!",
        "VibeU Gold aboneliğin aktif edildi!": "Your VibeU Gold subscription is active!",
        "Premium üyeliğiniz aktif edildi!": "Your premium subscription is active!",
        "Sınırsız eşleşme, sınırsız bağlantı": "Unlimited matches, unlimited connections",
        "Günlük limit olmadan beğen": "Like without daily limits",
        "Kimin beğendiğini anında öğren": "Instantly see who liked you",
        "Global Keşif": "Global Discovery",
        "Dünyanın her yerinden bağlan": "Connect from anywhere in the world",
        "Özel Profil Çerçevesi": "Special Profile Frame",
        "Premium rozeti ile öne çık": "Stand out with Premium badge",
        "Öncelikli Görünürlük": "Priority Visibility",
        "Profilin daha çok gösterilsin": "Get your profile seen more",
        "Sınırsız Geri Alma": "Unlimited Rewind",
        "Yanlışlıkla geçtiklerini geri al": "Undo accidental swipes",
        "Planını Seç": "Choose Your Plan",
        "EN İYİ": "BEST",
        "POPÜLER": "POPULAR",
        "Haftalık": "Weekly",
        "Aylık": "Monthly",
        "Yıllık": "Yearly",
        "/hafta": "/week",
        "Tasarruf": "Savings",
        "Şimdilik Geç": "Skip for Now",
        "Kullanım Şartları": "Terms of Use",
        "Gizlilik Politikası": "Privacy Policy",
        "Satın Alımları Geri Yükle": "Restore Purchases",
        "Tebrikler! 🎉": "Congratulations! 🎉",
        
        // Diamond / Gems
        "Elmaslarım": "My Gems",
        "Elmas": "Gems",
        "Günlük Ödül": "Daily Reward",
        "Ödülümü Al": "Claim Reward",
        "Bugünkü ödülünü aldın!": "You claimed your reward today!",
        "Yeni ödül:": "Next reward:",
        "saat": "hours",
        "dakika": "minutes",
        "Reklam İzle": "Watch Ad",
        "Reklam İzle & 25 Elmas Kazan": "Watch Ad & Earn 25 Gems",
        "Günde 1 kez kullanılabilir": "Available once a day",
        "Bugün reklamı izledin!": "You watched the ad today!",
        "Yarın tekrar izleyebilirsin": "You can watch again tomorrow",
        "Reklam izle, 25 elmas kazan": "Watch ad, earn 25 gems",


        "🌍 Global (Dünya Geneli)": "🌍 Global (Worldwide)",
        "🇹🇷 Türkiye (Yerel)": "🇹🇷 Turkey (Local)",
        "Yaş Aralığı": "Age Range",
        "Hızlı Filtreler": "Quick Filters",
        "Sadece Doğrulanmış": "Verified Only",
        "Fotoğraflı Profiller": "Profiles with Photos",
        "İlişki Amacı": "Relationship Goal",
        "Hepsi": "All",
        "Ciddi İlişki": "Serious Relationship",
        "Arkadaşlık": "Friendship",
        "Belirsiz": "Not Sure",
        "Evlilik": "Marriage",
        "Filtreleri Sıfırla": "Reset Filters",
        "Sıfırla": "Reset",
        "Uygula": "Apply",
        "Filtreler sıfırlandı": "Filters reset",

        // Moods Detail
        "Ne yapmak istersin?": "What do you want to do?",
        "Kişi Bul": "Find People",
        "Aynı ruh halindeki insanlarla tanış": "Meet people with same mood",
        "Tavsiye Al": "Get Advice",
        "Ruh haline göre öneriler al": "Get recommendations based on mood",
        "Kişi Bul'a Geç": "Switch to Find People",
        "İçin Öneriler": "Recommendations for",
        "Ruh Hali": "Mood",

        // Mood Tips - Adventure
        "Doğa Yürüyüşü": "Hiking",
        "Şehirden kaç, ormanda kaybol!": "Escape the city, get lost in the woods!",
        "Hafta Sonu Kaçamağı": "Weekend Getaway",
        "Yakın bir şehre git, keşfet": "Visit a nearby city, explore",
        "Fotoğraf Gezisi": "Photo Trip",
        "Yeni yerler keşfet, anıları yakala": "Explore new places, capture memories",

        // Mood Tips - Romantic
        "Romantik Akşam": "Romantic Evening",
        "Mum ışığında yemek, şarap": "Candlelight dinner, wine",
        "Gece Yürüyüşü": "Night Walk",
        "Sahilde el ele yürü": "Walk hand in hand on the beach",
        "Sürpriz Hediye": "Surprise Gift",
        "Küçük ama anlamlı bir şey al": "Buy something small but meaningful",
        
        // Mood Tips - Chill
        "Kahve Molası": "Coffee Break",
        "Favori kahve dükkanında dinlen": "Relax at your favorite coffee shop",
        "Kitap Keyfi": "Book Enjoyment",
        "Rahat bir köşede kitabına dal": "Dive into your book in a cozy corner",
        "Yoga Seansı": "Yoga Session",
        "Bedenini ve zihnini dinlendir": "Rest your body and mind",

        // Mood Tips - Party
        "Konser": "Concert",
        "Canlı müzik enerjisi yakala": "Catch the live music energy",
        "Dans Gecesi": "Dance Night",
        "Kulüpte sabaha kadar eğlen": "Have fun at the club until morning",
        "Ev Partisi": "House Party",
        "Arkadaşlarını topla, parti kur": "Gather friends, throw a party",

        // Mood Tips - Deep
        "Derin Sohbet": "Deep Conversation",
        "Hayatın anlamını tartış": "Discuss the meaning of life",
        "Sanat Galerisi": "Art Gallery",
        "Eserleri yorumla, düşün": "Interpret works, think",
        "Günlük Tut": "Keep a Journal",
        "Düşüncelerini yazıya dök": "Write down your thoughts",
        
        // Mood Tips - Creative
        "Resim Yap": "Paint",
        "Tuval al, hayal gücünü çalıştır": "Get a canvas, activate your imagination",
        




        // Mood Tips - Default
        "Yeni Bir Şey Dene": "Try Something New",
        "Konfor alanından çık": "Get out of your comfort zone",
        "Arkadaşlarla Buluş": "Meet Friends",
        "Sosyalleş, eğlen": "Socialize, have fun",
        "Kendine Zaman Ayır": "Make Time for Yourself",
        "Sevdiğin bir aktivite yap": "Do an activity you love",

        // Profile Overlay
        "İlk İzlenim ile öne çık": "Stand out with First Impression",
        "Eşleşmeden önce ona mesaj göndererek dikkatini çek. Ona profilinde hoşuna giden şeyin ne olduğunu söyleyebilir, iltifat edebilir veya onu güldürebilirsin.": "Catch their attention by sending a message before matching. You can tell them what you like about their profile, compliment them, or make them laugh.",
        "Mesajın...": "Your message...",
        "Mesajın gönderildi!": "Message sent!",

        // Other
        "Beğeniler": "Likes",

        "Seçkinler": "Top Picks",
        "Profili Düzenle": "Edit Profile",
        "Fotoğraflar": "Photos",
        "İlgi Alanları": "Interests",
        "Sosyal Medya": "Social Media",
        "Çıkış Yap": "Log Out",
        "Boostlarım": "My Boosts",
        "Abonelikler": "Subscriptions",
        "Güvenlik": "Security",
        "Ayarlar": "Settings",
        "Giriş Yap": "Log In",
        "Kayıt Ol": "Sign Up",
        "Arkadaşlar": "Friends",
        "Profil": "Profile",
        "Mesajlar": "Messages",
        "Bildirimler": "Notifications",
        "Hesabım": "My Account",
        "Konum": "Location",
        "Uzaklık": "Distance",

        "Cinsiyet": "Gender",
        "Erkek": "Male",
        "Kadın": "Female",
        "Tümü": "All",

        "E-posta": "Email",
        "Şifre": "Password",
        "Şifremi Unuttum": "Forgot Password",
        "Geri": "Back",
        "İleri": "Next",

        "Hata": "Error",
        "Başarılı": "Success",
        "Kullanıcı Adı": "Username",
        "Doğum Tarihi": "Date of Birth",
        "Biyografi": "Bio",
        "Düzenle": "Edit",
        "Sil": "Delete",
        "Kapat": "Close",
        "Ara": "Search",
        "Sohbet": "Chat",
        "Engelle": "Block",
        "Şikayet Et": "Report",
        "Eşleşmeyi Kaldır": "Unmatch",
        "Galeriden Seç": "Pick from Gallery",
        "Kamera": "Camera",
        "İzin Ver": "Allow",
        "Reddet": "Deny",
        "Tekrar Dene": "Try Again",
        "Astroloji": "Astrology",
        "Ruh haline göre eşleş": "Match by mood",
        "Bugün zaten giriş yaptın!": "Already checked in today!",
        "Tebrikler! Reklam izleyerek 50 Elmas kazandın! 💎": "Congrats! Earned 50 Diamonds! 💎",
        "Harika! 🎉": "Great! 🎉",
        "Filtrelerinize uygun kullanıcı bulunamadı": "No users found matching your filters",
        "Kullanıcılar yüklenirken hata oluştu": "Error loading users",
        "Sosyal Hesaplar": "Social Accounts",
        "Kilitli": "Locked",
        "Hesaplar Gizli": "Accounts Private",
        "Sosyal medya hesaplarını görmek için arkadaş olmalısın.": "You must be friends to see social media accounts.",
        "İstek Gönderildi": "Request Sent",
        "kişisine arkadaşlık isteği gönderildi": "friend request sent to",
        "Yetersiz Elmas 💎": "Insufficient Diamonds 💎",
        "Elmas Al": "Get Diamonds",
        "Arkadaşlık isteği göndermek için 10 elmas gerekiyor. Günlük ücretsiz elmasını alabilirsin!": "Sending a friend request costs 10 diamonds. You can claim your daily free diamonds!",
        "km uzakta": "km away",
        "common_interests": "Common Interests",
        "Tarih": "Date",

        "Katılımcılar": "Attendees",
        "kişi": "people",
        "Açıklama": "Description",
        "Bilet Al": "Buy Ticket",
        "Etkinliğe Katıl": "Join Event",
        "Çifte Randevu arkadaşları": "Double Date Friends",
        "Çifte Randevu'da en fazla 3 arkadaşınla çift olabilirsin.": "You can pair with up to 3 friends on Double Date.",
        "Daha fazla bilgi edin": "Learn more",
        "Arkadaşlardan gelen davetler": "Invites from friends",
        "Çifte Randevu davetlerini burada göreceksin.": "You will see Double Date invites here.",
        "Arkadaşlarını Davet Et": "Invite Friends",
        "Seni Çifte Randevu'ya davet etti": "Invited you to Double Date",
        "Kullanıcı": "User",
        "Profili Tamamla": "Complete Profile",
        "Profilini öne çıkar": "Highlight your profile",
        "Ortak noktalarını bul": "Find common grounds",
        "Hesaplarını bağla": "Connect accounts",
        "Hızlıca paylaş": "Share quickly",

        "Görünüm": "Appearance",
        "Tema": "Theme",
        "Dil": "Language",
        "Şirket": "Company",
        "Fiziksel Özellikler": "Physical Attributes",
        "Boy (cm)": "Height (cm)",
        "Burç": "Zodiac",
        "Yaşam Tarzı": "Lifestyle",
        "Sigara": "Smoking",
        "Alkol": "Drinking",
        "Egzersiz": "Exercise",
        "Evcil Hayvan": "Pets",
        "İlişki Tercihleri": "Relationship Goals",
        "Ne Arıyorum": "Looking For",
        "Çocuk İstiyor musun": "Want Kids",
        "Hobiler & İlgi Alanları": "Hobbies & Interests",
        "En fazla 8 hobi seç": "Select up to 8 hobbies",
        "Sosyal Medya Hesapları": "Social Media Accounts",
        "Fotoğrafı Değiştir": "Change Photo",
        "Seç": "Select",
        "Fotoğrafların": "Your Photos",
        "Sürükleyip bırakarak sıralamayı değiştir": "Drag and drop to reorder",
        "Ana Fotoğraf": "Main Photo",
        "Silmek istediğine emin misin?": "Are you sure you want to delete?",

        "Sıralamak için basılı tut ve sürükle": "Press and hold to drag and reorder",
        "İlk fotoğraf profil fotoğrafın olacak": "The first photo will be your profile photo",
        "Silinemez": "Cannot Delete",
        "En az 1 fotoğrafın olmalı. Son fotoğrafı silemezsin.": "You must have at least 1 photo. You cannot delete the last photo.",
        "fotoğraf kaydedildi.": "photos saved.",
        "fotoğraf": "photos",
        
        // Settings & Privacy
        "Profilimi Keşfetten Gizle": "Hide Profile from Discovery",
        "Son Görülmeyi Gizle": "Hide Last Seen",
        "Okundu Bilgisini Gizle": "Hide Read Receipts",
        "Verilerimi İndir": "Download My Data",
        "Keşif": "Discovery",
        "Görünürlük": "Visibility",
        "Veri": "Data",
        "Yaşımı Gizle": "Hide My Age",
        "Mesafeyi Gizle": "Hide Distance",
        "Çevrimiçi Durumu Gizle": "Hide Online Status",
        "Kullanıcı Bildir": "Report User",
        "Güvenlik İpuçları": "Safety Tips",
        "Bildirme sebebinizi seçin:": "Select reason for reporting:",
        "Ek bilgi (opsiyonel):": "Additional info (optional):",
        "Uygunsuz fotoğraf": "Inappropriate photo",
        "Spam veya sahte profil": "Spam or fake profile",
        "Taciz veya zorbalık": "Harassment or bullying",
        "Uygunsuz mesajlar": "Inappropriate messages",
        "Yaşı tutmuyor": "Underage",
        "Diğer": "Other",
        "Bildir": "Report",
        
        // Safety Tips
        "Kişisel Bilgiler": "Personal Information",
        "Adres, telefon numarası gibi kişisel bilgilerinizi paylaşmayın.": "Do not share personal info like address or phone number.",
        "Video Görüşme": "Video Call",
        "Buluşmadan önce video görüşme yapın.": "Have a video call before meeting.",
        "Halka Açık Yerler": "Public Places",
        "İlk buluşmalarınızı halka açık yerlerde yapın.": "Meet in public places for the first time.",
        "Arkadaşlarınıza Söyleyin": "Tell Friends",
        "Nereye gittiğinizi birine söyleyin.": "Tell someone where you are going.",
        
        // Blocked Users
        "Engellenen kullanıcı yok": "No blocked users",
        "Engellendi": "Blocked",
        "Engeli Kaldır": "Unblock",
        
        // Boost & Gems
        "Boost & Elmas": "Boost & Gems",

        "Boost": "Boost",
        "Günlük 100 Elmas Al": "Claim Daily 100 Gems",
        "Bugünkü ödülünüzü aldınız!": "You claimed your reward today!",
        "Elmas Kullanımı": "Gem Usage",
        "Eşleşme isteği: 10 elmas": "Match request: 10 gems",
        "30 dakika boyunca profilini öne çıkar!": "Boost your profile for 30 minutes!",

        
        // Edit Views Extra
        "İlgi Alanlarını Seç": "Select Interests",
        "En fazla 10 tane seçebilirsin": "You can select up to 10",
        "ilgi alanı kaydedildi.": "interests saved.",
        "Hesaplarını ekle, profilinde görünsün": "Add your accounts to show on profile",
        "Hesapların profilinde görünecek": "Accounts will be visible on your profile",
        "Sosyal medya hesapların güncellendi.": "Social media accounts updated.",
        "kullanici_adi": "username",
        "Profil linki": "Profile link",
        
        // Language & Country
        "Dil Seçin": "Select Language",
        "Uygulama dilini değiştirin": "Change app language",
        "Dil değiştirildi": "Language changed",
        "Ülke Seç": "Select Country",
        "Ülke Ara": "Search Country",
        
        // QR Extra


        
        // Sheet Views
        "no_favorites": "No Favorites",
        "no_favorites_message": "You haven't favorited anyone yet.",
        "favorites": "Favorites",
        "done": "Done",
        "no_requests": "No Requests",
        "no_requests_message": "You haven't received any friend requests yet.",
        "requests": "Requests",
        "boost_your_profile": "Boost Your Profile",
        "boost_description": "Boost your profile for 30 minutes and get more matches!",
        "boost_benefit": "30 minutes highlight",
        "see_who_liked_you": "See Who Liked You",
        "premium_required_likes": "Upgrade to Premium to see who liked you.",
        "upgrade_to_premium": "Upgrade to Premium",
        "no_likes_yet": "No Likes Yet",
        "no_likes_message": "Your profile hasn't received any likes yet. Edit your profile and be more active!",
        "liked_you": "Liked You",
        "search_users": "Search Users",
        "search_hint": "Start typing to search username...",
        "search": "Search",
        "cancel": "Cancel",





        "Elmas Satın Al": "Buy Gems",
        "Popüler": "Popular",
        "En İyi Değer": "Best Value",
        "Elmas Nasıl Kullanılır?": "How to use Gems?",
        "Eşleşme isteği göndermek: 10 elmas": "Send match request: 10 gems",
        "Her gün ücretsiz 100 elmas al": "Get 100 free gems daily",
        
        // Social & Notifications
        "Çevrimiçi": "Online",
        "Son Eklenen": "Recently Added",
        "İsme Göre": "By Name",
        "Çevrimiçi Önce": "Online First",
        "Arkadaş": "Friend",
        "Arkadaş ara...": "Search friends...",
        "Yükleniyor...": "Loading...",
        "Henüz arkadaşın yok": "No friends yet",
        "Sonuç bulunamadı": "No results found",
        "Keşfet'ten yeni insanlarla tanış": "Meet new people from Explore",
        "Farklı bir arama dene": "Try a different search",
        "Arkadaşlıktan Çıkar": "Unfriend",
        "arkadaş listenizden çıkarılacak.": "will be removed from your friends list.",
        "Çıkar": "Remove",
        "Bugün": "Today",
        "Bu Hafta": "This Week",
        "Daha Önce": "Earlier",
        "Tümünü Oku": "Read All",
        "Okunmamış": "Unread",
        "İstekler": "Requests",
        "Bildirim Yok": "No Notifications",
        "Yeni bildirimler geldiğinde burada görünecek": "New notifications will appear here",
        "Seyahat": "Travel",

        "Yüzme": "Swimming",
        "Yoga": "Yoga",
        "Kitap": "Books"
    ]
    
    static let es: [String: String] = [
        "Sanat": "Arte",
        "Spor": "Deportes",

        // Time Units
        "1 Hafta": "1 Semana",
        "1 Ay": "1 Mes",
        "6 Ay": "6 Meses",
        "Hafta": "Semana",
        "Ay": "Mes",
        "Yıl": "Año",

        // Profile & Premium
        "Mevcut:": "Actual:",
        "30 dakika boyunca profilini öne çıkar ve 10 kat daha fazla görüntülenme al!": "¡Destaca tu perfil por 30 min y obtén 10x más visitas!",
        "adet": "uds",
        "EN İYİ FİYAT": "MEJOR PRECIO",
        "Tüm premium özelliklere eriş!": "¡Accede a todas las funciones premium!",
        "Sınırsız Beğeni": "Me Gusta Ilimitados",
        "5 Super Like / Gün": "5 Súper Me Gusta / Día",
        "1 Boost / Ay": "1 Boost / Mes",
        "Seni Kimlerin Beğendiğini Gör": "Mira Quién Te Gustó",
        "Geri Alma": "Rebobinar",
        "Konum Değiştir": "Cambiar Ubicación",
        "Gizli Mod": "Modo Incógnito",
        "EN POPÜLER": "MÁS POPULAR",
        "Satın Al -": "Comprar -",
        "Abonelik otomatik olarak yenilenir. İstediğin zaman iptal edebilirsin.": "La suscripción se renueva automáticamente. Cancela cuando quieras.",
        "Premium Aktif! 🎉": "¡Premium Activado! 🎉",
        "Harika!": "¡Genial!",
        "VibeU Gold aboneliğin aktif edildi!": "¡Tu suscripción VibeU Gold está activa!",
        "Premium üyeliğiniz aktif edildi!": "¡Tu suscripción premium está activa!",
        "Sınırsız eşleşme, sınırsız bağlantı": "Coincidencias ilimitadas, conexiones ilimitadas",
        "Günlük limit olmadan beğen": "Da me gusta sin límites diarios",
        "Kimin beğendiğini anında öğren": "Mira quién te gustó al instante",
        "Global Keşif": "Descubrimiento Global",
        "Dünyanın her yerinden bağlan": "Conéctate desde cualquier lugar del mundo",
        "Özel Profil Çerçevesi": "Marco de Perfil Especial",
        "Premium rozeti ile öne çık": "Destaca con la insignia Premium",
        "Öncelikli Görünürlük": "Visibilidad Prioritaria",
        "Profilin daha çok gösterilsin": "Haz que tu perfil sea más visto",
        "Sınırsız Geri Alma": "Rebobinado Ilimitado",
        "Yanlışlıkla geçtiklerini geri al": "Deshaz los deslizamientos accidentales",
        "Planını Seç": "Elige Tu Plan",
        "EN İYİ": "MEJOR",
        "POPÜLER": "POPULAR",
        "Haftalık": "Semanal",
        "Aylık": "Mensual",
        "Yıllık": "Anual",
        "/hafta": "/semana",
        "Tasarruf": "Ahorro",
        "Şimdilik Geç": "Omitir por Ahora",
        "Kullanım Şartları": "Términos de Uso",
        "Gizlilik Politikası": "Política de Privacidad",
        "Satın Alımları Geri Yükle": "Restaurar Compras",
        "Tebrikler! 🎉": "¡Felicidades! 🎉",
        
        // Diamond / Gems
        "Elmaslarım": "Mis Gemas",
        "Elmas": "Gemas",
        "Günlük Ödül": "Recompensa Diaria",
        "Ödülümü Al": "Reclamar Recompensa",

        "Yeni ödül:": "Próxima recompensa:",
        "saat": "horas",
        "dakika": "minutos",
        "Reklam İzle": "Ver Anuncio",
        "Reklam İzle & 25 Elmas Kazan": "Ver Anuncio y Ganar 25 Gemas",
        "Günde 1 kez kullanılabilir": "Disponible una vez al día",
        "Bugün reklamı izledin!": "¡Viste el anuncio hoy!",
        "Yarın tekrar izleyebilirsin": "Puedes ver de nuevo mañana",
        "Reklam izle, 25 elmas kazan": "Ver anuncio, ganar 25 gemas",

        "Beğeniler": "Me Gusta",
        "🌍 Global (Dünya Geneli)": "🌍 Global (Mundial)",
        "🇹🇷 Türkiye (Yerel)": "🇹🇷 Turquía (Local)",
        "Yaş Aralığı": "Rango de Edad",
        "Hızlı Filtreler": "Filtros Rápidos",
        "Sadece Doğrulanmış": "Solo Verificados",
        "Fotoğraflı Profiller": "Perfiles con Fotos",
        "İlişki Amacı": "Objetivo de Relación",
        "Hepsi": "Todos",
        "Ciddi İlişki": "Relación Seria",
        "Arkadaşlık": "Amistad",
        "Belirsiz": "No Estoy Seguro",
        "Evlilik": "Matrimonio",
        "Filtreleri Sıfırla": "Restablecer Filtros",
        "Sıfırla": "Restablecer",
        "Uygula": "Aplicar",
        "Filtreler sıfırlandı": "Filtros restablecidos",

        // Moods Detail
        "Ne yapmak istersin?": "¿Qué quieres hacer?",
        "Kişi Bul": "Encontrar Personas",
        "Aynı ruh halindeki insanlarla tanış": "Conoce gente con el mismo ánimo",
        "Tavsiye Al": "Obtener Consejos",
        "Ruh haline göre öneriler al": "Obtén recomendaciones según tu ánimo",
        "Kişi Bul'a Geç": "Ir a Encontrar Personas",
        "İçin Öneriler": "Recomendaciones para",
        "Ruh Hali": "Estado de Ánimo",

        // Mood Tips - Adventure
        "Doğa Yürüyüşü": "Senderismo",
        "Şehirden kaç, ormanda kaybol!": "¡Escapa de la ciudad, piérdete en el bosque!",
        
        // Game Match
        "Oyun Arkadaşı": "Compañero de Juego",
        "Birlikte oynayacak arkadaş bul": "Encuentra un amigo para jugar",
        "Oyuncu ara...": "Buscar jugadores...",
        "Oyun": "Juego",
        "Rank": "Rango",
        "Oyuncu bulunamadı": "No se encontraron jugadores",
        "Filtreleri değiştirmeyi dene": "Intenta cambiar los filtros",
        "Oyun İsteği Gönder": "Enviar Solicitud de Juego",
        "Gönder": "Enviar",
        "ile oynamak için istek gönderilsin mi? (10 Elmas)": "¿Enviar solicitud para jugar con? (10 Gemas)",
        
        // Music Match
        "Müzik Eşleş": "Match Musical",
        "Aynı müzik zevkine sahip insanlarla tanış": "Conoce gente con el mismo gusto musical",
        "Müzik severleri ara...": "Buscar amantes de la música...",
        "Müzik sevgili bulunamadı": "No se encontraron amantes de la música",
        "Müzik İsteği Gönder": "Enviar Solicitud Musical",
        "şarkısını dinlemek için istek gönderilsin mi? (10 Elmas)": "¿Enviar solicitud para escuchar con? (10 Gemas)",

        // Gourmet
        "Gurme Deneyimi": "Experiencia Gourmet",
        "100+ restoran, rezervasyon yap, eşleş": "100+ restaurantes, reserva, haz match",
        "Restoran ara...": "Buscar restaurantes...",
        "Mutfak": "Cocina",
        "Şehir": "Ciudad",
        "Fiyat": "Precio",
        "Özel Lezzetler": "Sabores Especiales",
        
        // Book Club
        "Kitap Kulübü": "Club de Lectura",
        "Aynı kitabı okuyan insanlarla tanış": "Conoce gente leyendo el mismo libro",
        "Kitap veya yazar ara...": "Buscar libro o autor...",
        "Roman": "Novela",
        "Klasik": "Clásico",
        "Bilim Kurgu": "Ciencia Ficción",
        "Fantastik": "Fantasía",
        "Polisiye": "Crimen",
        "Tarih": "Historia",
        "Biyografi": "Biografía",
        "Felsefe": "Filosofía",
        "Psikoloji": "Psicología",
        "Şiir": "Poesía",
        "okuyucu": "lectores",
        "sayfa": "páginas",
        "Okuma Grubuna Katıl": "Unirse al Grupo de Lectura",
        
        // Travel Buddy
        "Seyahat Arkadaşı": "Compañero de Viaje",
        "Dünyayı birlikte keşfet": "Explora el mundo juntos",
        "Destinasyon ara...": "Buscar destino...",
        "Stil": "Estilo",
        "Bütçe": "Presupuesto",
        "Süre": "Duración",
        "Macera": "Aventura",
        "Kültür": "Cultura",
        "Plaj": "Playa",
        "Doğa": "Naturaleza",
        "Lüks": "Lujo",
        "Backpacking": "Mochilero",
        "Uçak Bileti Al": "Comprar Boleto de Avión",
        "Seyahat Arkadaşı Bul": "Buscar Compañero de Viaje",
        
        // Daily Streak & Ads
        "Günlük Seri": "Racha Diaria",
        "Bugün giriş yap!": "¡Inicia sesión hoy!",
        "Günlük Seri!": "¡Racha Diaria!",
        "Serin devam ediyor🔥": "La racha continúa🔥",
        "gün süren var": "días de racha",

        "Seriyi tamamla, elmas kazan!": "¡Completa la racha, gana gemas!",
        "Reklam İzle & Kazan": "Ver Anuncio y Ganar",
        "+10 Elmas": "+10 Gemas",
        "Kısa bir reklam izle, anında elmas kazan!": "¡Mira un anuncio corto, gana gemas al instante!",
        "İzle": "Ver",
        
        // Likes View
        "Beğenenler": "Me Gusta",




        // Mood Tips - Romantic
        "Romantik Akşam": "Velada Romántica",
        "Mum ışığında yemek, şarap": "Cena a la luz de las velas, vino",
        "Gece Yürüyüşü": "Paseo Nocturno",
        "Sahilde el ele yürü": "Camina de la mano por la playa",
        "Sürpriz Hediye": "Regalo Sorpresa",
        "Küçük ama anlamlı bir şey al": "Compra algo pequeño pero significativo",
        
                // Mood Tips - Chill
        "Kahve Molası": "Pausa para Café",
        "Favori kahve dükkanında dinlen": "Relájate en tu cafetería favorita",
        "Kitap Keyfi": "Disfrutar de un Libro",
        "Rahat bir köşede kitabına dal": "Sumérgete en tu libro en un rincón acogedor",
        "Yoga Seansı": "Sesión de Yoga",
        "Bedenini ve zihnini dinlendir": "Descansa tu cuerpo y tu mente",

        // Mood Tips - Party
        "Konser": "Concierto",
        "Canlı müzik enerjisi yakala": "Atrapa la energía de la música en vivo",
        "Dans Gecesi": "Noche de Baile",
        "Kulüpte sabaha kadar eğlen": "Diviértete en el club hasta la mañana",
        "Ev Partisi": "Fiesta en Casa",
        "Arkadaşlarını topla, parti kur": "Reúne amigos, haz una fiesta",

        // Mood Tips - Deep
        "Derin Sohbet": "Conversación Profunda",
        "Hayatın anlamını tartış": "Discute el significado de la vida",
        "Sanat Galerisi": "Galería de Arte",
        "Eserleri yorumla, düşün": "Interpreta obras, piensa",
        "Günlük Tut": "Llevar un Diario",
        "Düşüncelerini yazıya dök": "Escribe tus pensamientos",
        
        // Mood Tips - Creative
        "Resim Yap": "Pintar",
        "Tuval al, hayal gücünü çalıştır": "Consigue un lienzo, activa tu imaginación",
        "Müzik Yap": "Hacer Música",
        "Enstrüman çal veya beat yap": "Toca un instrumento o haz un beat",
        "Fotoğrafçılık": "Fotografía",
        "Farklı açılardan dünyayı yakala": "Captura el mundo desde diferentes ángulos",

        // Mood Tips - Default
        "Yeni Bir Şey Dene": "Prueba Algo Nuevo",
        "Konfor alanından çık": "Sal de tu zona de confort",
        "Arkadaşlarla Buluş": "Reunirse con Amigos",
        "Sosyalleş, diviértete": "Socializa, diviértete",
        "Kendine Zaman Ayır": "Tómate Tiempo para Ti",
        "Sevdiğin bir aktivite yap": "Haz una actividad que ames",

        // Profile Overlay
        "İlk İzlenim ile öne çık": "Destaca con Primera Impresión",
        "Eşleşmeden önce ona mesaj göndererek dikkatini çek. Ona profilinde hoşuna giden şeyin ne olduğunu söyleyebilir, iltifat edebilir veya onu güldürebilirsin.": "Llama su atención enviando un mensaje antes de hacer match. Puedes decirle qué te gusta de su perfil, hacerle un cumplido o hacerle reír.",
        "Mesajın...": "Tu mensaje...",
        "Mesajın gönderildi!": "¡Mensaje enviado!",
        
        // Favorites/Likes View

        "Hızlı Tanış": "Cita Rápida",
        "Ses Tanış": "Cita de Voz",
        "Burç Eşleş": "Astro Match",
        "Premium'a Geç": "Hazte Premium",
        "Sınırsız beğeni, reklamsız kullanım, özel özellikler": "Me gusta ilimitados, sin anuncios, funciones especiales",
        "Premium'u Keşfet": "Descubrir Premium",
        "Daha sonra": "Más tarde",
        "Yaklaşan Etkinlikler": "Próximos Eventos",

        "Romantik": "Romántico",
        "Sakin": "Tranquilo",
        "Bugün Nasıl Hissediyorsun?": "¿Cómo te sientes hoy?",
        "Ruh Eşini Bul": "Encuentra tu Alma Gemela",
        "Başla": "Empezar",
        "Sana Özel": "Para Ti",
        "Paylaş": "Compartir",
        "Çift Randevu": "Cita Doble",
        "Reklam izleniyor...": "Viendo anuncio...",
        "Reklam Süresi": "Pausa Publicitaria",
        "İzle ve Devam Et": "Ver y Continuar",
        "Sınırsız beğeni gönder": "Enviar me gusta ilimitados",
        "Gizli profil görüntüleme": "Visualización de perfil privada",
        "Öncelikli eşleşme": "Coincidencia prioritaria",
        "Reklamsız deneyim": "Experiencia sin anuncios",

        "VibeU Gold": "VibeU Gold",
        "Filtreler": "Filtros",
        "Çifte Randevu": "Cita Doble",
        "Arkadaşlarınla birlikte eşleş": "Empareja con amigos",
        "DAHA FAZLA AL": "OBTENER MÁS",
        "GÖRÜNTÜLE": "VER",

        "Super Like ile öne çık ve eşleşme şansını 3 kat artır!": "¡Destaca con Super Like y triplica tus posibilidades!",


        // Discover
        "Bakiye:": "Saldo:",
        "Premium ile reklamsız kullan": "Sin anuncios con Premium",
        "Son Zamanlarda Aktif": "Activo Recientemente",
        "Arkadaşlık isteği gönderildi!": "¡Solicitud de amistad enviada!",
        "Yetersiz elmas (100 gerekli)": "Diamantes insuficientes (100 requeridos)",
        "Yetersiz elmas! Arkadaşlık isteği göndermek için 10 elmas gerekli.": "¡Diamantes insuficientes! Se requieren 10 diamantes.",
        "Super Like + Arkadaşlık isteği gönderildi!": "¡Super Like + Solicitud enviada!",
        




        // QR Profile
        "Hikayende Paylaş": "Compartir en Historia",
        "QR Profilim": "Mi Perfil QR",
        "Kaydedildi ✓": "Guardado ✓",
        "QR kod fotoğraflarına kaydedildi.": "Código QR guardado en fotos.",
        "Arkadaş Ekle": "Añadir Amigo",
        "QR kod veya AirDrop ile arkadaşlarını ekle": "Añadir amigos vía QR o AirDrop",
        "QR Kodunu Göster": "Mostrar Código QR",
        "Arkadaşların seni tarayarak ekleyebilir": "Tus amigos pueden escanear para añadirte",
        "QR Kod Tara": "Escanear Código QR",
        "Arkadaşının QR kodunu tara ve ekle": "Escanea el QR de un amigo",
        "Yakındakileri Bul": "Buscar Cercanos",
        "AirDrop ile yakındaki VibeU kullanıcılarını bul": "Buscar usuarios cercanos con AirDrop",
        "Yakındaki Kullanıcılar": "Usuarios Cercanos",
        "Bu QR kodu arkadaşlarına göster": "Muestra este código QR a tus amigos",
        "QR Kodum": "Mi Código QR",
        "QR Kodu çerçevenin içine hizalayın": "Alinea el código QR dentro del marco",
        
        // Explore
        "Keşfet": "Explorar",


        
        // Vibe Quiz
        "Vibe Quiz": "Cuestionario Vibe",
        "8 soruluk kişilik testini tamamla ve ruh eşini bul!": "¡Completa el test de 8 preguntas y encuentra tu alma gemela!",
        "Teste Başla": "Iniciar Test",
        "Soru": "Pregunta",
        "Kişilik Tipin": "Tu Tipo de Personalidad",
        "Eşleşmeye Başla": "Empezar a Coincidir",
        "Maceracı": "Aventurero",
        "Düşünür": "Pensador",
        "Yaratıcı": "Creativo",
        "Sosyal": "Social",
        "Yeni deneyimlere açık, enerjik ve sosyal birisin!": "¡Eres abierto a nuevas experiencias, enérgico y social!",
        "Derin, sakin ve analitik bir kişiliğe sahipsin!": "¡Tienes una personalidad profunda, tranquila y analítica!",
        "Hayal gücü kuvvetli, özgün ve ilham vericisin!": "¡Tienes una gran imaginación, eres único e inspirador!",
        "İnsanlarla olmayı seven, enerjik ve eğlencelisin!": "¡Te encanta estar con gente, eres enérgico y divertido!",
        "Benzersiz bir kişiliğe sahipsin!": "¡Tienes una personalidad única!",

        "Kişilik testine göre eşleş": "Emparejar según personalidad",
        "Birlikte oyna": "Jugar juntos",
        "Aynı zevk": "Mismo gusto",
        "Yemek keşfi": "Descubrimiento gastronómico",
        "Aynı kitap": "Mismo libro",

        "Yakında yeni etkinlikler...": "Próximamente nuevos eventos...",
        "CANLI": "EN VIVO",

        "Özel Deneyimler": "Experiencias Exclusivas",


        // Live Events (Mock)
        "Canlı Müzik - Indie Rock": "Música en Vivo - Indie Rock",
        "Yerel indie rock gruplarının performansı": "Actuación de bandas locales de indie rock",
        "Jazz Night": "Noche de Jazz",
        "Caz müzik severler için özel gece": "Noche especial para amantes del jazz",
        "Kahve & Sohbet": "Café y Charla",
        "Yeni insanlarla tanış, kahve iç": "Conoce gente nueva, toma café",
        "Kitap Okuma Kulübü": "Club de Lectura",
        "Bu ay: Sabahattin Ali - Kürk Mantolu Madonna": "Este mes: Sabahattin Ali - Madonna con abrigo de piel",
        "Yoga & Tanışma": "Yoga y Encuentro",
        "Sabah yogası ve kahvaltı": "Yoga matutino y desayuno",
        "Gurme Akşam Yemeği": "Cena Gourmet",
        "Şef menüsü ve yeni tanışmalar": "Menú del chef y nuevos encuentros",
        "Sanat Galerisi Turu": "Tour de Galería de Arte",
        "Çağdaş sanat sergisi gezisi": "Visita a exposición de arte contemporáneo",
        "Plaj Voleybolu": "Voleibol de Playa",
        "Dostluk maçı ve eğlence": "Partido amistoso y diversión",
        "Müzik": "Música",
        "Kahve": "Café",
        "Wellness": "Bienestar",
        "Yemek": "Comida",


        


        // Moods & Subtitles
        "Heyecan": "Emoción",
        "Aşk": "Amor",
        "Dinlenme": "Descanso",
        "Eğlence": "Diversión",
        "Sohbet": "Charla",
        "Parti": "Fiesta",
        "Derin": "Profundo",
        "Profili Düzenle": "Editar Perfil",
        "Fotoğraflar": "Fotos",
        "İlgi Alanları": "Intereses",
        "Sosyal Medya": "Redes Sociales",
        "Çıkış Yap": "Cerrar Sesión",
        "Boostlarım": "Mis Boosts",
        "Abonelikler": "Suscripciones",
        "Güvenlik": "Seguridad",
        "Ayarlar": "Ajustes",
        "Giriş Yap": "Iniciar Sesión",
        "Kayıt Ol": "Registrarse",
        "Arkadaşlar": "Amigos",
        "Profil": "Perfil",
        "Mesajlar": "Mensajes",
        "Bildirimler": "Notificaciones",
        "Hesabım": "Mi Cuenta",
        "Konum": "Ubicación",
        "Uzaklık": "Distancia",

        "Cinsiyet": "Género",
        "Erkek": "Hombre",
        "Kadın": "Mujer",
        "Tümü": "Todos",
        "Kaydet": "Guardar",
        "İptal": "Cancelar",
        "E-posta": "Correo",
        "Şifre": "Contraseña",
        "Şifremi Unuttum": "Olvidé mi Contraseña",
        "Geri": "Atrás",
        "İleri": "Siguiente",
        "Tamam": "OK",
        "Hata": "Error",
        "Başarılı": "Éxito",
        "Kullanıcı Adı": "Nombre de Usuario",
        "Doğum Tarihi": "Fecha de Nacimiento",

        "Düzenle": "Editar",
        "Sil": "Eliminar",
        "Kapat": "Cerrar",
        "Ara": "Buscar",
        "Engelle": "Bloquear",
        "Şikayet Et": "Reportar",
        "Eşleşmeyi Kaldır": "Deshacer Match",
        "Galeriden Seç": "Elegir de Galería",
        "Kamera": "Cámara",
        "İzin Ver": "Permitir",
        "Reddet": "Denegar",
        "Tekrar Dene": "Intentar de Nuevo",
        "Astroloji": "Astrología",
        "Ruh haline göre eşleş": "Emparejar por estado de ánimo",
        "Bugün zaten giriş yaptın!": "¡Ya te registraste hoy!",
        "Tebrikler! Reklam izleyerek 50 Elmas kazandın! 💎": "¡Felicidades! ¡Ganaste 50 diamantes! 💎",
        "Harika! 🎉": "¡Genial! 🎉",
        "Filtrelerinize uygun kullanıcı bulunamadı": "No se encontraron usuarios con tus filtros",
        "Kullanıcılar yüklenirken hata oluştu": "Error al cargar usuarios",
        "Sosyal Hesaplar": "Cuentas Sociales",
        "Kilitli": "Bloqueado",
        "Hesaplar Gizli": "Cuentas Privadas",
        "Sosyal medya hesaplarını görmek için arkadaş olmalısın.": "Debes ser amigo para ver las redes sociales.",
        "İstek Gönderildi": "Solicitud Enviada",
        "kişisine arkadaşlık isteği gönderildi": "solicitud de amistad enviada a",
        "Yetersiz Elmas 💎": "Diamantes Insuficientes 💎",
        "Elmas Al": "Obtener Diamantes",
        "Arkadaşlık isteği göndermek için 10 elmas gerekiyor. Günlük ücretsiz elmasını alabilirsin!": "Enviar solicitud cuesta 10 diamantes. ¡Reclama tus diamantes diarios!",
        "km uzakta": "km de distancia",
        "common_interests": "Intereses Comunes",


        "Katılımcılar": "Asistentes",
        "kişi": "personas",
        "Açıklama": "Descripción",
        "Bilet Al": "Comprar Boleto",
        "Etkinliğe Katıl": "Unirse",
        "Çifte Randevu arkadaşları": "Amigos de Cita Doble",
        "Çifte Randevu'da en fazla 3 arkadaşınla çift olabilirsin.": "Puedes emparejarte con hasta 3 amigos en Cita Doble.",
        "Daha fazla bilgi edin": "Más información",
        "Arkadaşlardan gelen davetler": "Invitaciones de amigos",
        "Çifte Randevu davetlerini burada göreceksin.": "Verás las invitaciones de Cita Doble aquí.",
        "Arkadaşlarını Davet Et": "Invitar Amigos",
        "Seni Çifte Randevu'ya davet etti": "Te invitó a una Cita Doble",
        "Kullanıcı": "Usuario",

        "Görünüm": "Apariencia",
        "Tema": "Tema",
        "Dil": "Idioma",

        "Hesap": "Cuenta",
        "Gizlilik": "Privacidad",
        "Engellenenler": "Usuarios Bloqueados",
        "Destek": "Soporte",
        "Yardım Merkezi": "Centro de Ayuda",
        "Bize Ulaşın": "Contáctanos",
        "Sürüm": "Versión",
        "Hesabı Sil": "Eliminar Cuenta",

        "İsim": "Nombre",
        "Hakkımda": "Sobre mí",
        "Konum & Kariyer": "Ubicación y Carrera",

        "Ülke": "País",
        "Meslek": "Profesión",
        "Şirket": "Empresa",
        "Fiziksel Özellikler": "Atributos Físicos",
        "Boy (cm)": "Altura (cm)",
        "Burç": "Zodiaco",
        "Yaşam Tarzı": "Estilo de Vida",
        "Sigara": "Fumar",
        "Alkol": "Beber",
        "Egzersiz": "Ejercicio",
        "Evcil Hayvan": "Mascotas",
        "İlişki Tercihleri": "Objetivos de Relación",
        "Ne Arıyorum": "Buscando",
        "Çocuk İstiyor musun": "¿Quieres hijos?",
        "Hobiler & İlgi Alanları": "Aficiones e Intereses",
        "En fazla 8 hobi seç": "Selecciona hasta 8 aficiones",
        "Sosyal Medya Hesapları": "Cuentas de Redes Sociales",
        "Fotoğrafı Değiştir": "Cambiar Foto",
        "Seç": "Seleccionar",
        "Fotoğrafların": "Tus Fotos",
        "Sürükleyip bırakarak sıralamayı değiştir": "Arrastrar y soltar para reordenar",
        "Ana Fotoğraf": "Foto Principal",
        "Silmek istediğine emin misin?": "¿Estás seguro de que quieres eliminar?",

        "Sıralamak için basılı tut ve sürükle": "Mantén presionado para arrastrar y reordenar",
        "İlk fotoğraf profil fotoğrafın olacak": "La primera foto será tu foto de perfil",
        "Silinemez": "No se puede eliminar",
        "En az 1 fotoğrafın olmalı. Son fotoğrafı silemezsin.": "Debes tener al menos 1 foto. No puedes eliminar la última foto.",
        "fotoğraf kaydedildi.": "fotos guardadas.",
        "fotoğraf": "fotos",
        
        // Settings & Privacy
        "Profilimi Keşfetten Gizle": "Ocultar Perfil de Discovery",
        "Son Görülmeyi Gizle": "Ocultar Última Vez",
        "Okundu Bilgisini Gizle": "Ocultar Confirmación de Lectura",
        "Verilerimi İndir": "Descargar Mis Datos",
        "Keşif": "Descubrimiento",
        "Görünürlük": "Visibilidad",
        "Veri": "Datos",
        "Yaşımı Gizle": "Ocultar Mi Edad",
        "Mesafeyi Gizle": "Ocultar Distancia",
        "Çevrimiçi Durumu Gizle": "Ocultar Estado En Línea",
        "Kullanıcı Bildir": "Reportar Usuario",
        "Güvenlik İpuçları": "Consejos de Seguridad",
        "Bildirme sebebinizi seçin:": "Seleccione razón para reportar:",
        "Ek bilgi (opsiyonel):": "Info adicional (opcional):",
        "Uygunsuz fotoğraf": "Foto inapropiada",
        "Spam veya sahte profil": "Spam o perfil falso",
        "Taciz veya zorbalık": "Acoso o intimidación",
        "Uygunsuz mesajlar": "Mensajes inapropiados",
        "Yaşı tutmuyor": "Menor de edad",
        "Diğer": "Otro",
        "Bildir": "Reportar",
        
        // Safety Tips
        "Kişisel Bilgiler": "Información Personal",
        "Adres, telefon numarası gibi kişisel bilgilerinizin paylaşmayın.": "No compartas info personal como dirección o teléfono.",
        "Video Görüşme": "Videollamada",
        "Buluşmadan önce video görüşme yapın.": "Haz una videollamada antes de encontrarte.",
        "Halka Açık Yerler": "Lugares Públicos",
        "İlk buluşmalarınızı halka açık yerlerde yapın.": "Reúnete en lugares públicos la primera vez.",
        "Arkadaşlarınıza Söyleyin": "Dile a tus Amigos",
        "Nereye gittiğinizi birine söyleyin.": "Dile a alguien a dónde vas.",
        
        // Blocked Users
        "Engellenen kullanıcı yok": "No hay usuarios bloqueados",
        "Engellendi": "Bloqueado",
        "Engeli Kaldır": "Desbloquear",
        
        // Boost & Gems
        "Boost & Elmas": "Boost y Gemas",

        "Boost": "Boost",
        "Günlük 100 Elmas Al": "Reclamar 100 Gemas Diarias",
        "Bugünkü ödülünüzü aldınız!": "¡Ya reclamaste tu recompensa hoy!",
        "Elmas Kullanımı": "Uso de Gemas",
        "Eşleşme isteği: 10 elmas": "Solicitud de match: 10 gemas",
        "30 dakika boyunca profilini öne çıkar!": "¡Destaca tu perfil por 30 minutos!",

        
        // Edit Views Extra
        "İlgi Alanlarını Seç": "Seleccionar Intereses",
        "En fazla 10 tane seçebilirsin": "Puedes seleccionar hasta 10",
        "ilgi alanı kaydedildi.": "intereses guardados.",
        "Hesaplarını ekle, profilinde görünsün": "Añade tus cuentas para mostrar en perfil",
        "Hesapların profilinde görünecek": "Las cuentas serán visibles en tu perfil",
        "Sosyal medya hesapların güncellendi.": "Cuentas de redes sociales actualizadas.",
        "kullanici_adi": "usuario",
        "Profil linki": "Enlace de perfil",
        
        // Language & Country
        "Dil Seçin": "Seleccionar Idioma",
        "Uygulama dilini değiştirin": "Cambiar idioma de la app",
        "Dil değiştirildi": "Idioma cambiado",
        "Ülke Seç": "Seleccionar País",
        "Ülke Ara": "Buscar País",
        
        // QR Extra

        
        // Sheet Views
        "no_favorites": "Sin Favoritos",
        "no_favorites_message": "Aún no has marcado a nadie como favorito.",
        "favorites": "Favoritos",
        "done": "Listo",
        "no_requests": "Sin Solicitudes",
        "no_requests_message": "No has recibido solicitudes de amistad aún.",
        "requests": "Solicitudes",
        "boost_your_profile": "Mejora tu Perfil",
        "boost_description": "¡Destaca tu perfil por 30 minutos y consigue más matches!",
        "boost_benefit": "30 minutos destacado",
        "see_who_liked_you": "Mira Quién te Dio Like",
        "premium_required_likes": "Mejora a Premium para ver quién te dio like.",
        "upgrade_to_premium": "Mejorar a Premium",
        "no_likes_yet": "Sin Likes Aún",
        "no_likes_message": "Tu perfil aún no ha recibido likes. ¡Edita tu perfil y sé más activo!",
        "liked_you": "Te Dieron Like",
        "search_users": "Buscar Usuarios",
        "search_hint": "Escribe para buscar usuario...",
        "search": "Buscar",
        "cancel": "Cancelar",



        "Bugünkü ödülünü aldın!": "¡Ya reclamaste tu recompensa hoy!",

        "Elmas Satın Al": "Comprar Gemas",
        "En İyi Değer": "Mejor Valor",
        "Elmas Nasıl Kullanılır?": "Cómo usar Gemas?",
        "Eşleşme isteği göndermek: 10 elmas": "Enviar solicitud de match: 10 gemas",
        "Her gün ücretsiz 100 elmas al": "Obtén 100 gemas gratis diariamente",
        
        // Social & Notifications
        "Çevrimiçi": "En línea",
        "Son Eklenen": "Recientes",
        "İsme Göre": "Por Nombre",
        "Çevrimiçi Önce": "En línea Primero",
        "Arkadaş": "Amigo",
        "Arkadaş ara...": "Buscar amigos...",
        "Yükleniyor...": "Cargando...",
        "Henüz arkadaşın yok": "Aún no tienes amigos",
        "Sonuç bulunamadı": "No se encontraron resultados",
        "Keşfet'ten yeni insanlarla tanış": "Conoce gente nueva en Explorar",
        "Farklı bir arama dene": "Prueba una búsqueda diferente",
        "Arkadaşlıktan Çıkar": "Eliminar amigo",
        "arkadaş listenizden çıkarılacak.": "será eliminado de tu lista de amigos.",
        "Çıkar": "Eliminar",
        "Bugün": "Hoy",
        "Bu Hafta": "Esta Semana",
        "Daha Önce": "Anteriormente",
        "Tümünü Oku": "Leer Todo",
        "Okunmamış": "No Leído",
        "İstekler": "Solicitudes",
        "Bildirim Yok": "Sin Notificaciones",
        "Yeni bildirimler geldiğinde burada görünecek": "Las nuevas notificaciones aparecerán aquí",
        "Seyahat": "Viajes",

        "Yüzme": "Natación",
        "Yoga": "Yoga",
        "Kitap": "Libros"
    ]
    
    static let fr: [String: String] = [
        "Hızlı Tanış": "Speed Dating",
        "Ses Tanış": "Rencontre Vocale",
        "Burç Eşleş": "Astro Match",
        "Premium'a Geç": "Passer Premium",
        "Sınırsız beğeni, reklamsız kullanım, özel özellikler": "Likes illimités, sans pub, fonctions spéciales",
        "Premium'u Keşfet": "Découvrir Premium",
        "Daha sonra": "Plus tard",
        "Yaklaşan Etkinlikler": "Événements à venir",
        "Macera": "Aventure",
        "Romantik": "Romantique",
        "Sakin": "Calme",
        "Bugün Nasıl Hissediyorsun?": "Comment te sens-tu ?",
        "Ruh Eşini Bul": "Trouve ton Âme Sœur",
        "Başla": "Commencer",
        // Favorites/Likes View
        "Beğeniler": "J'aime",
        "Seçkinler": "Top Picks",
        "Henüz Superlike Yok": "Pas encore de Superlikes",
        "Seni çok beğenen özel biri olduğunda burada görünecek.": "Quand quelqu'un de spécial vous aimera, il apparaîtra ici.",
        "Seni Beğenenleri Gör": "Voir Qui Vous Aime",
        "Gold üyeler seni beğenen herkesi anında görür ve eşleşir.": "Les membres Gold voient instantanément qui les aime.",

        "En Seçkin Profiller": "Profils En Vedette",
        "Sana özel seçilmiş en popüler kullanıcılarla tanış.": "Rencontrez les utilisateurs les plus populaires sélectionnés pour vous.",
        "EN SEÇKİN PROFİLLERİ AÇ": "DÉBLOQUER TOP PICKS",
        "Seni Superlike'ladı! ⭐": "Vous a Superliké ! ⭐",
        "Popüler": "Populaire",
        "Gizli": "Caché",

        // Live Events (Mock)
        "Canlı Müzik - Indie Rock": "Musique Live - Indie Rock",
        "Yerel indie rock gruplarının performansı": "Performance de groupes indie rock locaux",
        "Jazz Night": "Soirée Jazz",
        "Caz müzik severler için özel gece": "Soirée spéciale pour les amateurs de jazz",
        "Kahve & Sohbet": "Café & Discussion",
        "Yeni insanlarla tanış, kahve iç": "Rencontrez de nouvelles personnes, buvez du café",
        "Kitap Okuma Kulübü": "Club de Lecture",
        "Bu ay: Sabahattin Ali - Kürk Mantolu Madonna": "Ce mois-ci : Sabahattin Ali - La Madone au manteau de fourrure",
        "Yoga & Tanışma": "Yoga & Rencontre",
        "Sabah yogası ve kahvaltı": "Yoga matinal et petit-déjeuner",
        "Gurme Akşam Yemeği": "Dîner Gourmet",
        "Şef menüsü ve yeni tanışmalar": "Menu du chef et nouvelles rencontres",
        "Sanat Galerisi Turu": "Visite de Galerie d'Art",
        "Çağdaş sanat sergisi gezisi": "Visite d'exposition d'art contemporain",
        "Plaj Voleybolu": "Volleyball de Plage",
        "Dostluk maçı ve eğlence": "Match amical et amusement",
        "Müzik": "Musique",
        "Kahve": "Café",
        "Wellness": "Bien-être",
        "Yemek": "Nourriture",
        "Sanat": "Art",
        "Spor": "Sport",

        // Time Units
        "1 Hafta": "1 Semaine",
        "1 Ay": "1 Mois",
        "6 Ay": "6 Mois",
        "Hafta": "Semaine",
        "Ay": "Mois",
        "Yıl": "An",

        // Profile & Premium
        "Mevcut:": "Actuel :",
        "30 dakika boyunca profilini öne çıkar ve 10 kat daha fazla görüntülenme al!": "Mettez votre profil en avant pendant 30 min et obtenez 10x plus de vues !",
        "adet": "pcs",
        "EN İYİ FİYAT": "MEILLEUR PRIX",
        "Tüm premium özelliklere eriş!": "Accédez à toutes les fonctionnalités premium !",
        "Sınırsız Beğeni": "Likes Ilimités",
        "5 Super Like / Gün": "5 Super Likes / Jour",
        "1 Boost / Ay": "1 Boost / Mois",
        "Seni Kimlerin Beğendiğini Gör": "Voir Qui Vous A Liké",
        "Geri Alma": "Rembobiner",
        "Konum Değiştir": "Changer de Lieu",
        "Gizli Mod": "Mode Incognito",
        "EN POPÜLER": "PLUS POPULAIRE",
        "Satın Al -": "Acheter -",
        "Abonelik otomatik olarak yenilenir. İstediğin zaman iptal edebilirsin.": "L'abonnement se renouvelle automatiquement. Annulez à tout moment.",
        "Premium Aktif! 🎉": "Premium Activé ! 🎉",
        "Harika!": "Super !",
        "VibeU Gold aboneliğin aktif edildi!": "Votre abonnement VibeU Gold est actif !",
        "Premium üyeliğiniz aktif edildi!": "Votre abonnement premium est actif !",
        "Sınırsız eşleşme, sınırsız bağlantı": "Matchs illimités, connexions illimitées",
        "Günlük limit olmadan beğen": "Likez sans limite quotidienne",
        "Kimin beğendiğini anında öğren": "Voyez instantanément qui vous a liké",
        "Global Keşif": "Découverte Mondiale",
        "Dünyanın her yerinden bağlan": "Connectez-vous de n'importe où",
        "Özel Profil Çerçevesi": "Cadre de Profil Spécial",
        "Premium rozeti ile öne çık": "Démarquez-vous avec le badge Premium",
        "Öncelikli Görünürlük": "Visibilité Prioritaire",
        "Profilin daha çok gösterilsin": "Faites voir votre profil plus souvent",
        "Sınırsız Geri Alma": "Rembobinage Illimité",
        "Yanlışlıkla geçtiklerini geri al": "Annulez les swipes accidentels",
        "Planını Seç": "Choisissez Votre Plan",
        "EN İYİ": "MEILLEUR",
        "POPÜLER": "POPULAIRE",
        "Haftalık": "Hebdomadaire",
        "Aylık": "Mensuel",
        "Yıllık": "Annuel",
        "/hafta": "/semaine",
        "Tasarruf": "Économie",
        "Şimdilik Geç": "Passer pour l'instant",
        "Kullanım Şartları": "Conditions d'Utilisation",
        "Gizlilik Politikası": "Politique de Confidentialité",
        "Satın Alımları Geri Yükle": "Restaurer les Achats",
        "Tebrikler! 🎉": "Félicitations ! 🎉",
        
        // Diamond / Gems
        "Elmaslarım": "Mes Gemmes",
        "Elmas": "Gemmes",
        "Günlük Ödül": "Récompense Quotidienne",

        "Bugünkü ödülünü aldın!": "Vous avez réclamé votre récompense !",
        "Yeni ödül:": "Prochaine récompense :",
        "saat": "heures",
        "dakika": "minutes",
        "Reklam İzle": "Regarder Pub",
        "Reklam İzle & 25 Elmas Kazan": "Regarder Pub & Gagner 25 Gemmes",
        "Günde 1 kez kullanılabilir": "Disponible une fois par jour",
        "Bugün reklamı izledin!": "Vous avez regardé la pub aujourd'hui !",
        "Yarın tekrar izleyebilirsin": "Vous pourrez revoir demain",
        "Reklam izle, 25 elmas kazan": "Regardez une pub, gagnez 25 gemmes",


        "🌍 Global (Dünya Geneli)": "🌍 Mondial (Global)",
        "🇹🇷 Türkiye (Yerel)": "🇹🇷 Turquie (Local)",
        "Yaş Aralığı": "Tranche d'Âge",
        "Hızlı Filtreler": "Filtres Rapides",
        "Sadece Doğrulanmış": "Vérifié Uniquement",
        "Fotoğraflı Profiller": "Profils avec Photos",
        "İlişki Amacı": "Objectif de Relation",
        "Hepsi": "Tous",
        "Ciddi İlişki": "Relation Sérieuse",
        "Arkadaşlık": "Amitié",
        "Belirsiz": "Pas Sûr",
        "Evlilik": "Mariage",
        "Filtreleri Sıfırla": "Réinitialiser",
        "Sıfırla": "Réinitialiser",
        "Uygula": "Appliquer",
        "Filtreler sıfırlandı": "Filtres réinitialisés",

        // Moods Detail
        "Ne yapmak istersin?": "Que veux-tu faire ?",
        "Kişi Bul": "Trouver des Gens",
        "Aynı ruh halindeki insanlarla tanış": "Rencontrez des gens avec la même humeur",
        "Tavsiye Al": "Obtenir des Conseils",
        "Ruh haline göre öneriler al": "Obtenez des recommandations selon l'humeur",
        "Kişi Bul'a Geç": "Passer à Trouver des Gens",
        "İçin Öneriler": "Recommandations pour",
        "Ruh Hali": "Humeur",

        // Mood Tips - Adventure
        "Doğa Yürüyüşü": "Randonnée",
        "Şehirden kaç, ormanda kaybol!": "Échappez à la ville, perdez-vous dans les bois !",
        
        // Game Match
        "Oyun Arkadaşı": "Partenaire de Jeu",
        "Birlikte oynayacak arkadaş bul": "Trouvez un ami pour jouer",
        "Oyuncu ara...": "Rechercher des joueurs...",
        "Oyun": "Jeu",
        "Rank": "Rang",
        "Oyuncu bulunamadı": "Aucun joueur trouvé",
        "Filtreleri değiştirmeyi dene": "Essayez de changer les filtres",
        "Oyun İsteği Gönder": "Envoyer Demande de Jeu",
        "Gönder": "Envoyer",
        "ile oynamak için istek gönderilsin mi? (10 Elmas)": "Envoyer une demande pour jouer avec ? (10 Gemmes)",
        
        // Music Match
        "Müzik Eşleş": "Match Musical",
        "Aynı müzik zevkine sahip insanlarla tanış": "Rencontrez des gens aux mêmes goûts musicaux",
        "Müzik severleri ara...": "Rechercher des mélomanes...",
        "Müzik sevgili bulunamadı": "Aucun mélomane trouvé",
        "Müzik İsteği Gönder": "Envoyer Demande Musicale",
        "şarkısını dinlemek için istek gönderilsin mi? (10 Elmas)": "Envoyer une demande pour écouter avec ? (10 Gemmes)",

        // Gourmet
        "Gurme Deneyimi": "Expérience Gastronomique",
        "100+ restoran, rezervasyon yap, eşleş": "100+ restaurants, réservez, matchez",
        "Restoran ara...": "Rechercher des restaurants...",
        "Mutfak": "Cuisine",
        "Şehir": "Ville",
        "Fiyat": "Prix",
        "Özel Lezzetler": "Saveurs Spéciales",
        
        // Book Club
        "Kitap Kulübü": "Club de Lecture",
        "Aynı kitabı okuyan insanlarla tanış": "Rencontrez des gens lisant le même livre",
        "Kitap veya yazar ara...": "Rechercher livre ou auteur...",
        "Roman": "Roman",
        "Klasik": "Classique",
        "Bilim Kurgu": "Science-Fiction",
        "Fantastik": "Fantastique",
        "Polisiye": "Policier",
        "Tarih": "Histoire",
        "Biyografi": "Biographie",
        "Felsefe": "Philosophie",
        "Psikoloji": "Psychologie",
        "Şiir": "Poésie",
        "okuyucu": "lecteurs",
        "sayfa": "pages",
        "Okuma Grubuna Katıl": "Rejoindre le Groupe de Lecture",
        
        // Travel Buddy
        "Seyahat Arkadaşı": "Compagnon de Voyage",
        "Dünyayı birlikte keşfet": "Explorez le monde ensemble",
        "Destinasyon ara...": "Rechercher une destination...",
        "Stil": "Style",
        "Bütçe": "Budget",
        "Süre": "Durée",

        "Kültür": "Culture",
        "Plaj": "Plage",
        "Doğa": "Nature",
        "Lüks": "Luxe",
        "Backpacking": "Excursion",
        "Uçak Bileti Al": "Acheter Billet d'Avion",
        "Seyahat Arkadaşı Bul": "Trouver Compagnon de Voyage",
        
        // Daily Streak & Ads
        "Günlük Seri": "Série Quotidienne",
        "Bugün giriş yap!": "Connectez-vous aujourd'hui !",
        "gün süren var": "série de jours",
        "Günlük Seri!": "Série Quotidienne !",
        "Serin devam ediyor🔥": "La série continue🔥",
        "Seriyi tamamla, elmas kazan!": "Complétez la série, gagnez des gemmes !",
        "Reklam İzle & Kazan": "Regarder Pub & Gagner",
        "+10 Elmas": "+10 Gemmes",
        "Kısa bir reklam izle, anında elmas kazan!": "Regardez une courte pub, gagnez des gemmes !",
        "İzle": "Regarder",
        
        // Likes View
        "Beğenenler": "J'aime",




        // Mood Tips - Romantic
        "Romantik Akşam": "Soirée Romantique",
        "Mum ışığında yemek, şarap": "Dîner aux chandelles, vin",
        "Gece Yürüyüşü": "Marche Nocturne",
        "Sahilde el ele yürü": "Marchez main dans la main sur la plage",
        "Sürpriz Hediye": "Cadeau Surprise",
        "Küçük ama anlamlı bir şey al": "Achetez quelque chose de petit mais significatif",
        
        // Mood Tips - Chill
        "Kahve Molası": "Pause Café",
        "Favori kahve dükkanında dinlen": "Détendez-vous dans votre café préféré",
        "Kitap Keyfi": "Plaisir de Lire",
        "Rahat bir köşede kitabına dal": "Plongez dans votre livre dans un coin confortable",
        "Yoga Seansı": "Séance de Yoga",
        "Bedenini ve zihnini dinlendir": "Reposez votre corps et votre esprit",

        // Mood Tips - Party
        "Konser": "Concert",
        "Canlı müzik enerjisi yakala": "Attrapez l'énergie de la musique live",
        "Dans Gecesi": "Soirée Dansante",
        "Kulüpte sabaha kadar eğlen": "Amusez-vous au club jusqu'au matin",
        "Ev Partisi": "Fête à la Maison",
        "Arkadaşlarını topla, parti kur": "Rassemblez des amis, organisez une fête",

        // Mood Tips - Deep
        "Derin Sohbet": "Conversation Profonde",
        "Hayatın anlamını tartış": "Discutez du sens de la vie",
        "Sanat Galerisi": "Galerie d'Art",
        "Eserleri yorumla, düşün": "Interprétez les œuvres, réfléchissez",
        "Günlük Tut": "Tenir un Journal",
        "Düşüncelerini yazıya dök": "Écrivez vos pensées",
        
        // Mood Tips - Creative
        "Resim Yap": "Peindre",
        "Tuval al, hayal gücünü çalıştır": "Prenez une toile, activez votre imagination",
        "Müzik Yap": "Faire de la Musique",
        "Enstrüman çal veya beat yap": "Jouez d'un instrument ou faites un beat",
        "Fotoğrafçılık": "Photographie",
        "Farklı açılardan dünyayı yakala": "Capturez le monde sous différents angles",

        // Mood Tips - Default
        "Yeni Bir Şey Dene": "Essayez Quelque Chose de Nouveau",
        "Konfor alanından çık": "Sortez de votre zone de confort",
        "Arkadaşlarla Buluş": "Rencontrer des Amis",
        "Sosyalleş, eğlen": "Socialisez, amusez-vous",
        "Kendine Zaman Ayır": "Prenez du Temps pour Vous",
        "Sevdiğin bir aktivite yap": "Faites une activité que vous aimez",

        // Profile Overlay
        "İlk İzlenim ile öne çık": "Démarquez-vous par une Première Impression",
        "Eşleşmeden önce ona mesaj göndererek dikkatini çek. Ona profilinde hoşuna giden şeyin ne olduğunu söyleyebilir, iltifat edebilir veya onu güldürebilirsin.": "Attirez son attention en envoyant un message avant de matcher. Dites-lui ce que vous aimez dans son profil, faites-lui un compliment ou faites-la rire.",
        "Mesajın...": "Votre message...",
        "Mesajın gönderildi!": "Message envoyé !",

        // Moods & Subtitles
        "Heyecan": "Excitation",
        "Aşk": "Amour",
        "Dinlenme": "Détente",
        "Eğlence": "Amusement",
        "Sohbet": "Discussion",
        "Parti": "Fête",
        "Derin": "Profond",
        "Yaratıcı": "Créatif",

        "Sana Özel": "Pour Vous",
        "Paylaş": "Partager",
        "Çift Randevu": "Double Rendez-vous",
        "Reklam izleniyor...": "Publicité en cours...",
        "Reklam Süresi": "Pause Pub",
        "İzle ve Devam Et": "Regarder et Continuer",
        "Sınırsız beğeni gönder": "Envoyer des likes illimités",
        "Gizli profil görüntüleme": "Affichage de profil privé",
        "Öncelikli eşleşme": "Matching prioritaire",
        "Reklamsız deneyim": "Expérience sans publicité",









        "Gelen Arkadaşlık İstekleri": "Demandes d'amis reçues",
        "istek daha": "demandes de plus",
        "kişi seni beğendi!": "personnes vous ont aimé!",
        "Premium ile kimlerin beğendiğini gör": "Voir qui vous a aimé avec Premium",

        // Discover

        "Premium ile reklamsız kullan": "Sans pub avec Premium",
        "Son Zamanlarda Aktif": "Récemment Actif",

        "Yetersiz elmas (100 gerekli)": "Diamants insuffisants (100 requis)",
        "Yetersiz elmas! Arkadaşlık isteği göndermek için 10 elmas gerekli.": "Diamants insuffisants ! 10 diamants requis.",
        "Super Like + Arkadaşlık isteği gönderildi!": "Super Like + Demande envoyée !",
        



        // QR Profile
        "Hikayende Paylaş": "Partager dans l'histoire",
        "QR Profilim": "Mon Profil QR",
        "Kaydedildi ✓": "Enregistré ✓",
        "QR kod fotoğraflarına kaydedildi.": "Code QR enregistré dans les photos.",
        "Arkadaş Ekle": "Ajouter un Ami",
        "QR kod veya AirDrop ile arkadaşlarını ekle": "Ajouter des amis via QR ou AirDrop",
        "QR Kodunu Göster": "Afficher le Code QR",
        "Arkadaşların seni tarayarak ekleyebilir": "Vos amis peuvent scanner pour vous ajouter",
        "QR Kod Tara": "Scanner le Code QR",
        "Arkadaşının QR kodunu tara ve ekle": "Scanner le QR d'un ami pour l'ajouter",
        "Yakındakileri Bul": "Trouver à Proximité",
        "AirDrop ile yakındaki VibeU kullanıcılarını bul": "Trouver des utilisateurs proches avec AirDrop",
        "Yakındaki Kullanıcılar": "Utilisateurs à Proximité",
        "Bu QR kodu arkadaşlarına göster": "Montrez ce code QR à vos amis",
        "QR Kodum": "Mon Code QR",
        "QR Kodu çerçevenin içine hizalayın": "Alignez le code QR dans le cadre",
        
        // Explore
        "Keşfet": "Explorer",



        // Vibe Quiz
        "Vibe Quiz": "Quiz Vibe",
        "8 soruluk kişilik testini tamamla ve ruh eşini bul!": "Complétez le quiz de 8 questions pour trouver votre âme sœur !",
        "Teste Başla": "Lancer le Quiz",
        "Soru": "Question",
        "Kişilik Tipin": "Votre Type de Personnalité",
        "Eşleşmeye Başla": "Commencer le Match",
        "Maceracı": "Aventurier",
        "Düşünür": "Penseur",
        "Sosyal": "Social",
        "Yeni deneyimlere açık, enerjik ve sosyal birisin!": "Vous êtes ouvert aux nouvelles expériences, énergique et social !",
        "Derin, sakin ve analitik bir kişiliğe sahipsin!": "Vous avez une personnalité profonde, calme et analytique !",
        "Hayal gücü kuvvetli, özgün ve ilham vericisin!": "Vous avez une forte imagination, unique et inspirant !",
        "İnsanlarla olmayı seven, enerjik ve eğlencelisin!": "Vous aimez être avec les gens, énergique et amusant !",
        "Benzersiz bir kişiliğe sahipsin!": "Vous avez une personnalité unique !",

        "Kişilik testine göre eşleş": "Matcher selon personnalité",
        "Birlikte oyna": "Jouer ensemble",
        "Aynı zevk": "Même goût",
        "Yemek keşfi": "Découverte culinaire",
        "Aynı kitap": "Même livre",

        "Yakında yeni etkinlikler...": "Nouveaux événements bientôt...",
        "CANLI": "EN DIRECT",

        "Özel Deneyimler": "Expériences Exclusives",

        "Profili Düzenle": "Modifier le Profil",
        "Fotoğraflar": "Photos",
        "İlgi Alanları": "Intérêts",
        "Sosyal Medya": "Réseaux Sociaux",
        "Çıkış Yap": "Déconnexion",
        "Boostlarım": "Mes Boosts",
        "Abonelikler": "Abonnements",
        "Güvenlik": "Sécurité",
        "Ayarlar": "Paramètres",
        "Giriş Yap": "Connexion",
        "Kayıt Ol": "Inscription",
        "Arkadaşlar": "Amis",
        "Profil": "Profil",
        "Mesajlar": "Messages",
        "Bildirimler": "Notifications",
        "Hesabım": "Mon Compte",
        "Konum": "Localisation",
        "Uzaklık": "Distance",

        "Cinsiyet": "Genre",
        "Erkek": "Homme",
        "Kadın": "Femme",
        "Tümü": "Tous",
        "Kaydet": "Enregistrer",
        "İptal": "Annuler",
        "E-posta": "E-mail",
        "Şifre": "Mot de passe",
        "Şifremi Unuttum": "Mot de passe oublié",
        "Geri": "Retour",
        "İleri": "Suivant",
        "Tamam": "OK",
        "Hata": "Erreur",
        "Başarılı": "Succès",
        "Kullanıcı Adı": "Nom d'utilisateur",
        "Doğum Tarihi": "Date de naissance",

        "Düzenle": "Modifier",
        "Sil": "Supprimer",
        "Kapat": "Fermer",
        "Ara": "Rechercher",
        "Engelle": "Bloquer",
        "Şikayet Et": "Signaler",
        "Eşleşmeyi Kaldır": "Dissocier",
        "Galeriden Seç": "Choisir dans la galerie",
        "Kamera": "Caméra",
        "İzin Ver": "Autoriser",
        "Reddet": "Refuser",
        "Tekrar Dene": "Réessayer",
        "Astroloji": "Astrologie",
        "Ruh haline göre eşleş": "Matcher selon l'humeur",
        "Bugün zaten giriş yaptın!": "Déjà enregistré aujourd'hui !",
        "Tebrikler! Reklam izleyerek 50 Elmas kazandın! 💎": "Félicitations ! 50 Diamants gagnés ! 💎",
        "Harika! 🎉": "Super ! 🎉",
        "Filtrelerinize uygun kullanıcı bulunamadı": "Aucun utilisateur trouvé avec vos filtres",
        "Kullanıcılar yüklenirken hata oluştu": "Erreur lors du chargement des utilisateurs",
        "Sosyal Hesaplar": "Comptes Sociaux",
        "Kilitli": "Verrouillé",
        "Hesaplar Gizli": "Comptes Privés",
        "Sosyal medya hesaplarını görmek için arkadaş olmalısın.": "Vous devez être amis pour voir les réseaux sociaux.",
        "İstek Gönderildi": "Demande Envoyée",
        "kişisine arkadaşlık isteği gönderildi": "demande d'ami envoyée à",
        "Yetersiz Elmas 💎": "Diamants Insuffisants 💎",
        "Elmas Al": "Obtenir des Diamants",
        "Arkadaşlık isteği göndermek için 10 elmas gerekiyor. Günlük ücretsiz elmasını alabilirsin!": "La demande coûte 10 diamants. Réclamez vos diamants gratuits !",
        "km uzakta": "km de distance",
        "common_interests": "Intérêts Communs",


        "Katılımcılar": "Participants",
        "kişi": "personnes",
        "Açıklama": "Description",
        "Bilet Al": "Acheter Billet",
        "Etkinliğe Katıl": "Rejoindre",
        "Çifte Randevu arkadaşları": "Amis Double Date",
        "Çifte Randevu'da en fazla 3 arkadaşınla çift olabilirsin.": "Vous pouvez vous associer avec jusqu'à 3 amis.",
        "Daha fazla bilgi edin": "En savoir plus",
        "Arkadaşlardan gelen davetler": "Invitations d'amis",
        "Çifte Randevu davetlerini burada göreceksin.": "Vous verrez les invitations ici.",
        "Arkadaşlarını Davet Et": "Inviter des Amis",
        "Seni Çifte Randevu'ya davet etti": "Vous a invité à un Double Date",
        "Kullanıcı": "Utilisateur",
        "Profili Tamamla": "Compléter Profil",
        "Profilini öne çıkar": "Mettez votre profil en avant",
        "Ortak noktalarını bul": "Trouvez des points communs",
        "Hesaplarını bağla": "Connecter les comptes",
        "Hızlıca paylaş": "Partager rapidement",
        "Görünüm": "Apparence",
        "Tema": "Thème",
        "Dil": "Langue",

        "Hesap": "Compte",
        "Gizlilik": "Confidentialité",
        "Engellenenler": "Utilisateurs Bloqués",
        "Destek": "Support",
        "Yardım Merkezi": "Centre d'Aide",
        "Bize Ulaşın": "Nous Contacter",
        "Sürüm": "Version",
        "Hesabı Sil": "Supprimer Compte",

        "Bu işlem geri alınamaz. Tüm verileriniz silinecektir.": "Cette action est irréversible. Toutes vos données seront supprimées.",

        "İsim": "Nom",
        "Hakkımda": "À propos de moi",
        "Konum & Kariyer": "Localisation & Carrière",

        "Ülke": "Pays",
        "Meslek": "Profession",
        "Şirket": "Entreprise",
        "Fiziksel Özellikler": "Attributs Physiques",
        "Boy (cm)": "Taille (cm)",
        "Burç": "Zodiaque",
        "Yaşam Tarzı": "Style de Vie",
        "Sigara": "Fumer",
        "Alkol": "Boire",
        "Egzersiz": "Exercice",
        "Evcil Hayvan": "Animaux",
        "İlişki Tercihleri": "Objectifs Relationnels",
        "Ne Arıyorum": "Je cherche",
        "Çocuk İstiyor musun": "Voulez-vous des enfants",
        "Hobiler & İlgi Alanları": "Loisirs & Intérêts",
        "En fazla 8 hobi seç": "Sélectionnez jusqu'à 8 loisirs",
        "Sosyal Medya Hesapları": "Comptes Réseaux Sociaux",
        "Fotoğrafı Değiştir": "Changer Photo",
        "Seç": "Sélectionner",
        "Fotoğrafların": "Vos Photos",
        "Sürükleyip bırakarak sıralamayı değiştir": "Glisser-déposer pour réorganiser",
        "Ana Fotoğraf": "Photo Principale",
        "Silmek istediğine emin misin?": "Êtes-vous sûr de vouloir supprimer ?",

        "Sıralamak için basılı tut ve sürükle": "Appuyez et maintenez pour faire glisser et réorganiser",
        "İlk fotoğraf profil fotoğrafın olacak": "La première photo sera votre photo de profil",
        "Silinemez": "Impossible de supprimer",
        "En az 1 fotoğrafın olmalı. Son fotoğrafı silemezsin.": "Vous devez avoir au moins 1 photo. Vous ne pouvez pas supprimer la dernière photo.",
        "fotoğraf kaydedildi.": "photos enregistrées.",
        "fotoğraf": "photos",
        
        // Settings & Privacy
        "Profilimi Keşfetten Gizle": "Masquer le profil de la découverte",
        "Son Görülmeyi Gizle": "Masquer la dernière vue",
        "Okundu Bilgisini Gizle": "Masquer les confirmations de lecture",
        "Verilerimi İndir": "Télécharger mes données",
        "Keşif": "Découverte",
        "Görünürlük": "Visibilité",
        "Veri": "Données",
        "Yaşımı Gizle": "Masquer mon âge",
        "Mesafeyi Gizle": "Masquer la distance",
        "Çevrimiçi Durumu Gizle": "Masquer le statut en ligne",
        "Kullanıcı Bildir": "Signaler un utilisateur",
        "Güvenlik İpuçları": "Conseils de sécurité",
        "Bildirme sebebinizi seçin:": "Sélectionnez la raison du signalement :",
        "Ek bilgi (opsiyonel):": "Infos supplémentaires (facultatif) :",
        "Uygunsuz fotoğraf": "Photo inappropriée",
        "Spam veya sahte profil": "Spam ou faux profil",
        "Taciz veya zorbalık": "Harcèlement ou intimidation",
        "Uygunsuz mesajlar": "Messages inappropriés",
        "Yaşı tutmuyor": "Mineur",
        "Diğer": "Autre",
        "Bildir": "Signaler",
        
        // Safety Tips
        "Kişisel Bilgiler": "Informations Personnelles",
        "Adres, telefon numarası gibi kişisel bilgilerinizin paylaşmayın.": "Ne partagez pas d'infos personnelles comme l'adresse ou le téléphone.",
        "Video Görüşme": "Appel Vidéo",
        "Buluşmadan önce video görüşme yapın.": "Faites un appel vidéo avant de vous rencontrer.",
        "Halka Açık Yerler": "Lieux Publics",
        "İlk buluşmalarınızı halka açık yerlerde yapın.": "Rencontrez-vous dans des lieux publics la première fois.",
        "Arkadaşlarınıza Söyleyin": "Dites-le à vos amis",
        "Nereye gittiğinizi birine söyleyin.": "Dites à quelqu'un où vous allez.",
        
        // Blocked Users
        "Engellenen kullanıcı yok": "Aucun utilisateur bloqué",
        "Engellendi": "Bloqué",
        "Engeli Kaldır": "Débloquer",
        
        // Boost & Gems
        "Boost & Elmas": "Boost & Gemmes",

        "Boost": "Boost",
        "Günlük 100 Elmas Al": "Réclamer 100 Gemmes/jour",
        "Bugünkü ödülünüzü aldınız!": "Vous avez réclamé votre récompense !",
        "Elmas Kullanımı": "Utilisation des Gemmes",
        "Eşleşme isteği: 10 elmas": "Demande de match : 10 gemmes",
        "30 dakika boyunca profilini öne çıkar!": "Boostez votre profil pendant 30 minutes !",

        
        // Edit Views Extra
        "İlgi Alanlarını Seç": "Sélectionner Intérêts",
        "En fazla 10 tane seçebilirsin": "Vous pouvez en sélectionner jusqu'à 10",
        "ilgi alanı kaydedildi.": "intérêts enregistrés.",
        "Hesaplarını ekle, profilinde görünsün": "Ajoutez vos comptes pour les afficher",
        "Hesapların profilinde görünecek": "Les comptes seront visibles sur votre profil",
        "Sosyal medya hesapların güncellendi.": "Comptes réseaux sociaux mis à jour.",
        "kullanici_adi": "nom_d_utilisateur",
        "Profil linki": "Lien du profil",
        
        // Language & Country
        "Dil Seçin": "Choisir la Langue",
        "Uygulama dilini değiştirin": "Changer la langue de l'app",
        "Dil değiştirildi": "Langue changée",
        "Ülke Seç": "Choisir le Pays",
        "Ülke Ara": "Rechercher un Pays",
        
        // QR Extra

        
        // Sheet Views
        "no_favorites": "Pas de Favoris",
        "no_favorites_message": "Vous n'avez encore mis personne en favori.",
        "favorites": "Favoris",
        "done": "Fait",
        "no_requests": "Pas de Demandes",
        "no_requests_message": "Vous n'avez pas encore reçu de demandes d'amis.",
        "requests": "Demandes",
        "boost_your_profile": "Boostez Votre Profil",
        "boost_description": "Mettez votre profil en avant pendant 30 minutes et obtenez plus de matchs !",
        "boost_benefit": "30 minutes en avant",
        "see_who_liked_you": "Voir Qui Vous a Aimé",
        "premium_required_likes": "Passez Premium pour voir qui vous a aimé.",
        "upgrade_to_premium": "Passer Premium",
        "no_likes_yet": "Pas Encore de Likes",
        "no_likes_message": "Votre profil n'a pas encore reçu de likes. Modifiez votre profil et soyez plus actif !",
        "liked_you": "Vous a Aimé",
        "search_users": "Rechercher des Utilisateurs",
        "search_hint": "Commencez à taper pour chercher...",
        "search": "Rechercher",
        "cancel": "Annuler",


        "Ödülümü Al": "Réclamer Récompense",


        "Elmas Satın Al": "Acheter des Gemmes",
        "En İyi Değer": "Meilleure Valeur",
        "Elmas Nasıl Kullanılır?": "Comment utiliser les Gemmes ?",
        "Eşleşme isteği göndermek: 10 elmas": "Envoyer demande de match : 10 gemmes",
        "Her gün ücretsiz 100 elmas al": "Obtenez 100 gemmes gratuites chaque jour",
        
        // Social & Notifications
        "Çevrimiçi": "En ligne",
        "Son Eklenen": "Récents",
        "İsme Göre": "Par Nom",
        "Çevrimiçi Önce": "En ligne d'abord",
        "Arkadaş": "Ami",
        "Arkadaş ara...": "Rechercher des amis...",
        "Yükleniyor...": "Chargement...",
        "Henüz arkadaşın yok": "Pas encore d'amis",
        "Sonuç bulunamadı": "Aucun résultat trouvé",
        "Keşfet'ten yeni insanlarla tanış": "Rencontrez de nouvelles personnes dans Explorer",
        "Farklı bir arama dene": "Essayez une autre recherche",
        "Arkadaşlıktan Çıkar": "Retirer des amis",
        "arkadaş listenizden çıkarılacak.": "sera retiré de votre liste d'amis.",
        "Çıkar": "Retirer",
        "Bugün": "Aujourd'hui",
        "Bu Hafta": "Cette Semaine",
        "Daha Önce": "Plus Tôt",
        "Tümünü Oku": "Tout Lire",
        "Okunmamış": "Non Lu",
        "İstekler": "Demandes",
        "Bildirim Yok": "Pas de Notifications",
        "Yeni bildirimler geldiğinde burada görünecek": "Les nouvelles notifications apparaîtront ici",
        "Seyahat": "Voyage",

        "Yüzme": "Natation",
        "Yoga": "Yoga",
        "Kitap": "Livres"
    ]
    
    static let pt: [String: String] = [
        "Hızlı Tanış": "Encontro Rápido",
        "Ses Tanış": "Encontro de Voz",
        "Burç Eşleş": "Astro Match",
        "Premium'a Geç": "Seja Premium",
        "Sınırsız beğeni, reklamsız kullanım, özel özellikler": "Curtidas ilimitadas, sem anúncios, recursos especiais",
        "Premium'u Keşfet": "Descobrir Premium",
        "Daha sonra": "Mais tarde",
        "Yaklaşan Etkinlikler": "Próximos Eventos",
        "Macera": "Aventura",
        "Romantik": "Romântico",
        "Sakin": "Calmo",
        "Bugün Nasıl Hissediyorsun?": "Como se sente hoje?",
        "Ruh Eşini Bul": "Encontre sua Alma Gêmea",
        "Başla": "Começar",
        "Sana Özel": "Para Você",
        "Paylaş": "Compartilhar",
        "Çift Randevu": "Encontro Duplo",
        "Reklam izleniyor...": "Assistindo anúncio...",
        "Reklam Süresi": "Intervalo Comercial",
        "İzle ve Devam Et": "Assistir e Continuar",
        "Sınırsız beğeni gönder": "Enviar curtidas ilimitadas",
        "Gizli profil görüntüleme": "Visualização de perfil privada",
        "Öncelikli eşleşme": "Correspondência prioritária",
        "Reklamsız deneyim": "Experiência sem anúncios",
        "Arkadaşlık isteği gönderdi": "enviou um pedido de amizade",
        "Tüm İstekler": "Todos os Pedidos",
        "Beğenenler": "Curtidas",
        
        // Vibe Quiz (NEW)
        "Vibe Quiz": "Quiz Vibe",
        "8 soruluk kişilik testini tamamla ve ruh eşini bul!": "Complete o quiz de 8 perguntas e encontre sua alma gêmea!",
        "Teste Başla": "Iniciar Quiz",
        "Soru": "Pergunta",
        "Kişilik Tipin": "Seu Tipo de Personalidade",
        "Eşleşmeye Başla": "Começar a Combinar",
        "Maceracı": "Aventureiro",
        "Düşünür": "Pensador",
        "Yaratıcı": "Criativo",
        "Sosyal": "Social",
        "Yeni deneyimlere açık, enerjik ve sosyal birisin!": "Você é aberto a novas experiências, enérgico e social!",
        "Derin, sakin ve analitik bir kişiliğe sahipsin!": "Você tem uma personalidade profunda, calma e analítica!",
        "Hayal gücü kuvvetli, özgün ve ilham vericisin!": "Você tem uma imaginação forte, único e inspirador!",
        "İnsanlarla olmayı seven, enerjik ve eğlencelisin!": "Você adora estar com pessoas, enérgico e divertido!",
        "Benzersiz bir kişiliğe sahipsin!": "Você tem uma personalidade única!",

        // Explore (Updated)
        "Keşfet": "Explorar",
        
        // Game Match
        "Oyun Arkadaşı": "Companheiro de Jogo",
        "Birlikte oynayacak arkadaş bul": "Encontre um amigo para jogar",
        "Oyuncu ara...": "Perquisar jogadores...",
        "Oyun": "Jogo",
        "Rank": "Ranking",
        "Oyuncu bulunamadı": "Nenhum jogador encontrado",
        "Filtreleri değiştirmeyi dene": "Tente mudar os filtros",
        "Oyun İsteği Gönder": "Enviar Pedido de Jogo",
        "Gönder": "Enviar",
        "ile oynamak için istek gönderilsin mi? (10 Elmas)": "Enviar pedido para jogar com? (10 Gemas)",

        // Music Match
        "Müzik Eşleş": "Match Musical",
        "Aynı müzik zevkine sahip insanlarla tanış": "Conheça pessoas com o mesmo gosto musical",
        "Müzik severleri ara...": "Pesquisar amantes da música...",
        "Müzik sevgili bulunamadı": "Nenhum amante da música encontrado",
        "Müzik İsteği Gönder": "Enviar Pedido Musical",
        "şarkısını dinlemek için istek gönderilsin mi? (10 Elmas)": "Enviar pedido para ouvir com? (10 Gemas)",

        // Gourmet
        "Gurme Deneyimi": "Experiência Gourmet",
        "100+ restoran, rezervasyon yap, eşleş": "100+ restaurantes, reserve, combine",
        "Restoran ara...": "Pesquisar restaurantes...",
        "Mutfak": "Cozinha",
        "Şehir": "Cidade",
        "Fiyat": "Preço",
        "Özel Lezzetler": "Sabores Especiais",
        
        // Book Club
        "Kitap Kulübü": "Clube do Livro",
        "Aynı kitabı okuyan insanlarla tanış": "Conheça pessoas lendo o mesmo livro",
        "Kitap veya yazar ara...": "Pesquisar livro ou autor...",
        "Roman": "Romance",
        "Klasik": "Clássico",
        "Bilim Kurgu": "Ficção Científica",
        "Fantastik": "Fantasia",
        "Polisiye": "Crime",
        "Tarih": "História",
        "Biyografi": "Biografia",
        "Felsefe": "Filosofia",
        "Psikoloji": "Psicologia",
        "Şiir": "Poesia",
        "okuyucu": "leitores",
        "sayfa": "páginas",
        "Okuma Grubuna Katıl": "Juntar-se ao Grupo de Leitura",
        
        // Travel Buddy
        "Seyahat Arkadaşı": "Companheiro de Viagem",
        "Dünyayı birlikte keşfet": "Explore o mundo juntos",
        "Destinasyon ara...": "Pesquisar destino...",
        "Stil": "Estilo",
        "Bütçe": "Orçamento",
        "Süre": "Duração",

        "Kültür": "Cultura",
        "Plaj": "Praia",
        "Doğa": "Natureza",
        "Lüks": "Luxo",
        "Backpacking": "Mochilão",
        "Uçak Bileti Al": "Comprar Passagem Aérea",
        "Seyahat Arkadaşı Bul": "Encontrar Companheiro de Viagem",
        
        // Daily Streak & Ads
        "Günlük Seri": "Sequência Diária",
        "Günlük Seri!": "Sequência Diária!",
        "Serin devam ediyor🔥": "Sequência continua🔥",
        "Bugün giriş yap!": "Faça login hoje!",

        "gün süren var": "dias de sequência",
        "Seriyi tamamla, elmas kazan!": "Complete a sequência, ganhe gemas!",
        "Reklam İzle & Kazan": "Assistir Anúncio & Ganhar",
        "+10 Elmas": "+10 Gemas",
        "Kısa bir reklam izle, anında elmas kazan!": "Assista a um anúncio curto, ganhe gemas!",
        "İzle": "Assistir",
        
        // Likes View




        // Favorites/Likes View



        // Moods & Subtitles
        "Heyecan": "Emoção",
        "Aşk": "Amor",
        "Dinlenme": "Descanso",
        "Eğlence": "Diversão",
        "Sohbet": "Bate-papo",
        "Sanat": "Arte",
        "Parti": "Festa",
        "Derin": "Profundo",

        // Live Events (Mock)
        "Canlı Müzik - Indie Rock": "Música ao Vivo - Indie Rock",
        "Yerel indie rock gruplarının performansı": "Apresentação de bandas locais de indie rock",
        "Jazz Night": "Noite de Jazz",
        "Caz müzik severler için özel gece": "Noite especial para amantes de jazz",
        "Kahve & Sohbet": "Café e Bate-papo",
        "Yeni insanlarla tanış, kahve iç": "Conheça novas pessoas, tome café",
        "Kitap Okuma Kulübü": "Clube de Leitura",
        "Bu ay: Sabahattin Ali - Kürk Mantolu Madonna": "Este mês: Sabahattin Ali - Madonna com Casaco de Pele",
        "Yoga & Tanışma": "Yoga e Encontro",
        "Sabah yogası ve kahvaltı": "Yoga matinal e café da manhã",
        "Gurme Akşam Yemeği": "Jantar Gourmet",
        "Şef menüsü ve yeni tanışmalar": "Menu do chef e novos encontros",
        "Sanat Galerisi Turu": "Tour na Galeria de Arte",
        "Çağdaş sanat sergisi gezisi": "Visita à exposição de arte contemporânea",
        "Plaj Voleybolu": "Vôlei de Praia",
        "Dostluk maçı ve eğlence": "Jogo amistoso e diversão",
        "Müzik": "Música",
        "Kahve": "Café",
        "Wellness": "Bem-estar",
        "Yemek": "Comida",





        // Time Units
        "1 Hafta": "1 Semana",
        "1 Ay": "1 Mês",
        "6 Ay": "6 Meses",
        "Hafta": "Semana",
        "Ay": "Mês",
        "Yıl": "Ano",

        // Profile & Premium
        "Mevcut:": "Atual:",
        "30 dakika boyunca profilini öne çıkar ve 10 kat daha fazla görüntülenme al!": "Destaque seu perfil por 30 min e tenha 10x mais visualizações!",
        "adet": "unid.",
        "EN İYİ FİYAT": "MELHOR PREÇO",
        "Tüm premium özelliklere eriş!": "Acesse todos os recursos premium!",

        "5 Super Like / Gün": "5 Super Likes / Dia",
        "1 Boost / Ay": "1 Boost / Mês",

        "Geri Alma": "Voltar",
        "Konum Değiştir": "Alterar Localização",
        "Gizli Mod": "Modo Anônimo",
        "EN POPÜLER": "MAIS POPULAR",
        "Satın Al -": "Comprar -",
        "Abonelik otomatik olarak yenilenir. İstediğin zaman iptal edebilirsin.": "A assinatura renova automaticamente. Cancele quando quiser.",
        "Premium Aktif! 🎉": "Premium Ativado! 🎉",
        "Harika!": "Ótimo!",
        "VibeU Gold aboneliğin aktif edildi!": "Sua assinatura VibeU Gold está ativa!",
        "Premium üyeliğiniz aktif edildi!": "Sua assinatura premium está ativa!",
        "Sınırsız eşleşme, sınırsız bağlantı": "Matches ilimitados, conexões ilimitadas",
        "Günlük limit olmadan beğen": "Curta sem limites diários",
        "Kimin beğendiğini anında öğren": "Veja instantaneamente quem curtiu você",
        "Global Keşif": "Descoberta Global",
        "Dünyanın her yerinden bağlan": "Conecte-se de qualquer lugar do mundo",
        "Özel Profil Çerçevesi": "Moldura de Perfil Especial",
        "Premium rozeti ile öne çık": "Destaque-se com o emblema Premium",
        "Öncelikli Görünürlük": "Visibilidade Prioritária",
        "Profilin daha çok gösterilsin": "Faça seu perfil ser mais visto",
        "Sınırsız Geri Alma": "Voltar Ilimitado",
        "Yanlışlıkla geçtiklerini geri al": "Desfaça deslizes acidentais",
        "Planını Seç": "Escolha Seu Plano",
        "EN İYİ": "MELHOR",
        "POPÜLER": "POPULAR",
        "Haftalık": "Semanal",
        "Aylık": "Mensal",
        "Yıllık": "Anual",
        "/hafta": "/semana",
        "Tasarruf": "Economia",
        "Şimdilik Geç": "Pular por Agora",
        "Kullanım Şartları": "Termos de Uso",
        "Gizlilik Politikası": "Política de Privacidade",
        "Satın Alımları Geri Yükle": "Restaurar Compras",
        "Tebrikler! 🎉": "Parabéns! 🎉",
        
        // Diamond / Gems
        "Elmaslarım": "Minhas Gemas",
        "Elmas": "Gemas",
        "Günlük Ödül": "Recompensa Diária",
        "Ödülümü Al": "Resgatar",
        "Bugünkü ödülünü aldın!": "Você resgatou sua recompensa hoje!",
        "Yeni ödül:": "Próxima recompensa:",
        "saat": "horas",
        "dakika": "minutos",
        "Reklam İzle": "Assistir Anúncio",
        "Reklam İzle & 25 Elmas Kazan": "Assistir Anúncio e Ganhar 25 Gemas",
        "Günde 1 kez kullanılabilir": "Disponível uma vez por dia",
        "Bugün reklamı izledin!": "Você assistiu ao anúncio hoje!",
        "Yarın tekrar izleyebilirsin": "Você pode assistir novamente amanhã",
        "Reklam izle, 25 elmas kazan": "Assista anúncio, ganhe 25 gemas",

        // Filters
        "Keşif Modu": "Modo Descoberta",
        "🌍 Global (Dünya Geneli)": "🌍 Global (Mundial)",
        "🇹🇷 Türkiye (Yerel)": "🇹🇷 Turquia (Local)",
        "Yaş Aralığı": "Faixa Etária",
        "Hızlı Filtreler": "Filtros Rápidos",
        "Sadece Doğrulanmış": "Apenas Verificados",
        "Fotoğraflı Profiller": "Perfis com Fotos",
        "İlişki Amacı": "Objetivo de Relacionamento",
        "Hepsi": "Todos",
        "Ciddi İlişki": "Relacionamento Sério",
        "Arkadaşlık": "Amizade",
        "Belirsiz": "Não Tenho Certeza",
        "Evlilik": "Casamento",
        "Filtreleri Sıfırla": "Redefinir Filtros",
        "Sıfırla": "Redefinir",
        "Uygula": "Aplicar",
        "Filtreler sıfırlandı": "Filtros redefinidos",

        // Moods Detail
        "Ne yapmak istersin?": "O que você quer fazer?",
        "Kişi Bul": "Encontrar Pessoas",
        "Aynı ruh halindeki insanlarla tanış": "Conheça pessoas com o mesmo humor",
        "Tavsiye Al": "Obter Conselhos",
        "Ruh haline göre öneriler al": "Obtenha recomendações baseadas no humor",
        "Kişi Bul'a Geç": "Mudar para Encontrar Pessoas",
        "İçin Öneriler": "Recomendações para",
        "Ruh Hali": "Humor",

        // Mood Tips - Adventure
        "Doğa Yürüyüşü": "Caminhada",
        "Şehirden kaç, ormanda kaybol!": "Fuja da cidade, perca-se na floresta!",
        "Hafta Sonu Kaçamağı": "Fuga de Fim de Semana",
        "Yakın bir şehre git, keşfet": "Visite uma cidade próxima, explore",
        "Fotoğraf Gezisi": "Viagem Fotográfica",
        "Yeni yerler keşfet, anıları yakala": "Explore novos lugares, capture memórias",

        // Mood Tips - Romantic
        "Romantik Akşam": "Noite Romântica",
        "Mum ışığında yemek, şarap": "Jantar à luz de velas, vinho",
        "Gece Yürüyüşü": "Caminhada Noturna",
        "Sahilde el ele yürü": "Caminhe de mãos dadas na praia",
        "Sürpriz Hediye": "Presente Surpresa",
        "Küçük ama anlamlı bir şey al": "Compre algo pequeno mas significativo",
        
        // Mood Tips - Chill
        "Kahve Molası": "Pausa para Café",
        "Favori kahve dükkanında dinlen": "Relaxe na sua cafeteria favorita",
        "Kitap Keyfi": "Prazer da Leitura",
        "Rahat bir köşede kitabına dal": "Mergulhe no seu livro em um canto aconchegante",
        "Yoga Seansı": "Sessão de Yoga",
        "Bedenini ve zihnini dinlendir": "Descanse seu corpo e mente",

        // Mood Tips - Party
        "Konser": "Show",
        "Canlı müzik enerjisi yakala": "Sinta a energia da música ao vivo",
        "Dans Gecesi": "Noite de Dança",
        "Kulüpte sabaha kadar eğlen": "Divirta-se no clube até de manhã",
        "Ev Partisi": "Festa em Casa",
        "Arkadaşlarını topla, parti kur": "Reúna amigos, faça uma festa",

        // Mood Tips - Deep
        "Derin Sohbet": "Conversa Profunda",
        "Hayatın anlamını tartış": "Discuta o significado da vida",
        "Sanat Galerisi": "Galeria de Arte",
        "Eserleri yorumla, düşün": "Interprete obras, pense",
        "Günlük Tut": "Manter um Diário",
        "Düşüncelerini yazıya dök": "Escreva seus pensamentos",
        
        // Mood Tips - Creative
        "Resim Yap": "Pintar",
        "Tuval al, hayal gücünü çalıştır": "Pegue uma tela, ative sua imaginação",
        "Müzik Yap": "Fazer Música",
        "Enstrüman çal veya beat yap": "Toque um instrumento ou faça um beat",
        "Fotoğrafçılık": "Fotografia",
        "Farklı açılardan dünyayı yakala": "Capture o mundo de ângulos diferentes",

        // Mood Tips - Default
        "Yeni Bir Şey Dene": "Tente Algo Novo",
        "Konfor alanından çık": "Saia da sua zona de conforto",
        "Arkadaşlarla Buluş": "Encontrar Amigos",
        "Sosyalleş, eğlen": "Socialize, divirta-se",
        "Kendine Zaman Ayır": "Tire um Tempo para Você",
        "Sevdiğin bir aktivite yap": "Faça uma atividade que você ama",

        // Profile Overlay
        "İlk İzlenim ile öne çık": "Destaque-se com Primeira Impressão",
        "Eşleşmeden önce ona mesaj göndererek dikkatini çek. Ona profilinde hoşuna giden şeyin ne olduğunu söyleyebilir, iltifat edebilir veya onu güldürebilirsin.": "Chame a atenção enviando uma mensagem antes de dar match. Diga o que você gosta no perfil, faça um elogio ou faça rir.",
        "Mesajın...": "Sua mensagem...",
        "Mesajın gönderildi!": "Mensagem enviada!",


        
        // Quick Date / Blind Date
        "Kör Randevu": "Encontro às Cegas",
        "Fotoğrafsız tanış": "Conheça sem fotos",
        "Eşleşme Bulundu! 🎉": "Match Encontrado! 🎉",
        "Eşleşme Aranıyor...": "Procurando Match...",
        "Sizin için en uygun kişi bulunuyor": "Encontrando o melhor match para você",
        "Hepsi Bu Kadar!": "É só isso!",
        "Yeni kullanıcılar için tekrar gel": "Volte para novos usuários",
        "Gizemli Kişi": "Pessoa Misteriosa",
        "Tanışalım mı?": "Vamos nos conhecer?",
        "VibeU Eşleşmesi": "Match do VibeU",

        // Voice Match
        "Ses Eşleşmesi! 🎙️": "Match de Voz! 🎙️",
        "Konuşacak Biri Aranıyor...": "Procurando alguém para conversar...",
        "Sesine kulak verecek biri bulunuyor": "Encontrando alguém para ouvir...",
        "Kaydı İptal Et": "Cancelar Gravação",
        "Kaydediliyor...": "Gravando...",
        "30 saniyelik sesli mesaj kaydet": "Grave uma mensagem de voz de 30s",
        "Durdur": "Parar",
        "Kayda Başla": "Iniciar Gravação",
        "Sesli Mesajı Dinle": "Ouvir Mensagem",
        
        // Astro Match
        "Yıldızlar Eşleşti! ✨": "As Estrelas Combinam! ✨",
        "Burç Uyumu Aranıyor...": "Procurando Compatibilidade Astral...",
        "Yıldız haritanız karşılaştırılıyor": "Comparando mapas astrais...",
        "Astroloji": "Astrologia",
        "Ruh haline göre eşleş": "Combinar por humor",
        "Bugün zaten giriş yaptın!": "Já fez check-in hoje!",
        "Tebrikler! Reklam izleyerek 50 Elmas kazandın! 💎": "Parabéns! Ganhou 50 Diamantes! 💎",
        "Harika! 🎉": "Ótimo! 🎉",
        "Filtrelerinize uygun kullanıcı bulunamadı": "Nenhum usuário encontrado com seus filtros",
        "Kullanıcılar yüklenirken hata oluştu": "Erro ao carregar usuários",
        "Sosyal Hesaplar": "Contas Sociais",
        "Kilitli": "Bloqueado",
        "Hesaplar Gizli": "Contas Privadas",
        "Sosyal medya hesaplarını görmek için arkadaş olmalısın.": "Você deve ser amigo para ver as redes sociais.",
        "İstek Gönderildi": "Pedido Enviado",
        "kişisine arkadaşlık isteği gönderildi": "pedido de amizade enviado para",
        "Yetersiz Elmas 💎": "Diamantes Insuficientes 💎",
        "Elmas Al": "Obter Diamantes",
        "Arkadaşlık isteği göndermek için 10 elmas gerekiyor. Günlük ücretsiz elmasını alabilirsin!": "Enviar pedido custa 10 diamantes. Reivindique seus diamantes diários!",
        "km uzakta": "km de distância",
        "common_interests": "Interesses Comuns",

        "Konum": "Localização",
        "Katılımcılar": "Participantes",
        "kişi": "pessoas",
        "Açıklama": "Descrição",
        "Bilet Al": "Comprar Bilhete",
        "Etkinliğe Katıl": "Entrar no Evento",
        "Çifte Randevu arkadaşları": "Amigos de Encontro Duplo",
        "Çifte Randevu'da en fazla 3 arkadaşınla çift olabilirsin.": "Você pode formar par com até 3 amigos.",
        "Daha fazla bilgi edin": "Saiba mais",
        "Arkadaşlardan gelen davetler": "Convites de amigos",
        "Çifte Randevu davetlerini burada göreceksin.": "Você verá convites aqui.",
        "Arkadaşlarını Davet Et": "Convidar Amigos",
        "Seni Çifte Randevu'ya davet etti": "Convidou você para um Encontro Duplo",
        "Kullanıcı": "Usuário",
        "Profili Düzenle": "Editar Perfil",
        "Profili Tamamla": "Completar Perfil",
        "DAHA FAZLA AL": "OBTER MAIS",
        "GÖRÜNTÜLE": "VER",

        "Super Like ile öne çık ve eşleşme şansını 3 kat artır!": "Destaque-se com Super Like e aumente a chance de match em 3x!",
        "Fotoğraflar": "Fotos",
        "Profilini öne çıkar": "Destaque seu perfil",
        "İlgi Alanları": "Interesses",
        "Ortak noktalarını bul": "Encontre pontos em comum",
        "Sosyal Medya": "Redes Sociais",
        "Hesaplarını bağla": "Conectar contas",
        "Hızlıca paylaş": "Compartilhar rápido",
        "Görünüm": "Aparência",
        "Tema": "Tema",
        "Dil": "Idioma",
        "Bildirimler": "Notificações",
        "Hesap": "Conta",
        "Gizlilik": "Privacidade",
        "Engellenenler": "Usuários Bloqueados",
        "Destek": "Suporte",
        "Yardım Merkezi": "Centro de Ajuda",
        "Bize Ulaşın": "Contate-nos",
        "Sürüm": "Versão",
        "Hesabı Sil": "Excluir Conta",
        "Ayarlar": "Configurações",
        "Tamam": "OK",
        "İptal": "Cancelar",
        "Sil": "Excluir",
        "Bu işlem geri alınamaz. Tüm verileriniz silinecektir.": "Esta ação não pode ser desfeita. Todos os seus dados serão excluídos.",
        "Kullanıcı Adı": "Nome de usuário",
        "İsim": "Nome",
        "Hakkımda": "Sobre mim",
        "Konum & Kariyer": "Localização e Carreira",

        "Ülke": "País",
        "Meslek": "Profissão",
        "Şirket": "Empresa",
        "Fiziksel Özellikler": "Atributos Físicos",
        "Boy (cm)": "Altura (cm)",
        "Burç": "Zodíaco",
        "Yaşam Tarzı": "Estilo de Vida",
        "Sigara": "Fumar",
        "Alkol": "Beber",
        "Egzersiz": "Exercício",
        "Evcil Hayvan": "Animais",
        "İlişki Tercihleri": "Objetivos de Relacionamento",
        "Ne Arıyorum": "Procurando",
        "Çocuk İstiyor musun": "Quer filhos",
        "Hobiler & İlgi Alanları": "Hobbies e Interesses",
        "En fazla 8 hobi seç": "Selecione até 8 hobbies",
        "Sosyal Medya Hesapları": "Contas de Redes Sociais",
        "Fotoğrafı Değiştir": "Alterar Foto",
        "Seç": "Selecionar",
        "Fotoğrafların": "Suas Fotos",
        "Sürükleyip bırakarak sıralamayı değiştir": "Arraste e solte para reordenar",
        "Ana Fotoğraf": "Foto Principal",
        "Silmek istediğine emin misin?": "Tem certeza que deseja excluir?",
        "Kaydet": "Salvar",

        "Sıralamak için basılı tut ve sürükle": "Pressione e segure para arrastar e reordenar",
        "İlk fotoğraf profil fotoğrafın olacak": "A primeira foto será sua foto de perfil",
        "Silinemez": "Não é possível excluir",
        "En az 1 fotoğrafın olmalı. Son fotoğrafı silemezsin.": "Você deve ter pelo menos 1 foto. Você não pode excluir a última foto.",
        "fotoğraf kaydedildi.": "fotos salvas.",
        "fotoğraf": "fotos"
    ]
}

// MARK: - Direct Localization Extension (Global)
extension String {
    var localized: String {
        let language = UserDefaults.standard.string(forKey: "appLanguage") ?? "tr"
        if let translated = ManualTranslations.translate(key: self, language: language) {
            return translated
        }
        return self
    }
}

@Observable @MainActor
final class AppState {
    var authState: AuthState = .loading
    var currentUser: User?
    var showPremiumOnLaunch = false
    
    // Navigation
    var selectedTab: Int = 0
    var pendingConversation: Conversation?
    var shouldNavigateToChat: Bool = false
    var isTabBarHidden: Bool = false
    
    // New conversations created from matches
    var newConversations: [Conversation] = []
    
    // Theme
    var currentTheme: AppTheme {
        get {
            if let saved = UserDefaults.standard.string(forKey: "appTheme"),
               let theme = AppTheme(rawValue: saved) {
                return theme
            }
            return .dark
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "appTheme")
        }
    }
    
    // Language
    var currentLanguage: AppLanguage {
        get {
            if let saved = UserDefaults.standard.string(forKey: "appLanguage"),
               let lang = AppLanguage(rawValue: saved) {
                return lang
            }
            return .turkish
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage")
            UserDefaults.standard.set([newValue.rawValue], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            Bundle.setLanguage(newValue.rawValue)
        }
    }
    
    // Language refresh trigger
    var languageRefreshId = UUID()
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        languageRefreshId = UUID()
        
        // Save to UserDefaults and update Bundle language
        UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        Bundle.setLanguage(language.rawValue)
        
        // Trigger UI update via LanguageManager
        LanguageManager.shared.setLanguage(language.rawValue)
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }
    
    // MARK: - Profile Completeness Check
    // Property 14: Profile Completeness Check
    // Validates: Requirements 1.1, 1.2, 1.3
    // Zorunlu alanlar: displayName, dateOfBirth, gender, country, city, profilePhotoUrl
    var isProfileComplete: Bool {
        guard let user = currentUser else { return false }
        
        // Check displayName is not empty
        let hasDisplayName = !user.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Check dateOfBirth is valid (not default/placeholder date)
        // A valid date should be in the past and user should be at least 15 years old
        let hasValidDateOfBirth = isValidDateOfBirth(user.dateOfBirth)
        
        // Check gender is set (any value is valid since we have preferNotToSay option)
        let hasGender = true // Gender is always set since it's an enum with default
        
        // Check country is not empty
        let hasCountry = !user.country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Check city is not empty
        let hasCity = !user.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Check profilePhotoURL is not empty and is a valid URL
        let hasProfilePhoto = !user.profilePhotoURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                              URL(string: user.profilePhotoURL) != nil
        
        return hasDisplayName && hasValidDateOfBirth && hasGender && hasCountry && hasCity && hasProfilePhoto
    }
    
    // Helper function to validate date of birth
    private func isValidDateOfBirth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Date should be in the past
        guard date < now else { return false }
        
        // Calculate age
        let ageComponents = calendar.dateComponents([.year], from: date, to: now)
        guard let age = ageComponents.year else { return false }
        
        // User must be at least 15 years old (per Requirements 1.4, 1.5)
        return age >= 15
    }
    
    // MARK: - Profile Completion Percentage (10 fields * 10% each = 100%)
    /// Calculates profile completion percentage based on 10 key profile fields
    var profileCompletionPercentage: Int {
        guard let user = currentUser else { return 0 }
        
        var completedFields = 0
        
        // 1. Display Name (10%)
        if !user.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { completedFields += 1 }
        
        // 2. Date of Birth (10%)
        if isValidDateOfBirth(user.dateOfBirth) { completedFields += 1 }
        
        // 3. Country (10%)
        if !user.country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { completedFields += 1 }
        
        // 4. City (10%)
        if !user.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { completedFields += 1 }
        
        // 5. Profile Photo (10%)
        if !user.profilePhotoURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && URL(string: user.profilePhotoURL) != nil { completedFields += 1 }
        
        // 6. Bio (10%)
        if let bio = user.bio, !bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { completedFields += 1 }
        
        // 7. At least 3 Interests (10%)
        if user.interests.count >= 3 { completedFields += 1 }
        
        // 8. At least 3 Photos (10%)
        if user.photos.count >= 3 { completedFields += 1 }
        
        // 9. Job or University (10%)
        let hasJob = user.jobTitle?.isEmpty == false || user.company?.isEmpty == false
        let hasUniversity = user.university?.isEmpty == false
        if hasJob || hasUniversity { completedFields += 1 }
        
        // 10. Height or Zodiac (10%)
        let hasHeight = user.height?.isEmpty == false
        let hasZodiac = user.zodiac?.isEmpty == false
        if hasHeight || hasZodiac { completedFields += 1 }
        
        return completedFields * 10 // Each field = 10%
    }
    
    // MARK: - Check and Award Verification
    /// Checks if profile is 100% complete and awards the blue verification tick
    func checkAndAwardVerification() {
        guard let user = currentUser else { return }
        
        // If already verified, no need to check again
        guard !user.isVerified else { return }
        
        // Award verification if profile is 100% complete
        if profileCompletionPercentage >= 100 {
            // Update local state
            currentUser?.isVerified = true
            
            // Update Firebase
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Task {
                do {
                    try await UserService.shared.updateUserFields(uid: uid, data: [
                        "is_verified": true
                    ])
                    
                    await LogService.shared.info("✅ Blue tick awarded for 100% profile completion", category: "Profile")
                    
                    // Haptic feedback for achievement
                    let notification = UINotificationFeedbackGenerator()
                    notification.notificationOccurred(.success)
                } catch {
                    print("❌ Failed to update verification status: \(error)")
                }
            }
        }
    }
    
    var isPremium: Bool {
        get { 
            // Read from UserDefaults
            return UserDefaults.standard.bool(forKey: "isPremium")
        }
        set { 
            UserDefaults.standard.set(newValue, forKey: "isPremium")
            UserDefaults.standard.set(newValue, forKey: "user_isPremium")
        }
    }
    
    // Boost sistemi - 5 boost = kendini öne çıkarma
    var boostCount: Int {
        get { UserDefaults.standard.integer(forKey: "boostCount") }
        set { UserDefaults.standard.set(newValue, forKey: "boostCount") }
    }
    
    func useBoost(count: Int = 5) -> Bool {
        guard boostCount >= count else { return false }
        boostCount -= count
        return true
    }
    
    func addBoosts(_ count: Int) {
        boostCount += count
    }
    
    var hasSkippedPremium: Bool {
        get { UserDefaults.standard.bool(forKey: "hasSkippedPremium") }
        set { UserDefaults.standard.set(newValue, forKey: "hasSkippedPremium") }
    }
    
    // Remember login
    var isLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: "isLoggedIn") }
        set { UserDefaults.standard.set(newValue, forKey: "isLoggedIn") }
    }
    
    init() {
        // Load saved language
        Bundle.setLanguage(currentLanguage.rawValue)
        checkAuthState()
        
        // Start location services
        Task { @MainActor in
            LocationManager.shared.requestLocationPermission()
        }
        
        // Listen for diamond balance changes using Selector-based observer for classic NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(handleDiamondBalanceChange), name: .diamondBalanceChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleDiamondBalanceChange() {
        Task {
            await refreshDiamondBalance()
        }
    }
    
    func refreshDiamondBalance() async {
        do {
            let balance = try await DiamondService.shared.getBalance()
            if var user = currentUser {
                user.diamondBalance = balance
                self.currentUser = user
                print("💎 [AppState] Diamond balance synced: \(balance)")
            }
        } catch {
            print("⚠️ [AppState] Failed to sync diamond balance: \(error)")
        }
    }
    
    func checkAuthState() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            
            print("🔐 [AppState] Checking auth state...")
            
            // Check if AuthService has a token
            if AuthService.shared.isAuthenticated {
                print("✅ [AppState] User is authenticated")
                do {
                    // Get user from backend
                    currentUser = try await AuthService.shared.getCurrentUser()
                    print("✅ [AppState] User loaded: \(currentUser?.displayName ?? "Unknown")")
                    authState = .authenticated
                    isLoggedIn = true
                    checkPremiumStatus()
                    return
                } catch {
                    // Token expired or invalid
                    print("❌ [AppState] Failed to load user: \(error.localizedDescription)")
                    AuthService.shared.clearAuth()
                    authState = .unauthenticated
                    isLoggedIn = false
                }
            } else if !hasCompletedOnboarding {
                print("📱 [AppState] Showing onboarding")
                authState = .onboarding
            } else {
                print("🔓 [AppState] User not authenticated")
                authState = .unauthenticated
            }
        }
    }
    
    func checkPremiumStatus() {
        // Premium değilse ve daha önce geçmediyse göster
        if !isPremium && !hasSkippedPremium {
            showPremiumOnLaunch = true
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        authState = .unauthenticated
    }
    
    func signIn(user: User, accessToken: String, refreshToken: String) {
        var finalToken = accessToken
        #if DEBUG
        // In debug mode, if we don't have a real JWT, use the special ID format
        // so backend knows who we are (instead of assuming test-user-1)
        finalToken = "firebase_uid_" + user.id
        print("🔧 [AppState] Using debug token: \(finalToken)")
        #endif
        
        KeychainManager.shared.saveAccessToken(finalToken)
        KeychainManager.shared.saveRefreshToken(refreshToken)
        currentUser = user
        isLoggedIn = true
        
        // Check if user has completed onboarding (profile_completed_at exists)
        if user.profileCompletedAt == nil {
            print("📝 [AppState] User needs to complete onboarding")
            authState = .needsProfileSetup
        } else {
            print("✅ [AppState] User profile is complete")
            authState = .authenticated
            checkPremiumStatus()
        }
        
        // Sync user to backend database for friend requests
        Task {
            await syncUserToBackend(user: user)
        }
    }
    
    private func syncUserToBackend(user: User) async {
        do {
            let dateFormatter = ISO8601DateFormatter()
            
            struct SyncUserBody: Codable {
                let userId: String
                let displayName: String
                let email: String
                let profilePhotoUrl: String?
                let dateOfBirth: String
                let gender: String
                let country: String
                let city: String
            }
            
            let body = SyncUserBody(
                userId: user.id,
                displayName: user.displayName,
                email: user.username,
                profilePhotoUrl: user.profilePhotoURL,
                dateOfBirth: dateFormatter.string(from: user.dateOfBirth),
                gender: user.gender.rawValue,
                country: user.country,
                city: user.city
            )
            
            try await APIClient.shared.requestVoid(
                endpoint: "/auth/sync",
                method: .post,
                body: body,
                requiresAuth: false
            )
            print("✅ User synced to backend: \(user.id)")
        } catch {
            print("⚠️ Failed to sync user to backend: \(error)")
        }
    }
    
    func signOut() {
        // AuthService'den çıkış
        AuthService.shared.logout()
        
        // Firebase'den çıkış
        try? Auth.auth().signOut()
        
        // Keychain temizle
        KeychainManager.shared.deleteTokens()
        
        // Tüm kullanıcı verilerini temizle (ProfileKeys)
        let userKeys = [
            "user_displayName",
            "user_bio",
            "user_city",
            "user_jobTitle",
            "user_interests",
            "user_instagram",
            "user_tiktok",
            "user_snapchat",
            "user_twitter",
            "user_spotify",
            "user_photos",
            "user_superLikes",
            "user_boosts",
            "user_isPremium",
            "isPremium",
            "boostCount",
            "hasSkippedPremium",
            "isLoggedIn",
            // Safety settings
            "safety_hideAge",
            "safety_hideDistance",
            "safety_hideOnlineStatus",
            "safety_readReceipts",
            // Filter settings
            "filter_minAge",
            "filter_maxAge",
            "filter_maxDistance",
            "filter_verifiedOnly",
            "filter_onlineOnly",
            "filter_withPhoto",
            "filter_withBio",
            // Notification settings
            "notifications_enabled",
            "location_enabled"
        ]
        
        for key in userKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        
        // State temizle
        currentUser = nil
        isLoggedIn = false
        hasSkippedPremium = false
        showPremiumOnLaunch = false
        newConversations = []
        pendingConversation = nil
        shouldNavigateToChat = false
        selectedTab = 0
        
        authState = .unauthenticated
        
        Task {
            await LogService.shared.info("Kullanıcı çıkış yaptı - tüm veriler temizlendi", category: "Auth")
        }
    }
    
    func purchasePremium() {
        isPremium = true
        hasSkippedPremium = true
        showPremiumOnLaunch = false
    }
    
    func skipPremium() {
        hasSkippedPremium = true
        showPremiumOnLaunch = false
    }
    
    // Create new conversation from match
    func createConversationFromMatch(name: String, age: Int, city: String, photoURL: String, compatibility: Int) {
        let newConversation = Conversation(
            id: "match_\(UUID().uuidString)",
            participant: ChatParticipant(
                id: UUID().uuidString,
                displayName: name,
                profilePhotoURL: photoURL,
                isOnline: true,
                lastActiveAt: Date()
            ),
            lastMessage: ChatMessage(
                id: UUID().uuidString,
                conversationId: "match_\(UUID().uuidString)",
                senderId: "system",
                content: "🎉 %\(compatibility) uyum ile eşleştiniz!",
                messageType: .text,
                isRead: false,
                createdAt: Date()
            ),
            unreadCount: 1,
            updatedAt: Date()
        )
        
        newConversations.insert(newConversation, at: 0)
        pendingConversation = newConversation
        shouldNavigateToChat = true
        selectedTab = 3 // Chat tab
    }
    
    // MARK: - Discover Users Cache
    var cachedDiscoverUsers: [DiscoverUser] = []
    var lastDiscoverFetch: Date?
    
    func prefetchDiscoverUsers() {
        Task {
            do {
                let response = try await DiscoverService.shared.getDiscoverFeed(
                    mode: .forYou,
                    limit: 50,
                    countryFilter: nil
                )
                await MainActor.run {
                    self.cachedDiscoverUsers = response.users
                    self.lastDiscoverFetch = Date()
                }
                print("✅ Prefetched \(response.users.count) discover users")
            } catch {
                print("⚠️ Failed to prefetch discover users: \(error)")
            }
        }
    }
    
    func shouldRefreshDiscoverCache() -> Bool {
        guard let lastFetch = lastDiscoverFetch else { return true }
        return Date().timeIntervalSince(lastFetch) > 300 // 5 minutes
    }
}
