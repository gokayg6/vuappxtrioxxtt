import SwiftUI

struct NotificationsView: View {
    @State private var viewModel = NotificationsViewModel()
    @State private var selectedFilter: NotificationFilter = .all
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    private var isLight: Bool { appState.currentTheme == .light }
    
    var body: some View {
        ZStack {
            // Background
            if isLight {
                Color(red: 0.96, green: 0.96, blue: 0.98).ignoresSafeArea()
            } else {
                PremiumBackground()
            }
            
            VStack(spacing: 0) {
                // Filter Bar
                NotificationFilterBar(selectedFilter: $selectedFilter, isLight: isLight)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                // Content
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    NotificationSkeletonView(isLight: isLight)
                } else if filteredNotifications.isEmpty {
                    EmptyNotificationsView(isLight: isLight)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            // Today Section
                            if !todayNotifications.isEmpty {
                                NotificationSection(
                                    title: "Bugün",
                                    notifications: todayNotifications,
                                    isLight: isLight,
                                    onTap: viewModel.handleTap,
                                    onMarkRead: viewModel.markAsRead
                                )
                            }
                            
                            // This Week Section
                            if !thisWeekNotifications.isEmpty {
                                NotificationSection(
                                    title: "Bu Hafta",
                                    notifications: thisWeekNotifications,
                                    isLight: isLight,
                                    onTap: viewModel.handleTap,
                                    onMarkRead: viewModel.markAsRead
                                )
                            }
                            
                            // Earlier Section
                            if !earlierNotifications.isEmpty {
                                NotificationSection(
                                    title: "Daha Önce",
                                    notifications: earlierNotifications,
                                    isLight: isLight,
                                    onTap: viewModel.handleTap,
                                    onMarkRead: viewModel.markAsRead
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        await viewModel.loadNotifications()
                    }
                }
            }
        }
        .navigationTitle("Bildirimler")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.hasUnread {
                    Button {
                        Task { await viewModel.markAllAsRead() }
                    } label: {
                        Text("Tümünü Oku")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.purple)
                    }
                }
            }
        }
        .task {
            await viewModel.loadNotifications()
        }
    }
    
    private var filteredNotifications: [AppNotification] {
        switch selectedFilter {
        case .all:
            return viewModel.notifications
        case .unread:
            return viewModel.notifications.filter { !$0.isRead }
        case .requests:
            return viewModel.notifications.filter { $0.type == .requestReceived || $0.type == .requestAccepted }
        case .friends:
            return viewModel.notifications.filter { $0.type == .newFriend }
        }
    }
    
    private var todayNotifications: [AppNotification] {
        filteredNotifications.filter { Calendar.current.isDateInToday($0.createdAt) }
    }
    
    private var thisWeekNotifications: [AppNotification] {
        filteredNotifications.filter {
            !Calendar.current.isDateInToday($0.createdAt) &&
            Calendar.current.isDate($0.createdAt, equalTo: Date(), toGranularity: .weekOfYear)
        }
    }
    
    private var earlierNotifications: [AppNotification] {
        filteredNotifications.filter {
            !Calendar.current.isDate($0.createdAt, equalTo: Date(), toGranularity: .weekOfYear)
        }
    }
}

// MARK: - Notification Filter

enum NotificationFilter: String, CaseIterable {
    case all = "Tümü"
    case unread = "Okunmamış"
    case requests = "İstekler"
    case friends = "Arkadaşlar"
    
    var icon: String {
        switch self {
        case .all: return "bell.fill"
        case .unread: return "circle.fill"
        case .requests: return "person.badge.plus"
        case .friends: return "person.2.fill"
        }
    }
}

struct NotificationFilterBar: View {
    @Binding var selectedFilter: NotificationFilter
    let isLight: Bool
    @Namespace private var animation
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NotificationFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedFilter = filter
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: filter.icon)
                                .font(.caption)
                            Text(filter.rawValue)
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(selectedFilter == filter ? .white : (isLight ? .black.opacity(0.6) : .white.opacity(0.6)))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background {
                            if selectedFilter == filter {
                                Capsule()
                                    .fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                                    .matchedGeometryEffect(id: "filter", in: animation)
                            } else {
                                Capsule()
                                    .fill(isLight ? Color.white : Color.white.opacity(0.1))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Notification Section

struct NotificationSection: View {
    let title: String
    let notifications: [AppNotification]
    let isLight: Bool
    let onTap: (AppNotification) -> Void
    let onMarkRead: (AppNotification) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(isLight ? .black.opacity(0.4) : .white.opacity(0.4))
                .padding(.leading, 4)
                .padding(.top, 8)
            
            ForEach(notifications) { notification in
                PremiumNotificationRow(
                    notification: notification,
                    isLight: isLight,
                    onTap: { onTap(notification) },
                    onMarkRead: { onMarkRead(notification) }
                )
            }
        }
    }
}

// MARK: - Premium Notification Row

