# VibeU - Social Add & Discovery App

Premium iOS social discovery application built with SwiftUI (iOS 26) and Liquid Glass design system.

## 🎯 Core Features

- **Age-Segregated Pools**: Strict separation between minor (13-17) and adult (18+) users
- **Local & Global Discovery**: Switch between nearby and worldwide user discovery
- **Social Media Sharing**: Connect TikTok, Instagram, Snapchat - visible only to friends
- **Request System**: Send connection requests, accept to unlock social links
- **Premium Features**: Unlimited likes, see who liked you, boosts, neon profile frame

## 🏗️ Architecture

### iOS App (SwiftUI + iOS 26)
- **Liquid Glass UI**: Native iOS 26 `.glassEffect()` throughout
- **MVVM Architecture**: Clean separation with `@Observable` ViewModels
- **Async/Await**: Modern Swift concurrency
- **StoreKit 2**: In-app purchases and subscriptions

### Backend (Node.js + TypeScript)
- **Express.js**: REST API
- **Prisma ORM**: PostgreSQL database
- **JWT Auth**: Secure token-based authentication
- **Rate Limiting**: Per-action limits for free/premium users

## 🔐 Safety & Security

### Age Group Enforcement (CRITICAL)
```
┌─────────────────────────────────────────┐
│  MINOR POOL (13-17)  │  ADULT POOL (18+) │
│                      │                   │
│  ❌ Cannot see       │  ❌ Cannot see    │
│  ❌ Cannot like      │  ❌ Cannot like   │
│  ❌ Cannot request   │  ❌ Cannot request│
│                      │                   │
│  Adults              │  Minors           │
└─────────────────────────────────────────┘
```

- Age calculated server-side on every request
- No client-side age group trust
- Database queries always filter by age group
- Cross-pool actions return 403 immediately

## 📱 Screens

1. **Onboarding** - 3-slide introduction
2. **Auth** - Phone OTP, Apple Sign In, Google Sign In
3. **Discover** - Hero card, trending, spotlight, swipe stack
4. **Requests** - Received, sent, friends list
5. **Profile** - Edit, photos, interests, social links
6. **QR Code** - Share profile via QR
7. **Premium** - Subscription and boosts
8. **Notifications** - Real-time updates

## 🎨 Design System

### Liquid Glass Layers
- **Layer 1 (Primary)**: Cards, modals, main containers
- **Layer 2 (Nav)**: TabBar, NavigationBar, toolbars
- **Layer 3 (Micro)**: Buttons, badges, pills, toggles

### Theme
- Primary: Deep Purple (#9B54EA)
- Dark mode dominant
- Native haptic feedback
- Spring animations only

## 🚀 Getting Started

### iOS App
```bash
cd VibeU
open VibeU.xcodeproj
# Build with Xcode 16+ for iOS 26
```

### Backend
```bash
cd Backend
npm install
cp .env.example .env
# Edit .env with your credentials
npx prisma migrate dev
npm run dev
```

## 📊 Discovery Algorithm

```
score = ageScore × 1.0
      + interestScore × (0.5 local / 0.8 global)
      + locationScore × (0.7 local / 0.1 global)
      + activityScore × (0.2 local / 0.4 global)
      + profileQualityScore × 0.3
      + boostScore
```

## 🛡️ App Store Compliance

- ✅ Age verification at signup
- ✅ Strict content moderation
- ✅ Report/block functionality
- ✅ No DM feature (reduces abuse vectors)
- ✅ Social links hidden until mutual connection
- ✅ COPPA compliant for minors

## 📄 License

Proprietary - All rights reserved
