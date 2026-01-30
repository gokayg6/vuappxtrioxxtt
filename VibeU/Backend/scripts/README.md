# Mock Users Script with Firebase Storage Photos

## Overview
This script automatically creates 60+ mock users (40 female, 20 male) with real photos downloaded from Unsplash and uploaded to Firebase Storage.

## Features
- ✅ Downloads 9:16 portrait photos from Unsplash
- ✅ Uploads photos to Firebase Storage
- ✅ Creates Firebase Auth users
- ✅ Saves user data to Firestore
- ✅ All photos stored in Firebase Storage (not external URLs)
- ✅ 40 female users, 20 male users
- ✅ Diverse profiles with interests, hobbies, zodiac signs

## Prerequisites
1. Firebase Admin SDK service account key file at `Backend/serviceAccountKey.json`
2. Firebase Storage bucket configured
3. Dependencies installed: `npm install`

## Usage

```bash
cd VibeU/Backend
npm run add-mock-users-photos
```

## What It Does

1. **Downloads Photos**: Fetches random portrait photos from Unsplash (1080x1920 resolution)
2. **Uploads to Storage**: Uploads each photo to Firebase Storage at `user_photos/{userId}/profile.jpg`
3. **Creates Auth Users**: Creates Firebase Auth accounts with email/password
4. **Saves to Firestore**: Creates user documents with all profile data

## User Data Structure

Each user includes:
- Name, surname, age, gender
- City, country
- Bio with emoji
- Interests (array)
- Hobbies (array)
- Zodiac sign
- Email: `{name}.{surname}@vibeumock.com`
- Password: `VibeU2024!`
- Diamond balance: 100
- Profile completion: 100%
- Photo URL from Firebase Storage

## Firebase Storage Structure

```
user_photos/
  ├── {userId1}/
  │   └── profile.jpg
  ├── {userId2}/
  │   └── profile.jpg
  └── ...
```

## Notes

- Photos are made public automatically
- Temp files are cleaned up after upload
- Script shows progress for each user
- Error handling for failed uploads
- All photos are 9:16 aspect ratio (perfect for mobile)

## Troubleshooting

### "Storage bucket not configured"
Update the `storageBucket` in the script with your actual Firebase Storage bucket name.

### "Permission denied"
Ensure your service account has Storage Admin permissions.

### "Unsplash rate limit"
The script uses Unsplash Source API which has rate limits. If you hit the limit, wait a few minutes and try again.

## Alternative: Manual Photo Upload

If you prefer to use specific photos:
1. Upload photos to Firebase Storage manually
2. Update the `photo_url` field in Firestore for each user
3. Use the format: `https://storage.googleapis.com/{bucket}/{path}`
