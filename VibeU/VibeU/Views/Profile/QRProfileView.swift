import SwiftUI
import CoreImage.CIFilterBuiltins
import FirebaseAuth
import MultipeerConnectivity

struct QRProfileView: View {
    @State private var qrImage: UIImage?
    @State private var qrImageWithLogo: UIImage?
    @State private var showSavedAlert = false
    @State private var showShareSheet = false
    @State private var profilePhoto: UIImage?
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.dismiss) private var dismiss
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // MARK: - ID Card Design (Shared Component)
                    ProfileQRCard(user: nil, qrImage: qrImageWithLogo ?? qrImage)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // MARK: - Share Section
                    VStack(spacing: 20) {
                        Text("Hikayende Paylaş".localized)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(colors.secondaryText)
                        
                        HStack(spacing: 32) {
                            // TikTok
                            Button { shareTikTok() } label: {
                                VStack(spacing: 8) {
                                    Image("TikTokIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
                                    
                                    Text("TikTok")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(colors.secondaryText)
                                }
                            }
                            
                            // Instagram
                            Button { shareInstagram() } label: {
                                VStack(spacing: 8) {
                                    Image("InstagramIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
                                    
                                    Text("Instagram")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(colors.secondaryText)
                                }
                            }
                            
                            // Snapchat
                            Button { shareSnapchat() } label: {
                                VStack(spacing: 8) {
                                    Image("SnapchatIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
                                    
                                    Text("Snapchat")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(colors.secondaryText)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Action Buttons
                    HStack(spacing: 16) {
                        Button { showShareSheet = true } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Paylaş".localized)
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 1))
                        }
                        
                        Button { saveQR() } label: {
                            HStack {
                                Image(systemName: "arrow.down.to.line")
                                Text("Kaydet".localized)
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .cyan.opacity(0.3), radius: 8, y: 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("QR Profilim".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
        .onAppear {
            generateQR()
            loadProfilePhoto()
        }
        .alert("Kaydedildi ✓".localized, isPresented: $showSavedAlert) {
            Button("Tamam".localized) { }
        } message: {
            Text("QR kod fotoğraflarına kaydedildi.".localized)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = qrImageWithLogo ?? qrImage {
                ShareSheet(items: [image])
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    // MARK: - QR Code Generation
    
    private func generateQR() {
        // Safe access to ID with fallback
        let userId = Auth.auth().currentUser?.uid ?? appState.currentUser?.id ?? UserDefaults.standard.string(forKey: "current_user_id") ?? UUID().uuidString
        let qrString = QRCodeURLGenerator.generateProfileURL(userId: userId)
        
        filter.message = Data(qrString.utf8)
        filter.correctionLevel = "H"
        
        guard let outputImage = filter.outputImage else { return }
        
        // Scale up for high resolution
        let scale = 10.0
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            let baseQR = UIImage(cgImage: cgImage)
            qrImage = baseQR
            qrImageWithLogo = addLogoToQRCode(baseQR)
        }
        
        Task { await LogService.shared.info("QRProfileView generasyon tamamlandı: \(userId)", category: "Profile") }
    }
    
    private func addLogoToQRCode(_ qrCode: UIImage) -> UIImage {
        let qrSize = qrCode.size
        let logoSize = CGSize(width: qrSize.width * 0.22, height: qrSize.height * 0.22) // Slightly smaller logo for better scanning
        
        UIGraphicsBeginImageContextWithOptions(qrSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        qrCode.draw(in: CGRect(origin: .zero, size: qrSize))
        
        let logoRect = CGRect(
            x: (qrSize.width - logoSize.width) / 2,
            y: (qrSize.height - logoSize.height) / 2,
            width: logoSize.width,
            height: logoSize.height
        )
        
        // White background for logo
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillEllipse(in: logoRect.insetBy(dx: -4, dy: -4)) // Circle cutout
        
        // Draw Logo
        if let appLogo = UIImage(named: "VibeULogo") {
            // Circular Clip
            let path = UIBezierPath(ovalIn: logoRect)
            path.addClip()
            appLogo.draw(in: logoRect)
        } else {
            // Fallback Text Logo
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: logoSize.width * 0.6, weight: .heavy),
                .foregroundColor: UIColor.cyan,
                .paragraphStyle: paragraphStyle
            ]
            
            let text = "V"
            let textRect = CGRect(
                x: logoRect.origin.x,
                y: logoRect.origin.y + (logoRect.height - logoSize.width * 0.72) / 2,
                width: logoRect.width,
                height: logoRect.height
            )
            text.draw(in: textRect, withAttributes: attrs)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? qrCode
    }
    
    // MARK: - Social Media Sharing
    
    private func shareTikTok() {
        guard let image = qrImageWithLogo ?? qrImage else { return }
        let pasteboardItems: [[String: Any]] = [["com.tiktok.story": image.pngData() as Any]]
        UIPasteboard.general.setItems(pasteboardItems, options: [:])
        
        if let url = URL(string: "tiktok://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                shareGeneral()
            }
        }
    }
    
    private func shareInstagram() {
        guard let image = qrImageWithLogo ?? qrImage, let imageData = image.pngData() else { return }
        
        let pasteboardItems: [[String: Any]] = [["com.instagram.sharedSticker.backgroundImage": imageData]]
        UIPasteboard.general.setItems(pasteboardItems, options: [.expirationDate: Date().addingTimeInterval(300)])
        
        if let url = URL(string: "instagram-stories://share?source_application=com.vibeu.app") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                shareGeneral()
            }
        }
    }
    
    private func shareSnapchat() {
        guard let image = qrImageWithLogo ?? qrImage else { return }
        let pasteboardItems: [[String: Any]] = [["com.snapchat.creativekit.media": image.pngData() as Any]]
        UIPasteboard.general.setItems(pasteboardItems, options: [:])
        
        if let url = URL(string: "snapchat://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                shareGeneral()
            }
        }
    }
    
    private func shareGeneral() {
        showShareSheet = true
    }
    
    private func saveQR() {
        guard let image = qrImageWithLogo ?? qrImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSavedAlert = true
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func loadProfilePhoto() {
        // Priority 1: Firebase photos array
        var photoUrlString = appState.currentUser?.photos.first?.url
        
        // Priority 2: profilePhotoURL if not placeholder
        if photoUrlString == nil || photoUrlString?.isEmpty == true {
            if let profileUrl = appState.currentUser?.profilePhotoURL,
               !profileUrl.contains("dicebear"),
               !profileUrl.isEmpty {
                photoUrlString = profileUrl
            }
        }
        
        guard let urlString = photoUrlString, let url = URL(string: urlString) else { return }
        
        Task {
            if let data = try? await URLSession.shared.data(from: url).0,
               let image = UIImage(data: data) {
                await MainActor.run {
                    profilePhoto = image
                }
            }
        }
    }
}

// MARK: - Helpers
struct QRCodeURLGenerator {
    static let scheme = "vibeu"
    static let profilePath = "profile"
    
    static func generateProfileURL(userId: String) -> String {
        return "\(scheme)://\(profilePath)/\(userId)"
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Share View (QR Code + AirDrop) (Merged from ShareView.swift)
struct ShareView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppState.self) private var appState
    
    @State private var showQRScanner = false
    @State private var showMyQRCode = false
    @State private var nearbyUsers: [NearbyUser] = []
    @State private var isSearchingNearby = false
    
    private var colors: ThemeColors {
        colorScheme == .dark ? .dark : .light
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // My QR Code Section
                    myQRCodeSection
                    
                    // Scan QR Code Section
                    scanQRCodeSection
                    
                    // AirDrop Section
                    airDropSection
                    
                    // Nearby Users (AirDrop)
                    if !nearbyUsers.isEmpty {
                        nearbyUsersSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(colors.background.ignoresSafeArea())
            .navigationTitle("Paylaş")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(colors.secondaryText)
                    }
                }
            }
            .sheet(isPresented: $showQRScanner) {
                QRScannerView_New { userId in
                    // Handle scanned user ID
                    handleScannedUser(userId: userId)
                }
            }
            .sheet(isPresented: $showMyQRCode) {
                MyQRCodeView()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 15)
                
                Image(systemName: "person.2.badge.plus")
                    .font(.system(size: 50, weight: .regular))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("Arkadaş Ekle".localized)
                .font(.title2.weight(.bold))
                .foregroundStyle(colors.primaryText)
            
            Text("QR kod veya AirDrop ile arkadaşlarını ekle".localized)
                .font(.subheadline)
                .foregroundStyle(colors.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - My QR Code Section
    private var myQRCodeSection: some View {
        ShareOptionCard(
            icon: "qrcode",
            iconColor: .purple,
            title: "QR Kodunu Göster".localized,
            description: "Arkadaşların seni tarayarak ekleyebilir".localized,
            colors: colors
        ) {
            showMyQRCode = true
        }
    }
    
    // MARK: - Scan QR Code Section
    private var scanQRCodeSection: some View {
        ShareOptionCard(
            icon: "qrcode.viewfinder",
            iconColor: .cyan,
            title: "QR Kod Tara".localized,
            description: "Arkadaşının QR kodunu tara ve ekle".localized,
            colors: colors
        ) {
            showQRScanner = true
        }
    }
    
    // MARK: - AirDrop Section
    private var airDropSection: some View {
        ShareOptionCard(
            icon: "antenna.radiowaves.left.and.right",
            iconColor: .orange,
            title: "Yakındakileri Bul".localized,
            description: "AirDrop ile yakındaki VibeU kullanıcılarını bul".localized,
            colors: colors,
            isLoading: isSearchingNearby
        ) {
            startNearbySearch()
        }
    }
    
    // MARK: - Nearby Users Section
    private var nearbyUsersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Yakındaki Kullanıcılar".localized)
                .font(.headline)
                .foregroundStyle(colors.primaryText)
            
            ForEach(nearbyUsers) { user in
                NearbyUserRow(user: user, colors: colors) {
                    sendFriendRequestToNearbyUser(user)
                }
            }
        }
        .padding(16)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colors.border, lineWidth: 0.5)
        )
    }
    
    // MARK: - Actions
    private func handleScannedUser(userId: String) {
        showQRScanner = false
        Task {
            do {
                try await FriendsService.shared.sendFriendRequest(userId: userId)
                print("✅ Friend request sent via QR scan to: \(userId)")
            } catch {
                print("❌ Failed to send friend request: \(error)")
            }
        }
    }
    
    private func startNearbySearch() {
        isSearchingNearby = true
        // Start MultipeerConnectivity search
        NearbyService.shared.startBrowsing { users in
            DispatchQueue.main.async {
                self.nearbyUsers = users
                self.isSearchingNearby = false
            }
        }
    }
    
    private func sendFriendRequestToNearbyUser(_ user: NearbyUser) {
        Task {
            do {
                try await FriendsService.shared.sendFriendRequest(userId: user.id)
                print("✅ Friend request sent to nearby user: \(user.displayName)")
            } catch {
                print("❌ Failed to send friend request: \(error)")
            }
        }
    }
}

// MARK: - Share Option Card
struct ShareOptionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let colors: ThemeColors
    var isLoading: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [iconColor.opacity(0.8), iconColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .shadow(color: iconColor.opacity(0.3), radius: 8, y: 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                    .font(.headline)
                    .foregroundStyle(colors.primaryText)
                    
                    Text(description)
                    .font(.caption)
                    .foregroundStyle(colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body.weight(.medium))
                    .foregroundStyle(colors.secondaryText)
            }
            .padding(16)
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(colors.border, lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}


// NOTE: ShareView has been moved to /Views/Share/ShareView.swift


// MARK: - My QR Code View
struct MyQRCodeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppState.self) private var appState
    
    private var colors: ThemeColors {
        colorScheme == .dark ? .dark : .light
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // User Info
                VStack(spacing: 16) {
                    if let photoURL = appState.currentUser?.profilePhotoURL {
                        CachedAsyncImage(url: photoURL)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(colors.secondaryBackground)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(colors.secondaryText)
                            )
                    }
                    
                    Text(appState.currentUser?.displayName ?? "Kullanıcı")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(colors.primaryText)
                }
                
                // QR Code
                if let userId = Auth.auth().currentUser?.uid {
                    QRCodeGenerator.generateQRCode(from: "vibeu://user/\(userId)")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding(24)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                        .shadow(color: colors.primaryText.opacity(0.1), radius: 20, y: 10)
                }
                
                Text("Bu QR kodu arkadaşlarına göster".localized)
                    .font(.subheadline)
                    .foregroundStyle(colors.secondaryText)
                
                Spacer()
            }
            .padding(32)
            .background(colors.background.ignoresSafeArea())
            .navigationTitle("QR Kodum".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat".localized) {
                        dismiss()
                    }
                    .foregroundStyle(colors.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - QR Code Generator
struct QRCodeGenerator {
    static func generateQRCode(from string: String) -> Image {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return Image(uiImage: UIImage(cgImage: cgImage))
            }
        }
        
        return Image(systemName: "qrcode")
    }
}

