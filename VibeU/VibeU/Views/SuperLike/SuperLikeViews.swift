import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - SuperLike Service
actor SuperLikeService {
    static let shared = SuperLikeService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Get SuperLike Count
    func getSuperLikeCount() async throws -> Int {
        guard let uid = Auth.auth().currentUser?.uid else { return 0 }
        
        let doc = try await db.collection("users").document(uid).getDocument()
        return doc.data()?["superlike_count"] as? Int ?? 0
    }
    
    // MARK: - Use SuperLike
    func useSuperLike(targetUserId: String) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        let userRef = db.collection("users").document(uid)
        
        // Transaction to ensure atomic update
        let success = try await db.runTransaction { (transaction, errorPointer) -> Bool in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return false
            }
            
            let data = snapshot.data() ?? [:]
            let isPremium = data["isPremium"] as? Bool ?? false
            let currentCount = data["superlike_count"] as? Int ?? 0
            
            // If premium, unlimited superlikes (don't deduct)
            if isPremium {
                return true
            }
            
            guard currentCount > 0 else {
                return false // No superlikes available
            }
            
            // Deduct one superlike
            transaction.updateData([
                "superlike_count": currentCount - 1
            ], forDocument: userRef)
            
            return true
        }
        
        if success {
            // Log the superlike
            try await db.collection("superlikes").addDocument(data: [
                "fromUserId": uid,
                "toUserId": targetUserId,
                "createdAt": FieldValue.serverTimestamp()
            ])
            
            // Also create a "like" entry
            try await db.collection("likes").addDocument(data: [
                "fromUserId": uid,
                "toUserId": targetUserId,
                "type": "superlike",
                "createdAt": FieldValue.serverTimestamp()
            ])
            
            print("⭐ [SuperLikeService] SuperLike sent to \(targetUserId)")
        }
        
        return success
    }
    
    // MARK: - Check if Match
    func checkForMatch(withUserId: String) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        // Check if the other user has liked us
        let query = db.collection("likes")
            .whereField("fromUserId", isEqualTo: withUserId)
            .whereField("toUserId", isEqualTo: uid)
        
        let snapshot = try await query.getDocuments()
        return !snapshot.documents.isEmpty
    }
    
    // MARK: - Get Boost Count
    func getBoostCount() async throws -> Int {
        guard let uid = Auth.auth().currentUser?.uid else { return 0 }
        
        let doc = try await db.collection("users").document(uid).getDocument()
        return doc.data()?["boost_count"] as? Int ?? 0
    }
    
    // MARK: - Use Boost
    func useBoost() async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        let userRef = db.collection("users").document(uid)
        
        let success = try await db.runTransaction { (transaction, errorPointer) -> Bool in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return false
            }
            
            let data = snapshot.data() ?? [:]
            let isPremium = data["isPremium"] as? Bool ?? false
            let currentCount = data["boost_count"] as? Int ?? 0
            
            // Premium users get 1 free boost per week (logic can be complex, for now deduct if not unlimited policy)
            // Or if user wants premium to have everything unlocked:
            if isPremium {
                 // For boosts, usually even premium has limits or timeouts. 
                 // Let's assume premium users have unlimited boosts or daily boosts.
                 // For now, let's keep boost logic as credit-based but maybe give premium free boosts.
                 // If user said "premium alınca bütün özellikler açılsın", maybe boost is free?
                 // Let's stick to credit for boost to avoid spam, but superlike is unlimited.
            }
            
            guard currentCount > 0 else { return false }
            
            transaction.updateData([
                "boost_count": currentCount - 1,
                "boosted_until": Timestamp(date: Date().addingTimeInterval(30 * 60)) // 30 min boost
            ], forDocument: userRef)
            
            return true
        }
        
        if success {
            print("🚀 [SuperLikeService] Boost activated!")
        }
        
        return success
    }
    
    // MARK: - Purchase Functions
    func purchaseSuperLikes(amount: Int, price: Int) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        let userRef = db.collection("users").document(uid)
        
        return try await db.runTransaction { (transaction, errorPointer) -> Bool in
            guard let snapshot = try? transaction.getDocument(userRef),
                  let data = snapshot.data(),
                  let currentDiamonds = data["diamond_balance"] as? Int,
                  currentDiamonds >= price else { return false }
            
            let currentSuperLikes = data["superlike_count"] as? Int ?? 0
            
            transaction.updateData([
                "diamond_balance": currentDiamonds - price,
                "superlike_count": currentSuperLikes + amount
            ], forDocument: userRef)
            
            return true
        }
    }
    
    func purchaseBoost(amount: Int, price: Int) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        let userRef = db.collection("users").document(uid)
        
        return try await db.runTransaction { (transaction, errorPointer) -> Bool in
            guard let snapshot = try? transaction.getDocument(userRef),
                  let data = snapshot.data(),
                  let currentDiamonds = data["diamond_balance"] as? Int,
                  currentDiamonds >= price else { return false }
            
            let currentBoosts = data["boost_count"] as? Int ?? 0
            
            transaction.updateData([
                "diamond_balance": currentDiamonds - price,
                "boost_count": currentBoosts + amount
            ], forDocument: userRef)
            
            return true
        }
    }
}

