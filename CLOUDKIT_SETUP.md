# CloudKit Sync Setup Guide

This document explains how to enable iCloud sync for the Ingredient Converter app using CloudKit and SwiftData.

## What's Been Done

The code has been updated to support CloudKit syncing:

1. **IngredientConverterApp.swift** - ModelContainer now configured with `cloudKitDatabase: .automatic`
2. **CloudKitHelper.swift** - Helper class to check iCloud account status
3. **SettingsView.swift** - Added iCloud sync status display

## What You Need to Do in Xcode

### Step 1: Enable iCloud Capability

1. Open `IngredientConverter.xcodeproj` in Xcode
2. Select the **IngredientConverter** target in the project navigator
3. Go to the **Signing & Capabilities** tab
4. Click the **+ Capability** button
5. Search for and add **iCloud**
6. In the iCloud section that appears, check **CloudKit**
7. Xcode will automatically create a CloudKit container named `iCloud.com.dawndemeo.IngredientConverter` (or similar based on your bundle ID)

### Step 2: Verify Settings

Ensure the following settings are correct:

- **Container**: `iCloud.com.dawndemeo.IngredientConverter` (or your bundle ID)
- **Services**: CloudKit should be checked
- The container should show as "Active" with a green checkmark

### Step 3: Build and Test

1. **Clean Build Folder**: Product → Clean Build Folder (⌘⇧K)
2. **Build**: Product → Build (⌘B)
3. The app should build successfully

## How It Works

### Automatic Sync

- When users sign into iCloud on their devices, data automatically syncs
- SwiftData handles all sync operations via CloudKit
- Changes on one device propagate to other devices signed into the same iCloud account

### What Gets Synced

Everything in the SwiftData database syncs:
- **Default ingredients** (with favorites and lastUsedDate)
- **Custom ingredients** (created by the user)
- **Unit conversions** (for all ingredients)

This means:
- ✅ Favorites sync across devices
- ✅ Recently used ingredients stay in sync
- ✅ Custom ingredients appear on all devices
- ✅ No manual export/import needed

### User Experience

**If signed into iCloud:**
- Settings shows "iCloud sync enabled" with a green checkmark
- Data syncs automatically in the background
- No user action required

**If not signed into iCloud:**
- Settings shows "Sign in to iCloud to sync across devices" with a warning icon
- App continues to work normally with local data only
- Users can still use export/import as a backup option

## Testing CloudKit Sync

### Requirements for Testing

- **Two real devices** or **two separate Simulator instances** signed into the same iCloud account
- TestFlight builds work best for real-world testing
- CloudKit sync in Simulator can be unreliable

### Testing Steps

1. **Device 1**: Sign in to iCloud, install app
2. **Device 1**: Add a custom ingredient or favorite an ingredient
3. **Device 2**: Sign in to same iCloud account, install app
4. **Device 2**: Wait a few moments, then check if changes appear
5. Changes should sync within seconds to minutes depending on connectivity

### Debugging Sync Issues

If sync isn't working:

1. Check both devices are signed into the **same** iCloud account
2. Verify iCloud Drive is enabled in Settings → [Your Name] → iCloud
3. Check network connectivity on both devices
4. Force quit and relaunch the app
5. Check Xcode console for CloudKit errors

## Privacy & Data

- All data is stored in the user's **private iCloud account**
- You (the developer) cannot access user data
- Data does not sync through your servers
- Users control their data via iCloud settings
- Deleting the app from all devices removes data from iCloud after a grace period

## Cost Considerations

- CloudKit is **free** for most use cases
- Apple provides generous free tiers:
  - 10GB private database storage per user
  - 200MB per request
  - 400 requests per second
- For this app's use case (small ingredient database), you'll never hit limits

## Future Enhancements (Optional)

If you want more control over syncing:

1. **Selective Sync**: Only sync custom ingredients, not defaults
   - Requires two ModelConfigurations (one with CloudKit, one without)

2. **Conflict Resolution**: Custom logic for handling conflicts
   - SwiftData's default is usually sufficient

3. **Sync Status Indicator**: Real-time sync progress
   - Observe `NSPersistentCloudKitContainer` notifications

4. **Manual Sync Trigger**: Button to force immediate sync
   - Call `container.performBackgroundTask`

## Troubleshooting

### Build Errors

**Error: "No such module 'CloudKit'"**
- CloudKit is a system framework, should be available automatically
- Try: Clean Build Folder → Restart Xcode

**Error: "CloudKit container not found"**
- Check iCloud capability is enabled
- Verify container name matches bundle ID

### Runtime Issues

**Sync not working**
- Check CloudKit dashboard: developer.apple.com/icloud/dashboard
- Verify app has iCloud entitlements
- Check device is signed into iCloud

**Data duplicated**
- SwiftData uses object IDs to prevent duplicates
- If seeing duplicates, check for manual insertions without checking existing data

## Resources

- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [SwiftData + CloudKit](https://developer.apple.com/documentation/swiftdata/synchronizing-model-data-across-icloud)
- [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/)

---

**Note**: After enabling iCloud capability, you may need to update provisioning profiles in App Store Connect when releasing to TestFlight or the App Store.
