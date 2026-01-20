import SwiftUI
import CoreImage.CIFilterBuiltins

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
                    
                    // MARK: - ID Card Design
                    VStack(spacing: 24) {
                        // Header: Avatar & Info
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(LinearGradient(colors: [.cyan, .purple], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                                    .frame(width: 90, height: 90)
                                
                                if let photo = profilePhoto {
                                    Image(uiImage: photo)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 82, height: 82)
                                        .clipShape(Circle())
                                } else {
                                    Circle().fill(colors.secondaryBackground)
                                        .frame(width: 82, height: 82)
                                        .overlay {
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 32))
                                                .foregroundStyle(colors.tertiaryText)
                                        }
                                }
                            }
                            
                            VStack(spacing: 4) {
                                Text(UserDefaults.standard.string(forKey: ProfileKeys.displayName) ?? appState.currentUser?.displayName ?? "Kullanıcı")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(colors.primaryText)
                                
                                Text("@\(appState.currentUser?.username ?? "username")")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(colors.secondaryText)
                            }
                        }
                        
                        Divider()
                            .background(colors.border)
                        
                        // QR Code
                        VStack(spacing: 16) {
                            if let qr = qrImageWithLogo ?? qrImage {
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
                                    .fill(colors.secondaryBackground)
                                    .frame(width: 200, height: 200)
                                    .overlay { ProgressView() }
                            }
                            
                            Text("Tarat ve Bağlan")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(colors.secondaryText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(colors.secondaryBackground, in: Capsule())
                        }
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(colors.cardBackground)
                            .shadow(color: Color.black.opacity(isDark ? 0.3 : 0.05), radius: 20, x: 0, y: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(colors.border.opacity(0.5), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // MARK: - Share Section
                    VStack(spacing: 20) {
                        Text("Hikayende Paylaş")
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
                                Text("Paylaş")
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
                                Text("Kaydet")
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
        .navigationTitle("QR Profilim")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
        .onAppear {
            generateQR()
            loadProfilePhoto()
        }
        .alert("Kaydedildi ✓", isPresented: $showSavedAlert) {
            Button("Tamam") { }
        } message: {
            Text("QR kod fotoğraflarına kaydedildi.")
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
        let userId = appState.currentUser?.id ?? UserDefaults.standard.string(forKey: "current_user_id") ?? UUID().uuidString
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
