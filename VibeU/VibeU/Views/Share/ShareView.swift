import SwiftUI
import CoreImage.CIFilterBuiltins
import AVFoundation
import FirebaseAuth
import Photos

// MARK: - Share View (Liquid Glass Design - iOS 26)
struct ShareView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppState.self) private var appState
    
    // State
    @State private var qrImage: UIImage?
    @State private var showScanner = false
    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    @State private var isSearchingNearby = false
    @State private var nearbyUsers: [NearbyDiscoveryUser] = []
    @State private var scannedUserId: String?
    @State private var showProfileSheet = false
    @State private var shareImage: UIImage?
    
    private var isDark: Bool { colorScheme == .dark }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - QR Kod Kartı
                    qrCardSection
                    
                    // MARK: - Aksiyon Butonları
                    actionButtonsSection
                    
                    // MARK: - Bağlantı Seçenekleri
                    connectionOptionsSection
                    
                    // MARK: - Yakındaki Kullanıcılar
                    if !nearbyUsers.isEmpty {
                        nearbyUsersSection
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(backgroundGradient)
            .navigationTitle("Paylaş")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(isDark ? .white.opacity(0.7) : .black.opacity(0.5))
                    }
                }
            }
            .onAppear {
                generateQRCode()
            }
            .fullScreenCover(isPresented: $showScanner) {
                QRScannerOverlay(onDismiss: { showScanner = false }) { userId in
                    scannedUserId = userId
                    showScanner = false
                    showProfileSheet = true
                }
            }
            .sheet(isPresented: $showProfileSheet) {
                if let userId = scannedUserId {
                    ScannedProfileSheet(userId: userId)
                }
            }
            .alert("Kaydedildi! ✅", isPresented: $showSaveSuccess) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text("QR kodunuz galeriye kaydedildi.")
            }
            .alert("Hata", isPresented: $showSaveError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text("Kaydetme sırasında bir hata oluştu.")
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            (isDark ? Color.black : Color(UIColor.systemBackground))
                .ignoresSafeArea()
            
            // Subtle gradient orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 60)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.cyan.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 350, height: 350)
                .blur(radius: 50)
                .offset(x: 120, y: 200)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Profilini Paylaş")
                .font(.title2.bold())
                .foregroundStyle(isDark ? .white : .black)
            
            Text("QR kodunu taratarak veya yakındaki kişileri bularak bağlan")
                .font(.subheadline)
                .foregroundStyle(isDark ? .white.opacity(0.6) : .black.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - QR Card Section
    private var qrCardSection: some View {
        VStack(spacing: 20) {
            // User Info Row
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.3), .cyan.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    if let photoURL = appState.currentUser?.profilePhotoURL,
                       let url = URL(string: photoURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.fill")
                                .font(.title2)
                                .foregroundStyle(.gray)
                        }
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.currentUser?.displayName ?? "Kullanıcı")
                        .font(.headline)
                        .foregroundStyle(isDark ? .white : .black)
                    
                    Text("@\(appState.currentUser?.username ?? "kullanici")")
                        .font(.subheadline)
                        .foregroundStyle(isDark ? .white.opacity(0.6) : .black.opacity(0.6))
                }
                
                Spacer()
                
                // VibeU Badge
                Text("VibeU")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [.purple, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
            }
            
            // QR Code
            if let qr = qrImage {
                Image(uiImage: qr)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                ProgressView()
                    .frame(width: 200, height: 200)
            }
            
            // Link Preview
            HStack(spacing: 6) {
                Image(systemName: "link")
                    .font(.caption)
                Text("vibeu://profile/\(appState.currentUser?.id ?? "...")")
                    .font(.caption)
                    .lineLimit(1)
            }
            .foregroundStyle(isDark ? .white.opacity(0.5) : .black.opacity(0.5))
        }
        .padding(24)
        .glassEffect()
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        HStack(spacing: 14) {
            // Kaydet Button
            Button {
                saveQRToGallery()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.body.bold())
                    Text("Kaydet")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.purple, .purple.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
            }
            .glassEffect()
            
            // Paylaş Button
            Button {
                shareQR()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.bold())
                    Text("Paylaş")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.cyan, .cyan.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
            }
            .glassEffect()
        }
    }
    
    // MARK: - Connection Options
    private var connectionOptionsSection: some View {
        VStack(spacing: 12) {
            Text("Bağlan")
                .font(.headline)
                .foregroundStyle(isDark ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // QR Tara Button
            Button {
                showScanner = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("QR Kod Tara")
                            .font(.headline)
                            .foregroundStyle(isDark ? .white : .black)
                        
                        Text("Arkadaşının kodunu tara")
                            .font(.caption)
                            .foregroundStyle(isDark ? .white.opacity(0.6) : .black.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.body.bold())
                        .foregroundStyle(isDark ? .white.opacity(0.4) : .black.opacity(0.4))
                }
                .padding(16)
                .glassEffect()
            }
            .buttonStyle(.plain)
            
            // Yakındakileri Bul Button
            Button {
                findNearbyUsers()
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        
                        if isSearchingNearby {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Yakındakileri Bul")
                            .font(.headline)
                            .foregroundStyle(isDark ? .white : .black)
                        
                        Text("AirDrop ile bağlan")
                            .font(.caption)
                            .foregroundStyle(isDark ? .white.opacity(0.6) : .black.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.body.bold())
                        .foregroundStyle(isDark ? .white.opacity(0.4) : .black.opacity(0.4))
                }
                .padding(16)
                .glassEffect()
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Nearby Users Section
    private var nearbyUsersSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Yakındaki Kişiler")
                    .font(.headline)
                    .foregroundStyle(isDark ? .white : .black)
                
                Spacer()
                
                Text("\(nearbyUsers.count) kişi")
                    .font(.caption)
                    .foregroundStyle(isDark ? .white.opacity(0.6) : .black.opacity(0.6))
            }
            
            ForEach(nearbyUsers) { user in
                nearbyUserRow(user)
            }
        }
        .padding(16)
        .glassEffect()
    }
    
    private func nearbyUserRow(_ user: NearbyDiscoveryUser) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.5), .cyan.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .overlay {
                    Text(String(user.displayName.prefix(1)).uppercased())
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(isDark ? .white : .black)
                
                Text("Yakında")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            
            Spacer()
            
            Button {
                sendFriendRequest(to: user)
            } label: {
                Text("Ekle")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [.purple, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Functions
    
    private func generateQRCode() {
        guard let userId = appState.currentUser?.id else { return }
        let profileLink = "vibeu://profile/\(userId)"
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        let data = Data(profileLink.utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        if let output = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledOutput = output.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledOutput, from: scaledOutput.extent) {
                qrImage = UIImage(cgImage: cgImage)
            }
        }
    }
    
    private func saveQRToGallery() {
        guard let qr = qrImage else {
            showSaveError = true
            return
        }
        
        // Create composite image with user info
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 500))
        let compositeImage = renderer.image { ctx in
            // White background
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 400, height: 500))
            
            // Draw QR
            qr.draw(in: CGRect(x: 50, y: 50, width: 300, height: 300))
            
            // Draw text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            let name = appState.currentUser?.displayName ?? "VibeU User"
            name.draw(with: CGRect(x: 0, y: 370, width: 400, height: 30), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            
            let subAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.gray,
                .paragraphStyle: paragraphStyle
            ]
            
            "VibeU ile bağlan".draw(with: CGRect(x: 0, y: 410, width: 400, height: 25), options: .usesLineFragmentOrigin, attributes: subAttrs, context: nil)
        }
        
        // Save to gallery
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized || status == .limited {
                UIImageWriteToSavedPhotosAlbum(compositeImage, nil, nil, nil)
                DispatchQueue.main.async {
                    showSaveSuccess = true
                }
            } else {
                DispatchQueue.main.async {
                    showSaveError = true
                }
            }
        }
    }
    
    private func shareQR() {
        guard let qr = qrImage else { return }
        
        let activityVC = UIActivityViewController(activityItems: [qr], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func findNearbyUsers() {
        isSearchingNearby = true
        
        // Simulate finding nearby users (replace with actual NearbyService)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isSearchingNearby = false
            // Demo data - in real app, use NearbyService
            nearbyUsers = [
                NearbyDiscoveryUser(id: "1", displayName: "Ayşe", profilePhotoURL: nil),
                NearbyDiscoveryUser(id: "2", displayName: "Mehmet", profilePhotoURL: nil)
            ]
        }
    }
    
    private func sendFriendRequest(to user: NearbyDiscoveryUser) {
        Task {
            do {
                try await FriendsService.shared.sendFriendRequest(userId: user.id)
                await MainActor.run {
                    // Remove from list after sending
                    nearbyUsers.removeAll { $0.id == user.id }
                }
            } catch {
                print("❌ Friend request failed: \(error)")
            }
        }
    }
}

