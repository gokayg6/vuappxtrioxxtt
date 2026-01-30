# VibeU Deployment Instructions

## 🔥 Firestore Security Rules Deployment

### Prerequisites
1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Initialize Firebase in the project (if not already done):
   ```bash
   cd VibeU
   firebase init
   ```
   - Select "Firestore" when prompted
   - Use existing project
   - Accept default file names

### Deploy Rules
```bash
cd VibeU
./deploy-firestore-rules.sh
```

Or manually:
```bash
firebase deploy --only firestore:rules
```

### Verify Rules
After deployment, check the Firebase Console:
1. Go to https://console.firebase.google.com
2. Select your project
3. Navigate to Firestore Database > Rules
4. Verify the rules are updated

## 📱 Friend Request System

The friend request system now uses Firestore subcollections for better security:

### Structure
```
users/{userId}/
  ├── sent_friend_requests/{requestId}
  │   ├── id: string
  │   ├── to_user_id: string
  │   ├── to_user_name: string
  │   ├── status: "pending" | "accepted" | "rejected"
  │   └── sent_at: timestamp
  │
  └── incoming_friend_requests/{requestId}
      ├── id: string
      ├── from_user_id: string
      ├── from_user_name: string
      ├── status: "pending" | "accepted" | "rejected"
      └── received_at: timestamp
```

### Diamond Cost
- Sending a friend request costs **10 diamonds**
- Balance is deducted immediately upon sending
- Users can earn 100 free diamonds daily

## ✅ Completed Features

### Task 9: Hide Action Buttons When Viewing Full Profile ✓
- Action buttons (rewind, skip, super like, like, add friend) now hide when user expands profile detail
- Buttons reappear when profile is collapsed
- Smooth animations with spring physics

### Task 10: Çifte Randevu (Double Date) System ✓
Fully functional real-time double date matching system:

#### Features:
- **Team Management**: Create teams with up to 3 friends
- **Invitations**: Send/receive invites to join double date teams
- **Discovery**: Browse other teams looking for matches
- **Matching**: Like teams and get matched when mutual
- **Settings**: Leave team, deactivate team, notification preferences
- **Real-time**: All data synced via Firestore

#### Components:
- `DoubleDateSheet` - Main interface
- `DoubleDateFriendPickerSheet` - Select friends to invite
- `DoubleDateSettingsSheet` - Team settings and preferences
- `DoubleDateService` - Backend API integration

#### Backend Routes:
- `GET /doubledate/team` - Get user's team
- `POST /doubledate/invites` - Send invite
- `GET /doubledate/invites/received` - Get received invites
- `POST /doubledate/invites/{id}/accept` - Accept invite
- `POST /doubledate/invites/{id}/reject` - Reject invite
- `GET /doubledate/discover` - Discover other teams
- `POST /doubledate/likes` - Like a team
- `POST /doubledate/skip` - Skip a team
- `GET /doubledate/matches` - Get matches
- `POST /doubledate/team/leave` - Leave team
- `POST /doubledate/team/deactivate` - Deactivate team

## 🎨 UI/UX Improvements

### Diamond Icon
- Custom blue crystal icon used throughout app
- Replaced all SF Symbol diamond icons
- Proper rendering with `.renderingMode(.original)`

### Profile Summary Sheet
- Compact 400px popup design
- Gray/white gradient ring around profile photo
- White text in both light/dark modes
- Locked social media icons
- Golden glow button (no icon on button itself)
- Success/error toast notifications
- Floating -10 💎 animation

### Diamond Screen (Elmaslarım)
- Scrollable layout with proper spacing
- Large balance display (100px icon, 56pt text)
- Daily reward system with countdown
- Purchase options (100, 500, 1000 diamonds)
- Reduced glow effect for cleaner look
- Gray/white gradient border matching profile style

### Filters
- Removed: Education status, bio filter, online only
- Kept functional: Age, distance, verified, photos, interests, relationship goal, zodiac
- All filters save to UserDefaults
- Global/Country toggle works properly

### Country Selection
- Replaced university with country
- 60+ countries with flags and Turkish names
- Search functionality
- Burç seçme style picker
- Shows flag + name in discover view

## 🐛 Bug Fixes

### Image Loading
- Implemented `ImageCacheService` with actor-based caching
- Created `CachedAsyncImage` component
- Prefetching for next 3-5 cards
- Instant loading with 0 delay (tak tak tak like Tinder)
- Fixed image mixing between users with unique IDs

### Profile Photo System
- Completely separated profile photo from gallery
- Profile photo: `uploadProfilePhoto()` → `users/{userId}/profile/profile_photo.jpg`
- Gallery photos: `uploadPhoto()` → never update profile_photo_url
- Independent systems

### Location Services
- Real-time distance calculation
- Proper location permissions handling
- Distance-based filtering works correctly

### Self-Filtering
- Users no longer appear in their own discover feed
- Checks both ID and name for filtering

## 📋 Remaining Tasks

### Task 11: Add 60 Mock Profiles
To add mock profiles to Firebase:

1. **Option A: Use Backend Seed Script**
   ```bash
   cd VibeU/Backend
   npm run seed
   ```

2. **Option B: Manual Firebase Console**
   - Go to Firebase Console > Firestore
   - Create documents in `users` collection
   - Upload images to Firebase Storage
   - Link storage URLs in user documents

3. **Option C: Create Seed Script** (Recommended)
   Create a script that:
   - Generates 60 realistic Turkish profiles (30 male, 30 female)
   - Downloads 4K profile images
   - Uploads to Firebase Storage
   - Creates Firestore documents with:
     - display_name, age (18-35), city, country
     - bio, interests, hobbies
     - photos array with Storage URLs
     - All required fields

### Mock Profile Requirements:
- **Gender**: 30 male, 30 female
- **Images**: 4K quality, unique for each profile
- **Storage**: Firebase Storage (not external links)
- **Data**: Realistic Turkish names, cities, bios
- **Mix**: Should appear alongside real users in discover feed

## 🚀 Build & Deploy

### Build for Device
```bash
cd VibeU
xcodebuild -project VibeU.xcodeproj -scheme VibeU \
  -destination 'id=00008110-001201C02E02601E' \
  clean build
```

### Install on Device
```bash
xcodebuild -project VibeU.xcodeproj -scheme VibeU \
  -destination 'id=00008110-001201C02E02601E' \
  install
```

## 📝 Notes

- All changes work in both light and dark themes
- Haptic feedback implemented (success: single vibration, error: double)
- Toast notifications for user feedback
- Smooth animations throughout
- No delays - instant transitions

## 🔐 Security

- Firestore rules properly configured
- Users can only write to their own documents
- Friend requests use secure subcollections
- Diamond transactions logged for audit trail

## 📞 Support

For issues or questions:
1. Check Firebase Console for errors
2. Review Xcode console logs
3. Verify Firestore rules are deployed
4. Ensure all dependencies are installed
