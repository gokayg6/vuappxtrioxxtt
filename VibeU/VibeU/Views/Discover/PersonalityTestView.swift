import SwiftUI

// MARK: - Personality Test Models

struct PersonalityQuestion: Identifiable {
    let id: Int
    let question: String
    let options: [PersonalityOption]
    let category: PersonalityCategory
}

struct PersonalityOption: Identifiable {
    let id: Int
    let text: String
    let emoji: String
    let value: Int
}

enum PersonalityCategory: String, CaseIterable {
    case social = "Sosyallik"
    case adventure = "Macera"
    case romance = "Romantizm"
    case lifestyle = "Yaşam Tarzı"
    case communication = "İletişim"
    
    var icon: String {
        switch self {
        case .social: return "person.2.fill"
        case .adventure: return "airplane"
        case .romance: return "heart.fill"
        case .lifestyle: return "house.fill"
        case .communication: return "bubble.left.and.bubble.right.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .social: return .blue
        case .adventure: return .orange
        case .romance: return .pink
        case .lifestyle: return .green
        case .communication: return .purple
        }
    }
}

extension PersonalityQuestion {
    static let allQuestions: [PersonalityQuestion] = [
        // Sosyallik
        PersonalityQuestion(
            id: 1,
            question: "Hafta sonu planın nasıl olur?",
            options: [
                PersonalityOption(id: 1, text: "Arkadaşlarla dışarıda eğlence", emoji: "🎉", value: 4),
                PersonalityOption(id: 2, text: "Küçük bir grup ile buluşma", emoji: "👥", value: 3),
                PersonalityOption(id: 3, text: "Evde film ve kitap", emoji: "📚", value: 2),
                PersonalityOption(id: 4, text: "Yalnız doğa yürüyüşü", emoji: "🌲", value: 1)
            ],
            category: .social
        ),
        PersonalityQuestion(
            id: 2,
            question: "Yeni insanlarla tanışmak seni nasıl hissettirir?",
            options: [
                PersonalityOption(id: 1, text: "Heyecanlandırır, bayılırım!", emoji: "🤩", value: 4),
                PersonalityOption(id: 2, text: "Güzel ama biraz yorucu", emoji: "😊", value: 3),
                PersonalityOption(id: 3, text: "Duruma göre değişir", emoji: "🤔", value: 2),
                PersonalityOption(id: 4, text: "Biraz çekingen olurum", emoji: "😅", value: 1)
            ],
            category: .social
        ),
        // Macera
        PersonalityQuestion(
            id: 3,
            question: "Tatil planlarken neyi tercih edersin?",
            options: [
                PersonalityOption(id: 1, text: "Yeni ülkeler keşfetmek", emoji: "✈️", value: 4),
                PersonalityOption(id: 2, text: "Macera sporları", emoji: "🏄", value: 3),
                PersonalityOption(id: 3, text: "Kültürel turlar", emoji: "🏛️", value: 2),
                PersonalityOption(id: 4, text: "Sakin bir sahil tatili", emoji: "🏖️", value: 1)
            ],
            category: .adventure
        ),
        PersonalityQuestion(
            id: 4,
            question: "Risk almak hakkında ne düşünürsün?",
            options: [
                PersonalityOption(id: 1, text: "Hayat risk almakla güzel!", emoji: "🎲", value: 4),
                PersonalityOption(id: 2, text: "Hesaplı riskler alırım", emoji: "📊", value: 3),
                PersonalityOption(id: 3, text: "Nadiren risk alırım", emoji: "🛡️", value: 2),
                PersonalityOption(id: 4, text: "Güvenli olanı tercih ederim", emoji: "🏠", value: 1)
            ],
            category: .adventure
        ),
        // Romantizm
        PersonalityQuestion(
            id: 5,
            question: "İdeal ilk buluşma nasıl olmalı?",
            options: [
                PersonalityOption(id: 1, text: "Romantik bir akşam yemeği", emoji: "🕯️", value: 4),
                PersonalityOption(id: 2, text: "Eğlenceli bir aktivite", emoji: "🎳", value: 3),
                PersonalityOption(id: 3, text: "Rahat bir kahve sohbeti", emoji: "☕", value: 2),
                PersonalityOption(id: 4, text: "Doğada yürüyüş", emoji: "🌳", value: 1)
            ],
            category: .romance
        ),
        PersonalityQuestion(
            id: 6,
            question: "İlişkide en önemli şey nedir?",
            options: [
                PersonalityOption(id: 1, text: "Tutku ve heyecan", emoji: "🔥", value: 4),
                PersonalityOption(id: 2, text: "Güven ve sadakat", emoji: "🤝", value: 3),
                PersonalityOption(id: 3, text: "Ortak ilgi alanları", emoji: "🎯", value: 2),
                PersonalityOption(id: 4, text: "Özgürlük ve saygı", emoji: "🕊️", value: 1)
            ],
            category: .romance
        ),
        // Yaşam Tarzı
        PersonalityQuestion(
            id: 7,
            question: "Sabahları nasıl başlarsın?",
            options: [
                PersonalityOption(id: 1, text: "Erken kalkar, spor yaparım", emoji: "🏃", value: 4),
                PersonalityOption(id: 2, text: "Kahve ile yavaş başlarım", emoji: "☕", value: 3),
                PersonalityOption(id: 3, text: "Son dakikaya kadar uyurum", emoji: "😴", value: 2),
                PersonalityOption(id: 4, text: "Gece kuşuyum, geç kalkarım", emoji: "🦉", value: 1)
            ],
            category: .lifestyle
        ),
        PersonalityQuestion(
            id: 8,
            question: "Boş zamanlarında ne yaparsın?",
            options: [
                PersonalityOption(id: 1, text: "Spor ve fitness", emoji: "💪", value: 4),
                PersonalityOption(id: 2, text: "Sanat ve müzik", emoji: "🎨", value: 3),
                PersonalityOption(id: 3, text: "Oyun ve teknoloji", emoji: "🎮", value: 2),
                PersonalityOption(id: 4, text: "Yemek ve gastronomi", emoji: "🍳", value: 1)
            ],
            category: .lifestyle
        ),
        // İletişim
        PersonalityQuestion(
            id: 9,
            question: "Tartışmalarda nasıl davranırsın?",
            options: [
                PersonalityOption(id: 1, text: "Hemen konuşup çözerim", emoji: "💬", value: 4),
                PersonalityOption(id: 2, text: "Sakinleşip sonra konuşurum", emoji: "🧘", value: 3),
                PersonalityOption(id: 3, text: "Yazarak ifade ederim", emoji: "✍️", value: 2),
                PersonalityOption(id: 4, text: "Zaman tanırım", emoji: "⏰", value: 1)
            ],
            category: .communication
        ),
        PersonalityQuestion(
            id: 10,
            question: "Mesajlaşma tarzın nasıl?",
            options: [
                PersonalityOption(id: 1, text: "Hemen cevap veririm", emoji: "⚡", value: 4),
                PersonalityOption(id: 2, text: "Uzun ve detaylı yazarım", emoji: "📝", value: 3),
                PersonalityOption(id: 3, text: "Kısa ve öz olurum", emoji: "👍", value: 2),
                PersonalityOption(id: 4, text: "Sesli mesaj tercih ederim", emoji: "🎤", value: 1)
            ],
            category: .communication
        )
    ]
}