// MARK: - Match Screen (Eşleştiniz Ekranı)
struct MatchScreen: View {
    let matchedUser: DiscoverUser
    let onDismiss: () -> Void
    let onSendMessage: () -> Void
    let onSendRequest: () -> Void
    
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.purple.opacity(0.8), .pink.opacity(0.8), .orange.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 24) {
                Spacer()
                
                // Match Title
                VStack(spacing: 8) {
                    Text("🎉")
                        .font(.system(size: 60))
                    
                    Text("Eşleştiniz!")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("\(matchedUser.displayName) seni beğendi!")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                Spacer()
                
                // User Cards
                HStack(spacing: -30) {
                    // Your photo placeholder
                    Circle()
                        .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.white)
                        )
                        .overlay(Circle().stroke(.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.3), radius: 10)
                    
                    // Matched user photo
                    CachedAsyncImage(url: URL(string: matchedUser.profilePhotoURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 4))
                    .shadow(color: .black.opacity(0.3), radius: 10)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    // Send Request Button
                    Button {
                        onSendRequest()
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Arkadaşlık İsteği Gönder")
                        }
                        .font(.headline)
                        .foregroundStyle(.purple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 10)
                    }
                    
                    // Continue Button
                    Button {
                        onDismiss()
                    } label: {
                        Text("Devam Et")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
            
            // Haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, color: Color, rotation: Double)] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles, id: \.id) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: 10, height: 10)
                        .position(x: particle.x, y: particle.y)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .onAppear {
                createParticles(in: geo.size)
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        
        for i in 0..<50 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                let particle = (
                    id: i,
                    x: CGFloat.random(in: 0...size.width),
                    y: -20.0,
                    color: colors.randomElement()!,
                    rotation: Double.random(in: 0...360)
                )
                particles.append(particle)
                
                // Animate falling
                withAnimation(.easeIn(duration: 2)) {
                    if let index = particles.firstIndex(where: { $0.id == i }) {
                        particles[index].y = size.height + 20
                        particles[index].rotation += Double.random(in: 180...720)
                    }
                }
            }
        }
    }
}

// MARK: - SuperLike Purchase Sheet
struct SuperLikePurchaseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var superlikeCount = 0
    @State private var boostCount = 0
    @State private var diamondBalance = 0
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? Color.black : Color.white).ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Current Balance
                            HStack(spacing: 40) {
                                VStack {
                                    Image(systemName: "star.fill")
                                        .font(.title)
                                        .foregroundStyle(.yellow)
                                    Text("\(superlikeCount)")
                                        .font(.title2.bold())
                                    Text("SuperLike")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                VStack {
                                    Image(systemName: "bolt.fill")
                                        .font(.title)
                                        .foregroundStyle(.purple)
                                    Text("\(boostCount)")
                                        .font(.title2.bold())
                                    Text("Boost")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                VStack {
                                    Image(systemName: "sparkles")
                                        .font(.title)
                                        .foregroundStyle(.cyan)
                                    Text("\(diamondBalance)")
                                        .font(.title2.bold())
                                    Text("Elmas")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            // Purchase Options
                            VStack(spacing: 16) {
                                Text("Elmasla Satın Al")
                                    .font(.headline)
                                
                                // SuperLike Package
                                purchaseRow(
                                    icon: "star.fill",
                                    color: .yellow,
                                    title: "3 SuperLike",
                                    price: "150 💎"
                                ) {
                                    Task { await buyItem(type: .superlike, amount: 3, price: 150) }
                                }
                                
                                purchaseRow(
                                    icon: "star.fill",
                                    color: .yellow,
                                    title: "10 SuperLike",
                                    price: "400 💎"
                                ) {
                                    Task { await buyItem(type: .superlike, amount: 10, price: 400) }
                                }
                                
                                // Boost Package
                                purchaseRow(
                                    icon: "bolt.fill",
                                    color: .purple,
                                    title: "1 Boost (30 dk)",
                                    price: "100 💎"
                                ) {
                                    Task { await buyItem(type: .boost, amount: 1, price: 100) }
                                }
                            }
                            .padding()
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("SuperLike & Boost")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert("Satın Alma", isPresented: $showAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .task {
            await loadData()
        }
    }
    
    private func purchaseRow(icon: String, color: Color, title: String, price: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                Text(price)
                    .font(.subheadline.bold())
                    .foregroundStyle(.cyan)
            }
            .padding()
            .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    enum ItemType { case superlike, boost }
    
    private func buyItem(type: ItemType, amount: Int, price: Int) async {
        guard diamondBalance >= price else {
            alertMessage = "Yetersiz elmas! Lütfen önce elmas yükleyin."
            showAlert = true
            return
        }
        
        isLoading = true
        
        do {
            let success: Bool
            switch type {
            case .superlike:
                success = try await SuperLikeService.shared.purchaseSuperLikes(amount: amount, price: price)
            case .boost:
                success = try await SuperLikeService.shared.purchaseBoost(amount: amount, price: price)
            }
            
            if success {
                alertMessage = "Satın alma başarılı! 🎉"
                await loadData()
            } else {
                alertMessage = "Bir hata oluştu. Lütfen tekrar deneyin."
            }
        } catch {
            alertMessage = "Hata: \(error.localizedDescription)"
        }
        
        showAlert = true
        isLoading = false
    }
    
    private func loadData() async {
        do {
            superlikeCount = try await SuperLikeService.shared.getSuperLikeCount()
            boostCount = try await SuperLikeService.shared.getBoostCount()
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let doc = try await Firestore.firestore().collection("users").document(uid).getDocument()
            diamondBalance = doc.data()?["diamond_balance"] as? Int ?? 0
        } catch {
            print("Error loading data: \(error)")
        }
        isLoading = false
    }
}
