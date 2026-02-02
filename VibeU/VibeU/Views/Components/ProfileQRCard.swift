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