// MARK: - QR Scanner View
// Renamed to avoid conflicts if needed, but keeping simple name as it is unique
struct QRScannerView_New: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let onScanned: (String) -> Void
    
    @State private var scannedCode: String?
    @State private var isScanning = true
    
    private var colors: ThemeColors {
        colorScheme == .dark ? .dark : .light
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Camera Preview (Placeholder - actual implementation needs AVFoundation)
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Scanning Frame
                    RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.cyan, lineWidth: 3)
                    .frame(width: 250, height: 250)
                    .overlay(
                        // Corner indicators
                        ForEach(0..<4) { corner in
                            QRCornerIndicator(corner: corner)
                        }
                    )
                    
                    Spacer()
                    
                    Text("QR Kodu çerçevenin içine hizalayın".localized)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.bottom, 50)
                }
                
                // Scanning Animation
                if isScanning {
                    VStack {
                        Spacer()
                        ScanningLineAnimation()
                            .frame(width: 250, height: 250)
                        Spacer()
                            .frame(height: 100)
                    }
                }
            }
            .navigationTitle("QR Kod Tara".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal".localized) {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .onAppear {
                // In a real implementation, start camera scanning here
                // For demo, we'll simulate a scan after 3 seconds
                #if DEBUG
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    // Simulated scan - in real app this would come from camera
                    // onScanned("test-user-id")
                }
                #endif
            }
        }
    }
}