// MARK: - Personality Test View

struct PersonalityTestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestionIndex = 0
    @State private var answers: [Int: Int] = [:]
    @State private var showResults = false
    @State private var animateProgress = false
    
    private let questions = PersonalityQuestion.allQuestions
    
    private var progress: Double {
        Double(answers.count) / Double(questions.count)
    }
    
    private var currentQuestion: PersonalityQuestion {
        questions[currentQuestionIndex]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                
                if showResults {
                    PersonalityResultsView(answers: answers, questions: questions) {
                        dismiss()
                    }
                } else {
                    VStack(spacing: 0) {
                        // Progress Header
                        progressHeader
                        
                        // Question Content
                        questionContent
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .id(currentQuestionIndex)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if currentQuestionIndex > 0 {
                            withAnimation(.spring(response: 0.4)) {
                                currentQuestionIndex -= 1
                            }
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: currentQuestionIndex > 0 ? "chevron.left" : "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Kişilik Testi")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
    // MARK: - Progress Header
    
    private var progressHeader: some View {
        VStack(spacing: 16) {
            // Category Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PersonalityCategory.allCases, id: \.rawValue) { category in
                        CategoryPill(
                            category: category,
                            isActive: currentQuestion.category == category,
                            isCompleted: isCategoryCompleted(category)
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.1))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress, height: 6)
                            .animation(.spring(response: 0.4), value: progress)
                    }
                }
                .frame(height: 6)
                
                HStack {
                    Text("Soru \(currentQuestionIndex + 1)/\(questions.count)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text("%\(Int(progress * 100)) tamamlandı")
                        .font(.caption)
                        .foregroundStyle(.purple)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 16)
    }
    
    // MARK: - Question Content
    
    private var questionContent: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Category Icon
            ZStack {
                Circle()
                    .fill(currentQuestion.category.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: currentQuestion.category.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(currentQuestion.category.color)
            }
            
            // Question Text
            Text(currentQuestion.question)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Options
            VStack(spacing: 12) {
                ForEach(currentQuestion.options) { option in
                    OptionButton(
                        option: option,
                        isSelected: answers[currentQuestion.id] == option.id,
                        color: currentQuestion.category.color
                    ) {
                        selectOption(option)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Functions
    
    private func isCategoryCompleted(_ category: PersonalityCategory) -> Bool {
        let categoryQuestions = questions.filter { $0.category == category }
        return categoryQuestions.allSatisfy { answers[$0.id] != nil }
    }
    
    private func selectOption(_ option: PersonalityOption) {
        withAnimation(.spring(response: 0.3)) {
            answers[currentQuestion.id] = option.id
        }
        
        // Move to next question after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.4)) {
                if currentQuestionIndex < questions.count - 1 {
                    currentQuestionIndex += 1
                } else {
                    showResults = true
                }
            }
        }
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let category: PersonalityCategory
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : category.icon)
                .font(.system(size: 12))
            
            Text(category.rawValue)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(isActive ? .white : (isCompleted ? .green : .white.opacity(0.5)))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isActive ? category.color.opacity(0.3) : .white.opacity(0.05))
        )
        .overlay(
            Capsule()
                .stroke(isActive ? category.color : .clear, lineWidth: 1)
        )
    }
}