// MARK: - Nearby Discovery User Model
struct NearbyDiscoveryUser: Identifiable {
    let id: String
    let displayName: String
    let profilePhotoURL: String?
}

// MARK: - Scanned Profile Sheet
struct ScannedProfileSheet: View {
    let userId: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var user: DiscoverUser?
    @State private var isLoading = true
    @State private var requestSent = false
    
    private var isDark: Bool { colorScheme == .dark }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let user = user {
                    // Found User UI
                    VStack(spacing: 16) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            if let url = URL(string: user.profilePhotoURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 92, height: 92)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        Text(user.displayName)
                            .font(.title2.bold())
                            .foregroundStyle(isDark ? .white : .black)
                        
                        Text("\(user.age) • \(user.city)")
                            .font(.subheadline)
                            .foregroundStyle(isDark ? .white.opacity(0.6) : .black.opacity(0.6))
                        
                        if requestSent {
                            Label("İstek Gönderildi", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.green)
                                .padding()
                        } else {
                            Button {
                                sendRequest()
                            } label: {
                                Text("Arkadaş Olarak Ekle")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [.purple, .cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 16)
                                    )
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .glassEffect()
                    .padding()
                } else {
                    // User not found
                    VStack(spacing: 12) {
                        Image(systemName: "person.slash")
                            .font(.system(size: 60))
                            .foregroundStyle(.red)
                        
                        Text("Kullanıcı Bulunamadı")
                            .font(.title2.bold())
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isDark ? Color.black : Color(UIColor.systemBackground))
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadUser()
            }
        }
    }
    
    private func loadUser() {
        Task {
            do {
                if let fetchedUser = try await UserService.shared.fetchUser(uid: userId) {
                    await MainActor.run {
                        user = DiscoverUser(
                            id: fetchedUser.id,
                            displayName: fetchedUser.displayName,
                            age: fetchedUser.age,
                            city: fetchedUser.city,
                            country: nil,
                            countryFlag: nil,
                            distanceKm: 0,
                            profilePhotoURL: fetchedUser.profilePhotoURL ?? "",
                            photos: [],
                            tags: [],
                            commonInterests: [],
                            score: 0,
                            isBoosted: false,
                            tiktokUsername: nil,
                            instagramUsername: nil,
                            snapchatUsername: nil,
                            isFriend: false,
                            bio: nil
                        )
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func sendRequest() {
        Task {
            do {
                try await FriendsService.shared.sendFriendRequest(userId: userId)
                await MainActor.run {
                    withAnimation {
                        requestSent = true
                    }
                }
            } catch {
                print("❌ Failed to send request: \(error)")
            }
        }
    }
}

// MARK: - QR Scanner Overlay
struct QRScannerOverlay: View {
    let onDismiss: () -> Void
    let onScanned: (String) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var cameraPermissionDenied = false
    
    var body: some View {
        ZStack {
            // Camera View
            CameraPreviewView(onScanned: onScanned, onPermissionDenied: {
                cameraPermissionDenied = true
            })
            .ignoresSafeArea()
            
            // Overlay
            VStack {
                // Top Bar
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Scan Frame
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 250, height: 250)
                    
                    // Corner accents
                    QRCornerAccents()
                        .frame(width: 250, height: 250)
                    
                    // Scanning line animation
                    ScanningLineView()
                        .frame(width: 230)
                }
                
                Spacer()
                
                // Instructions
                VStack(spacing: 8) {
                    Text("QR Kodu Tara")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Text("Arkadaşının VibeU QR kodunu çerçeveye yerleştir")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
            
            // Permission Denied
            if cameraPermissionDenied {
                VStack(spacing: 20) {
                    Image(systemName: "camera.slash")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                    
                    Text("Kamera İzni Gerekli")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Text("QR kod taramak için kamera iznini ayarlardan etkinleştirin.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Ayarlara Git")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 14)
                            .background(.white, in: Capsule())
                    }
                    
                    Button("Kapat") {
                        onDismiss()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.9))
            }
        }
    }
}

// MARK: - Camera Preview
struct CameraPreviewView: UIViewRepresentable {
    let onScanned: (String) -> Void
    let onPermissionDenied: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        context.coordinator.setupCamera(in: view, onScanned: onScanned, onPermissionDenied: onPermissionDenied)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        var onScanned: ((String) -> Void)?
        var hasScanned = false
        
        func setupCamera(in view: UIView, onScanned: @escaping (String) -> Void, onPermissionDenied: @escaping () -> Void) {
            self.onScanned = onScanned
            
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                DispatchQueue.main.async {
                    self.configureCamera(in: view)
                }
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            self.configureCamera(in: view)
                        } else {
                            onPermissionDenied()
                        }
                    }
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    onPermissionDenied()
                }
            @unknown default:
                break
            }
        }
        
        private func configureCamera(in view: UIView) {
            let session = AVCaptureSession()
            
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else { return }
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            let output = AVCaptureMetadataOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: .main)
                output.metadataObjectTypes = [.qr]
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            self.previewLayer = previewLayer
            self.captureSession = session
            
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
            
            // Update frame on layout change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                previewLayer.frame = view.bounds
            }
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard !hasScanned,
                  let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  metadataObject.type == .qr,
                  let stringValue = metadataObject.stringValue else { return }
            
            hasScanned = true
            
            // Parse vibeu://profile/{userId}
            if stringValue.hasPrefix("vibeu://profile/") {
                let userId = String(stringValue.dropFirst("vibeu://profile/".count))
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                onScanned?(userId)
            }
        }
    }
}

