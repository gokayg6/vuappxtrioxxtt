import SwiftUI
import SafariServices

// MARK: - Event Detail View - Full Screen with bubilet.com Integration
struct EventDetailView: View {
    let event: LiveEvent
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showSafari = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // 4K Banner Image
                        AsyncImage(url: URL(string: event.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(16/9, contentMode: .fill)
                                    .frame(height: 280)
                                    .clipped()
                            case .failure(_), .empty:
                                Rectangle()
                                    .fill(LinearGradient(colors: [.purple.opacity(0.3), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(height: 280)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 20) {
                            // Title & Category
                            VStack(alignment: .leading, spacing: 8) {
                                Text(event.title)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(colors.primaryText)
                                
                                Text(event.category.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.purple, in: Capsule())
                            }
                            
                            // Info Cards
                            VStack(spacing: 12) {
                                InfoRow(icon: "calendar", title: "Tarih".localized, value: event.formattedDate, color: .orange)
                                InfoRow(icon: "mappin.circle.fill", title: "Konum".localized, value: event.location, color: .cyan)
                                InfoRow(icon: "person.2.fill", title: "Katılımcılar".localized, value: "\(event.attendees)/\(event.maxAttendees) " + "kişi".localized, color: .green)
                            }
                            
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Açıklama".localized)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(colors.primaryText)
                                
                                Text(event.description)
                                    .font(.system(size: 15))
                                    .foregroundStyle(colors.secondaryText)
                                    .lineSpacing(4)
                            }
                            
                            // Ticket Button
                            if let ticketURL = event.ticketURL {
                                Button {
                                    if let url = URL(string: ticketURL) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "ticket.fill")
                                            .font(.system(size: 18))
                                        Text("Bilet Al".localized)
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(
                                        LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing),
                                        in: RoundedRectangle(cornerRadius: 16)
                                    )
                                }
                            }
                            
                            // Join Button
                            Button {
                                // TODO: Join event logic
                            } label: {
                                HStack {
                                    Image(systemName: "person.badge.plus.fill")
                                        .font(.system(size: 18))
                                    Text("Etkinliğe Katıl".localized)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundStyle(colors.primaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 1))
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
}

// MARK: - Info Row
private struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(colors.tertiaryText)
                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(colors.primaryText)
            }
            
            Spacer()
        }
        .padding(14)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(colors.border, lineWidth: 0.5))
    }
}