struct PremiumNotificationRow: View {
    let notification: AppNotification
    let isLight: Bool
    let onTap: () -> Void
    let onMarkRead: () -> Void
    
    private let cardShape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Avatar or Icon
                ZStack {
                    if let avatarURL = notification.avatarURL {
                        AsyncImage(url: URL(string: avatarURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(iconColor.opacity(0.2))
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(iconColor.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: iconName)
                                    .font(.title3)
                                    .foregroundStyle(iconColor)
                            }
                    }
                    
                    // Type badge
                    Image(systemName: iconName)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(iconColor, in: Circle())
                        .overlay(Circle().stroke(isLight ? Color.white : Color(red: 0.04, green: 0.02, blue: 0.08), lineWidth: 2))
                        .offset(x: 18, y: 18)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.subheadline.weight(notification.isRead ? .regular : .semibold))
                        .foregroundStyle(isLight ? .black : .white)
                    
                    Text(notification.body)
                        .font(.caption)
                        .foregroundStyle(isLight ? .black.opacity(0.5) : .white.opacity(0.5))
                        .lineLimit(2)
                    
                    Text(timeAgo)
                        .font(.caption2)
                        .foregroundStyle(isLight ? .black.opacity(0.3) : .white.opacity(0.3))
                }
                
                Spacer()
                
                // Unread Indicator
                if !notification.isRead {
                    Circle()
                        .fill(
                            LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 10, height: 10)
                }
            }
            .padding(14)
            .background(
                notification.isRead ?
                (isLight ? Color.white : Color.white.opacity(0.03)) :
                (isLight ? Color.purple.opacity(0.05) : Color.purple.opacity(0.1)),
                in: cardShape
            )
            .overlay(
                cardShape.stroke(
                    isLight ? Color.black.opacity(0.05) : Color.white.opacity(0.05),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
        .shadow(color: isLight ? .black.opacity(0.03) : .clear, radius: 4, y: 2)
    }
    
    private var iconName: String {
        switch notification.type {
        case .requestReceived: return "person.badge.plus"
        case .requestAccepted: return "checkmark.circle.fill"
        case .newFriend: return "person.2.fill"
        case .boostExpired: return "bolt.slash.fill"
        case .premiumExpiring: return "crown.fill"
        case .system: return "bell.fill"
        }
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .requestReceived: return .purple
        case .requestAccepted: return .green
        case .newFriend: return .blue
        case .boostExpired: return .orange
        case .premiumExpiring: return .yellow
        case .system: return .gray
        }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: notification.createdAt, relativeTo: Date())
    }
}

// MARK: - Skeleton View

struct NotificationSkeletonView: View {
    let isLight: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { _ in
                HStack(spacing: 14) {
                    Circle()
                        .fill(isLight ? Color.gray.opacity(0.1) : Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isLight ? Color.gray.opacity(0.1) : Color.white.opacity(0.1))
                            .frame(width: 150, height: 14)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isLight ? Color.gray.opacity(0.1) : Color.white.opacity(0.1))
                            .frame(width: 200, height: 10)
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isLight ? Color.white : Color.white.opacity(0.03))
                )
            }
        }
        .padding(.horizontal, 16)
        .shimmer()
    }
}

// MARK: - Empty View

struct EmptyNotificationsView: View {
    let isLight: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [.purple.opacity(0.5), .pink.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            Text("Bildirim Yok")
                .font(.title3.weight(.semibold))
                .foregroundStyle(isLight ? .black : .white)
            
            Text("Yeni bildirimler geldiğinde burada görünecek")
                .font(.subheadline)
                .foregroundStyle(isLight ? .black.opacity(0.5) : .white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + phase * geo.size.width * 2)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - ViewModel

@Observable @MainActor
final class NotificationsViewModel {
    var notifications: [AppNotification] = []
    var isLoading = false
    var error: Error?
    
    var hasUnread: Bool {
        notifications.contains { !$0.isRead }
    }
    
    func loadNotifications() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await NotificationService.shared.getNotifications()
            // Add new notifications to the top instead of replacing if needed, 
            // but for now replacing is fine for a fresh load.
            notifications = response.notifications
        } catch {
            print("Failed to load notifications: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    func markAsRead(_ notification: AppNotification) {
        // Optimistic update
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
        
        Task {
            do {
                try await NotificationService.shared.markAsRead(notificationId: notification.id)
            } catch {
                print("Failed to mark as read: \(error)")
                // Revert optimistic update? For now, keep it simple.
            }
        }
    }
    
    func markAllAsRead() async {
        // Optimistic update
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        
        do {
            try await NotificationService.shared.markAllAsRead()
        } catch {
            print("Failed to mark all as read: \(error)")
        }
    }
    
    func handleTap(_ notification: AppNotification) {
        markAsRead(notification)
        // Navigate if needed (e.g. to friend profile)
    }
}

// MARK: - Mock Data (DISABLED)
#Preview {
    NavigationStack {
        NotificationsView()
    }
    .environment(AppState())
}