// MARK: - QR Corner Accents
struct QRCornerAccents: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cornerSize: CGFloat = 30
            let lineWidth: CGFloat = 4
            
            ZStack {
                // Top-left
                Path { path in
                    path.move(to: CGPoint(x: 0, y: cornerSize))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: cornerSize, y: 0))
                }
                .stroke(Color.cyan, lineWidth: lineWidth)
                
                // Top-right
                Path { path in
                    path.move(to: CGPoint(x: w - cornerSize, y: 0))
                    path.addLine(to: CGPoint(x: w, y: 0))
                    path.addLine(to: CGPoint(x: w, y: cornerSize))
                }
                .stroke(Color.cyan, lineWidth: lineWidth)
                
                // Bottom-left
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h - cornerSize))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.addLine(to: CGPoint(x: cornerSize, y: h))
                }
                .stroke(Color.cyan, lineWidth: lineWidth)
                
                // Bottom-right
                Path { path in
                    path.move(to: CGPoint(x: w - cornerSize, y: h))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: w, y: h - cornerSize))
                }
                .stroke(Color.cyan, lineWidth: lineWidth)
            }
        }
    }
}

// MARK: - Scanning Line Animation
struct ScanningLineView: View {
    @State private var offset: CGFloat = -100
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .cyan, .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = 100
                }
            }
    }
}

#Preview {
    ShareView()
        .environment(AppState())
}