// MARK: - QR Corner Indicator
struct QRCornerIndicator: View {
    let corner: Int
    
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let length: CGFloat = 30
                let x: CGFloat
                let y: CGFloat
                
                switch corner {
                case 0: // Top Left
                    x = 0; y = 0
                    path.move(to: CGPoint(x: x, y: y + length))
                    path.addLine(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x + length, y: y))
                case 1: // Top Right
                    x = geo.size.width; y = 0
                    path.move(to: CGPoint(x: x - length, y: y))
                    path.addLine(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x, y: y + length))
                case 2: // Bottom Right
                    x = geo.size.width; y = geo.size.height
                    path.move(to: CGPoint(x: x, y: y - length))
                    path.addLine(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x - length, y: y))
                case 3: // Bottom Left
                    x = 0; y = geo.size.height
                    path.move(to: CGPoint(x: x + length, y: y))
                    path.addLine(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x, y: y - length))
                default:
                    break
                }
            }
            .stroke(Color.cyan, lineWidth: 4)
        }
    }
}

// MARK: - Scanning Line Animation
struct ScanningLineAnimation: View {
    @State private var offset: CGFloat = -125
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .cyan.opacity(0.5), .cyan, .cyan.opacity(0.5), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 3)
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    offset = 125
                }
            }
    }
}

