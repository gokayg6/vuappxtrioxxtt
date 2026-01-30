#!/bin/bash

# Deploy Firestore security rules to Firebase
# Make sure you have Firebase CLI installed: npm install -g firebase-tools
# And you're logged in: firebase login

echo "🔥 Deploying Firestore security rules..."

# Check if firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Install it with: npm install -g firebase-tools"
    exit 1
fi

# Deploy rules
firebase deploy --only firestore:rules

echo "✅ Firestore rules deployed successfully!"
