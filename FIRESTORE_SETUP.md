# Firestore Security Rules Setup Guide

## Problem
You're getting a permission denied error when trying to access journal entries:
```
[cloud_firestore/permission-denied] Missing or insufficient permissions
```

## Solution
I've created Firestore security rules that allow users to read and write their own data.

## Files Created

1. **`firestore.rules`** - Security rules file
2. **`firebase.json`** - Updated to include Firestore rules configuration

## How to Deploy the Rules

### Option 1: Using Firebase CLI (Recommended)

1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase** (if not already done):
   ```bash
   firebase init firestore
   ```
   - Select your Firebase project
   - Use existing `firestore.rules` file

4. **Deploy the rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Option 2: Using Firebase Console (Web Interface)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `flutter-authentication-56ba3`
3. Navigate to **Firestore Database** → **Rules** tab
4. Copy the contents of `firestore.rules` file
5. Paste into the rules editor
6. Click **Publish**

## Security Rules Explained

The rules I've created:

### Journal Entries
- ✅ Users can **read** their own journal entries
- ✅ Users can **create** journal entries (must set userId to their own UID)
- ✅ Users can **update** their own journal entries
- ✅ Users can **delete** their own journal entries
- ❌ Users **cannot** access other users' journal entries

### Users Collection
- ✅ Users can read their own profile
- ✅ Admins can read all user profiles
- ✅ Users can create/update their own profile
- ✅ Admins can update any user profile

### Future Collections
Rules are also set up for:
- `daily_routines` - Same permissions as journal entries
- `meal_plans` - Same permissions as journal entries
- `therapy_sessions` - Same permissions as journal entries

## Testing

After deploying the rules:

1. **Test in your app**: Try accessing the journal entries page again
2. **Test in Firebase Console**: 
   - Go to Firestore Database
   - Try to read/write documents
   - You should see permissions working correctly

## Troubleshooting

### Still getting permission errors?

1. **Check if rules are deployed**:
   - Go to Firebase Console → Firestore → Rules
   - Verify the rules match the `firestore.rules` file

2. **Check user authentication**:
   - Make sure the user is logged in
   - Verify `request.auth.uid` matches the `userId` in the document

3. **Check document structure**:
   - Journal entries must have a `userId` field
   - The `userId` must match the authenticated user's UID

4. **Wait a few minutes**:
   - Rules can take 1-2 minutes to propagate after deployment

## Quick Test Rules (Development Only)

If you want to test quickly during development, you can temporarily use these less secure rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ **Warning**: These rules allow any authenticated user to read/write any document. Only use for development!

## Next Steps

1. Deploy the rules using one of the methods above
2. Test the journal entries feature in your app
3. The permission error should be resolved
4. Your journal entries will now persist in Firestore

