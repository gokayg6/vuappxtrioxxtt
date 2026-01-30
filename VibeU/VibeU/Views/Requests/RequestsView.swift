import SwiftUI

struct RequestsView: View {
    @State private var viewModel = RequestsViewModel()
    @State private var selectedSegment: RequestSegment = .received
    @Namespace private var segmentAnimation
    
    enum RequestSegment: String, CaseIterable {
        case received
        case sent
        case friends
        
        var title: String {
            switch self {
            case .received: return "Gelen"
            case .sent: return "Giden"
            case .friends: return "Arkadaşlar"
            }
        }
        
        var icon: String {
            switch self {
            case .received: return "tray.and.arrow.down.fill"
            case .sent: return "paperplane.fill"
            case .friends: return "person.2.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Premium Segment Bar
                PremiumSegmentBar(
                    selectedSegment: $selectedSegment,
                    namespace: segmentAnimation,
                    counts: [
                        .received: viewModel.count(for: .received),
                        .sent: viewModel.count(for: .sent),
                        .friends: viewModel.count(for: .friends)
                    ]
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                // Content
                TabView(selection: $selectedSegment) {
                    PremiumReceivedContent(
                        requests: viewModel.receivedRequests,
                        isLoading: viewModel.isLoading,
                        onAccept: { viewModel.acceptRequest($0) },
                        onReject: { viewModel.rejectRequest($0) }
                    )
                    .tag(RequestSegment.received)
                    
                    PremiumSentContent(
                        requests: viewModel.sentRequests,
                        isLoading: viewModel.isLoading
                    )
                    .tag(RequestSegment.sent)
                    
                    PremiumFriendsContent(
                        friends: viewModel.friends,
                        isLoading: viewModel.isLoading,
                        onRemove: { viewModel.removeFriend($0) }
                    )
                    .tag(RequestSegment.friends)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea())
            .navigationTitle("Bağlantılar")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - Premium Segment Bar (Tabbar Style)

struct PremiumSegmentBar: View {
    @Binding var selectedSegment: RequestsView.RequestSegment
    var namespace: Namespace.ID
    let counts: [RequestsView.RequestSegment: Int]
    
    private let segmentShape = Capsule()
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(RequestsView.RequestSegment.allCases, id: \.rawValue) { segment in
                PremiumSegmentButton(
                    segment: segment,
                    isSelected: selectedSegment == segment,
                    count: counts[segment] ?? 0,
                    namespace: namespace
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        selectedSegment = segment
                    }
                }
            }
        }
        .padding(5)
        .background(.regularMaterial, in: segmentShape)
        .glassEffect(.regular.interactive(), in: segmentShape)
    }
}

struct PremiumSegmentButton: View {
    let segment: RequestsView.RequestSegment
    let isSelected: Bool
    let count: Int
    var namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(segment.title)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(isSelected ? .purple : .white)
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(isSelected ? .white : .purple)
                        )
                }
            }
            .foregroundStyle(isSelected ? .white : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                if isSelected {
                    // Blob background with matchedGeometryEffect
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .matchedGeometryEffect(id: "segmentBlob", in: namespace)
                        .shadow(color: .purple.opacity(0.4), radius: 8, y: 4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Premium Empty State

struct PremiumEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple.opacity(0.6), .pink.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Premium Received Content

struct PremiumReceivedContent: View {
    let requests: [SocialRequest]
    let isLoading: Bool
    let onAccept: (SocialRequest) -> Void
    let onReject: (SocialRequest) -> Void
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .tint(.purple)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if requests.isEmpty {
                PremiumEmptyState(
                    icon: "tray",
                    title: "Henüz istek yok",
                    subtitle: "Yeni bağlantı istekleri burada görünecek"
                )
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(requests) { request in
                            PremiumRequestCard(
                                request: request,
                                onAccept: { onAccept(request) },
                                onReject: { onReject(request) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}


// MARK: - Premium Request Card

struct PremiumRequestCard: View {
    let request: SocialRequest
    let onAccept: () -> Void
    let onReject: () -> Void
    
    private let cardShape = RoundedRectangle(cornerRadius: 20, style: .continuous)
    
    var body: some View {
        HStack(spacing: 12) {
            // Premium Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.5), .pink.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                AsyncImage(url: URL(string: request.fromUser?.profilePhotoURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            }
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(request.fromUser?.displayName ?? "Kullanıcı")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    if let age = request.fromUser?.age {
                        Text("\(age)")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                HStack(spacing: 3) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 9))
                    Text(request.fromUser?.city ?? "")
                        .font(.system(size: 12))
                }
                .foregroundStyle(.white.opacity(0.4))
            }
            
            Spacer()
            
            // Premium Action Buttons
            HStack(spacing: 8) {
                // Reject - Liquid Glass
                Button(action: onReject) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.red)
                        .frame(width: 42, height: 42)
                        .background(.regularMaterial, in: Circle())
                        .glassEffect(.regular.interactive(), in: Circle())
                }
                .buttonStyle(.plain)
                
                // Accept - Gradient
                Button(action: onAccept) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: cardShape)
        .glassEffect(.regular.interactive(), in: cardShape)
    }
}

// MARK: - Premium Sent Content

struct PremiumSentContent: View {
    let requests: [SocialRequest]
    let isLoading: Bool
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .tint(.purple)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if requests.isEmpty {
                PremiumEmptyState(
                    icon: "paperplane",
                    title: "Gönderilen istek yok",
                    subtitle: "Gönderdiğin istekler burada görünecek"
                )
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(requests) { request in
                            PremiumSentCard(request: request)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct PremiumSentCard: View {
    let request: SocialRequest
    
    private let cardShape = RoundedRectangle(cornerRadius: 20, style: .continuous)
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AsyncImage(url: URL(string: request.toUser?.profilePhotoURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Circle()
                    .fill(.white.opacity(0.1))
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.white.opacity(0.3))
                    }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(request.toUser?.displayName ?? "Kullanıcı")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(request.toUser?.city ?? "")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            Spacer()
            
            // Status Badge
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
                Text(statusText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(statusColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusColor.opacity(0.15), in: Capsule())
        }
        .padding(14)
        .background(.ultraThinMaterial, in: cardShape)
        .glassEffect(.regular.interactive(), in: cardShape)
    }
    
    private var statusText: String {
        switch request.status {
        case .pending: return "Bekliyor"
        case .accepted: return "Kabul Edildi"
        case .rejected: return "Reddedildi"
        case .cancelled: return "İptal"
        }
    }
    
    private var statusColor: Color {
        switch request.status {
        case .pending: return .orange
        case .accepted: return .green
        case .rejected: return .red
        case .cancelled: return .gray
        }
    }
}

// MARK: - Premium Friends Content

struct PremiumFriendsContent: View {
    let friends: [Friendship]
    let isLoading: Bool
    let onRemove: (Friendship) -> Void
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .tint(.purple)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if friends.isEmpty {
                PremiumEmptyState(
                    icon: "person.2",
                    title: "Henüz arkadaş yok",
                    subtitle: "Bağlantı isteklerini kabul ederek arkadaş edin"
                )
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(friends) { friendship in
                            PremiumFriendCard(
                                friendship: friendship,
                                onRemove: { onRemove(friendship) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct PremiumFriendCard: View {
    let friendship: Friendship
    let onRemove: () -> Void
    
    @State private var showActions = false
    
    private let cardShape = RoundedRectangle(cornerRadius: 20, style: .continuous)
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar with online indicator
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if !friendship.friend.profilePhotoURL.isEmpty, let url = URL(string: friendship.friend.profilePhotoURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(.white.opacity(0.1))
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                        }
                    } else {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .overlay {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                // Online dot
                if isOnline {
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                        .overlay {
                            Circle()
                                .stroke(Color(red: 0.04, green: 0.02, blue: 0.08), lineWidth: 2)
                        }
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(friendship.friend.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(isOnline ? .green : .gray)
                        .frame(width: 5, height: 5)
                    Text(isOnline ? "Çevrimiçi" : timeAgo)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            
            Spacer()
            
            // Social Links
            if let socialLinks = friendship.friend.socialLinks {
                HStack(spacing: 6) {
                    if socialLinks.instagram != nil {
                        PremiumSocialIcon(platform: .instagram, size: 32)
                    }
                    if socialLinks.snapchat != nil {
                        PremiumSocialIcon(platform: .snapchat, size: 32)
                    }
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: cardShape)
        .glassEffect(.regular.interactive(), in: cardShape)
        .contextMenu {
            Button(role: .destructive, action: onRemove) {
                Label("Arkadaşlıktan Çıkar", systemImage: "person.badge.minus")
            }
        }
    }
    
    private var isOnline: Bool {
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        return friendship.friend.lastActiveAt > fiveMinutesAgo
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.localizedString(for: friendship.friend.lastActiveAt, relativeTo: Date())
    }
}

// MARK: - Premium Social Icon

struct PremiumSocialIcon: View {
    enum Platform {
        case instagram, snapchat
    }
    
    let platform: Platform
    let size: CGFloat
    
    var body: some View {
        Button {
            // Open social link
        } label: {
            Image(platform == .instagram ? "InstagramIcon" : "SnapchatIcon")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RequestsView()
}