// MARK: - Nearby User Model
struct NearbyUser: Identifiable {
    let id: String
    let displayName: String
    let profilePhotoURL: String?
    let peerId: MCPeerID
}

// MARK: - Nearby User Row
struct NearbyUserRow: View {
    let user: NearbyUser
    let colors: ThemeColors
    let onSendRequest: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if let photoURL = user.profilePhotoURL {
                CachedAsyncImage(url: photoURL)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(colors.secondaryBackground)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(colors.secondaryText)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                    .foregroundStyle(colors.primaryText)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text("Yakında")
                        .font(.caption)
                        .foregroundStyle(colors.secondaryText)
                }
            }
            
            Spacer()
            
            Button {
                onSendRequest()
            } label: {
                Image(systemName: "person.badge.plus")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(
                        LinearGradient(
                            colors: [.purple, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Circle()
                    )
            }
        }
        .padding(12)
        .background(colors.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Nearby Service (MultipeerConnectivity)
class NearbyService: NSObject, ObservableObject {
    static let shared = NearbyService()
    
    private let serviceType = "vibeu-nearby"
    private var myPeerId: MCPeerID!
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    
    private var foundPeers: [MCPeerID: NearbyUser] = [:]
    private var onUsersFound: (([NearbyUser]) -> Void)?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        let displayName = Auth.auth().currentUser?.uid ?? UUID().uuidString
        myPeerId = MCPeerID(displayName: String(displayName.prefix(63)))
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }
    
    func startAdvertising() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let discoveryInfo: [String: String] = [
            "userId": uid,
            "displayName": UserDefaults.standard.string(forKey: "user_displayName") ?? "VibeU User"
        ]
        
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: discoveryInfo, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }
    
    func startBrowsing(onFound: @escaping ([NearbyUser]) -> Void) {
        self.onUsersFound = onFound
        
        browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
        
        // Also start advertising so we can be found
        startAdvertising()
        
        // Stop after 30 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            self?.stopBrowsing()
            self?.stopAdvertising()
        }
    }
    
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
    }
    
    func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
    }
}

