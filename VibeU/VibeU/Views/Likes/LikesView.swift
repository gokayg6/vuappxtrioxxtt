import SwiftUI

// MARK: - Likes View
struct LikesView: View {
    @State private var selectedUser: DiscoverUser?
    @State private var showPremiumSheet = false
    @Environment(AppState.self) private var appState
    
    private let likedYouUsers = DiscoverUser.likedYouUsers
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header Stats
                        if !appState.isPremium {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 70, height: 70)
                                    
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.white)
                                }
                                
                                Text("\(likedYouUsers.count) kişi seni beğendi")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                Text("Premium ile kimlerin beğendiğini gör")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .padding(.top, 20)
                        }
                        
                        // Users Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(likedYouUsers) { user in
                                LikesCardView(user: user, isBlurred: !appState.isPremium) {
                                    if appState.isPremium {
                                        selectedUser = user
                                    } else {
                                        showPremiumSheet = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        if !appState.isPremium {
                            Color.clear.frame(height: 100)
                        }
                    }
                }
                
                // Floating Bottom Button
                if !appState.isPremium {
                    Button {
                        showPremiumSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 18))
                            Text("Seni kimlerin beğendiğini gör")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(Color(red: 0.04, green: 0.02, blue: 0.08))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [.white, Color(white: 0.9)], startPoint: .top, endPoint: .bottom))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 90)
                }
            }
            .navigationTitle("Beğenenler")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(red: 0.04, green: 0.02, blue: 0.08), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(item: $selectedUser) { user in
                ProfileDetailView(user: user)
            }
            .sheet(isPresented: $showPremiumSheet) {
                SubscriptionSheet()
            }
        }
    }
}

// MARK: - Likes Card View
struct LikesCardView: View {
    let user: DiscoverUser
    let isBlurred: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Rectangle()
                            .fill(Color(white: 0.15))
                    }
                }
                .frame(height: 200)
                .clipped()
                .blur(radius: isBlurred ? 20 : 0)
                
                LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.system(size: 15, weight: .bold))
                        Text("\(user.age)")
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(user.city)
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                
                if isBlurred {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
