import SwiftUI
import PhotosUI

// MARK: - Step 5: Photo Upload (Min 2-3 photos)
struct PhotoUploadView: View {
    @Binding var data: OnboardingData
    let onNext: () -> Void
    let onBack: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    private var backgroundColor: Color {
        isDark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color.white
    }
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showImagePicker = false
    
    private let minPhotos = 2
    private let maxPhotos = 6
    
    var isComplete: Bool {
        data.photos.count >= minPhotos
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                ProgressBar(current: 5, total: 6, isDark: isDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(isDark ? .white : .black)
                        }
                        
                        Text("Fotoğraflarınız")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(isDark ? .white : .black)
                        
                        Text("En az \(minPhotos) fotoğraf ekleyin")
                            .font(.system(size: 16))
                            .foregroundStyle(isDark ? .white.opacity(0.7) : .black.opacity(0.7))
                        
                        Text("\(data.photos.count)/\(maxPhotos) fotoğraf")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(data.photos.count >= minPhotos ? .green : .orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05)))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Photo Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(0..<maxPhotos, id: \.self) { index in
                            if index < data.photos.count {
                                // Existing Photo
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: data.photos[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    
                                    // Remove Button
                                    Button {
                                        data.photos.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(isDark ? .white : .black)
                                            .background(Circle().fill(isDark ? Color.black.opacity(0.5) : Color.white.opacity(0.5)))
                                    }
                                    .padding(8)
                                    
                                    // Primary Badge
                                    if index == 0 {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Text("Ana Fotoğraf")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 6)
                                                    .background(Capsule().fill(isDark ? Color.white : Color.black))
                                                Spacer()
                                            }
                                            .padding(8)
                                        }
                                    }
                                }
                            } else {
                                // Add Photo Button
                                Button {
                                    showImagePicker = true
                                } label: {
                                    VStack(spacing: 12) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(isDark ? .white.opacity(0.5) : .black.opacity(0.5))
                                        
                                        Text("Fotoğraf Ekle")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(isDark ? .white.opacity(0.7) : .black.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 220)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(.ultraThinMaterial)
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                            .foregroundStyle(isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.2))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("💡 İpuçları")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(isDark ? .white : .black)
                        
                        OnboardingTipRow(icon: "checkmark.circle.fill", text: "Yüzünüz net görünsün", color: .green, isDark: isDark)
                        OnboardingTipRow(icon: "checkmark.circle.fill", text: "Farklı açılardan çekilmiş olsun", color: .green, isDark: isDark)
                        OnboardingTipRow(icon: "xmark.circle.fill", text: "Grup fotoğrafı kullanmayın", color: .red, isDark: isDark)
                        OnboardingTipRow(icon: "xmark.circle.fill", text: "Filtre kullanmayın", color: .red, isDark: isDark)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                    )
                    .padding(.horizontal, 24)
                    
                    Color.clear.frame(height: 100)
                }
            }
            
                // Next Button
                Button {
                    onNext()
                } label: {
                    Text("Devam Et")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isDark ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isComplete ? (isDark ? .white : .black) : (isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)))
                        )
                }
                .disabled(!isComplete)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .photosPicker(isPresented: $showImagePicker, selection: $selectedItems, maxSelectionCount: maxPhotos - data.photos.count, matching: .images)
            .onChange(of: selectedItems) { _, newItems in
                Task {
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await MainActor.run {
                                self.data.photos.append(image)
                            }
                        }
                    }
                    selectedItems = []
                }
            }
        }
    }
}

// MARK: - Tip Row (Onboarding)
struct OnboardingTipRow: View {
    let icon: String
    let text: String
    let color: Color
    let isDark: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(isDark ? .white.opacity(0.8) : .black.opacity(0.8))
            
            Spacer()
        }
    }
}