// MARK: - MCSessionDelegate
extension NearbyService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // Handle state changes
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension NearbyService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {}
}

// MARK: - MCNearbyServiceBrowserDelegate
extension NearbyService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if let info = info, let userId = info["userId"], let displayName = info["displayName"] {
            let nearbyUser = NearbyUser(id: userId, displayName: displayName, profilePhotoURL: nil, peerId: peerID)
            foundPeers[peerID] = nearbyUser
            
            DispatchQueue.main.async {
                self.onUsersFound?(Array(self.foundPeers.values))
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        foundPeers.removeValue(forKey: peerID)
        DispatchQueue.main.async {
            self.onUsersFound?(Array(self.foundPeers.values))
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {}
}
import SwiftUI
import CoreImage.CIFilterBuiltins

struct ProfileQRCard: View {
    let user: User? // or DiscoverUser, depending on usage. Using optional generic data for V1
    let qrImage: UIImage?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 24) {
            // Header: Avatar & Info
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(LinearGradient(colors: [.cyan, .purple], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                        .frame(width: 90, height: 90)
                    
                    // Profile Photo Logic Placeholder - would normally pass image or URL
                    // For now using placeholder logic matching original view
                    Circle().fill(Color.gray.opacity(0.2))
                        .frame(width: 82, height: 82)
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.gray)
                        }
                }
                
                VStack(spacing: 4) {
                    Text(UserDefaults.standard.string(forKey: ProfileKeys.displayName) ?? appState.currentUser?.displayName ?? "Kullanıcı")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text("@\(appState.currentUser?.username ?? "username")")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(colorScheme == .dark ? .gray : .secondary)
                }
            }
            
            Divider()
            
            // QR Code
            VStack(spacing: 16) {
                if let qr = qrImage {
                    Image(uiImage: qr)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .overlay { ProgressView() }
                }
                
                Text("Tarat ve Bağlan")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1), in: Capsule())
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