// MARK: - Option Button

struct OptionButton: View {
    let option: PersonalityOption
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(option.emoji)
                    .font(.title2)
                
                Text(option.text)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(color)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color.opacity(0.2) : .white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : .white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Personality Results View

struct PersonalityResultsView: View {
    let answers: [Int: Int]
    let questions: [PersonalityQuestion]
    let onComplete: () -> Void
    
    @State private var animateResults = false
    
    private var categoryScores: [PersonalityCategory: Int] {
        var scores: [PersonalityCategory: Int] = [:]
        for category in PersonalityCategory.allCases {
            scores[category] = 0
        }
        
        for question in questions {
            if let answerId = answers[question.id],
               let option = question.options.first(where: { $0.id == answerId }) {
                scores[question.category, default: 0] += option.value
            }
        }
        return scores
    }
    
    private var personalityType: String {
        let totalScore = categoryScores.values.reduce(0, +)
        let avgScore = Double(totalScore) / Double(categoryScores.count)
        
        if avgScore > 3.0 {
            return "Sosyal Kelebek 🦋"
        } else if avgScore > 2.5 {
            return "Dengeli Ruh 🌟"
        } else if avgScore > 2.0 {
            return "Sakin Deniz 🌊"
        } else {
            return "Gizemli Ay 🌙"
        }
    }
    
    private var personalityDescription: String {
        let totalScore = categoryScores.values.reduce(0, +)
        let avgScore = Double(totalScore) / Double(categoryScores.count)
        
        if avgScore > 3.0 {
            return "Enerjik, sosyal ve maceraperest bir ruha sahipsin! İnsanlarla vakit geçirmeyi ve yeni deneyimler yaşamayı seviyorsun."
        } else if avgScore > 2.5 {
            return "Hem sosyal hem de kendi zamanına değer veren dengeli bir kişiliğe sahipsin. Uyum sağlama yeteneğin güçlü."
        } else if avgScore > 2.0 {
            return "Sakin, düşünceli ve derin bağlantılar kurmayı seven birisin. Kaliteli ilişkilere önem veriyorsun."
        } else {
            return "Gizemli ve içe dönük bir yapın var. Kendi iç dünyanı keşfetmeyi ve anlamlı bağlar kurmayı tercih ediyorsun."
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Result Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple.opacity(0.3), .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 120, height: 120)
                            .scaleEffect(animateResults ? 1.0 : 0.5)
                        
                        Text("🎭")
                            .font(.system(size: 50))
                            .scaleEffect(animateResults ? 1.0 : 0.5)
                    }
                    
                    Text(personalityType)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                        .opacity(animateResults ? 1 : 0)
                    
                    Text(personalityDescription)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(animateResults ? 1 : 0)
                }
                .padding(.top, 20)
                
                // Category Scores
                VStack(alignment: .leading, spacing: 16) {
                    Text("Kategori Puanların")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    ForEach(PersonalityCategory.allCases, id: \.rawValue) { category in
                        CategoryScoreRow(
                            category: category,
                            score: categoryScores[category] ?? 0,
                            maxScore: 8,
                            animate: animateResults
                        )
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)
                
                // Compatibility Info
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundStyle(.pink)
                        Text("Uyumluluk Artışı")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("+15%")
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                    
                    Text("Kişilik testi sonuçların artık profilinde görünecek ve seninle uyumlu kişileri bulmamıza yardımcı olacak!")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
                
                // Complete Button
                Button(action: onComplete) {
                    Text("Keşfetmeye Devam Et")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.2)) {
                animateResults = true
            }
        }
    }
}

// MARK: - Category Score Row

struct CategoryScoreRow: View {
    let category: PersonalityCategory
    let score: Int
    let maxScore: Int
    let animate: Bool
    
    private var percentage: Double {
        Double(score) / Double(maxScore)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(category.color)
                
                Text(category.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("\(score)/\(maxScore)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.1))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(category.color)
                        .frame(width: animate ? geo.size.width * percentage : 0, height: 8)
                        .animation(.spring(response: 0.6).delay(0.3), value: animate)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Premium Background

struct PremiumBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.04, blue: 0.16),
                Color(red: 0.04, green: 0.02, blue: 0.08)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    PersonalityTestView()
}
