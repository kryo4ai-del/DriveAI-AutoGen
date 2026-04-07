# iOS Provisioning Profile Setup Guide

## Prerequisites
- Apple Developer Account (Team ID: Q3L7S9WGUT)
- Distribution Certificate installed (confirmed: `Apple Distribution: Andreas Ott (Q3L7S9WGUT)`)

## Steps

### 1. Create App ID (if not exists)
1. Go to https://developer.apple.com/account/resources/identifiers/list
2. Click "+" to add a new identifier
3. Select "App IDs" → "App"
4. Description: "DAI-Core Wildcard"
5. Bundle ID: Wildcard → `com.dai-core.*`
6. Click "Continue" → "Register"

### 2. Create Provisioning Profile
1. Go to https://developer.apple.com/account/resources/profiles/list
2. Click "+" to add a new profile
3. Select "App Store Connect" (under Distribution)
4. Select the App ID: `com.dai-core.*`
5. Select the Distribution Certificate: `Apple Distribution: Andreas Ott`
6. Profile Name: "DAI-Core App Store Distribution"
7. Click "Generate"
8. Download the .mobileprovision file

### 3. Install the Profile
```bash
# Double-click the downloaded .mobileprovision file
# OR:
cp ~/Downloads/*.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
```

### 4. Get the api_issuer_id
1. Go to https://appstoreconnect.apple.com/access/integrations/api
2. Copy the "Issuer ID" shown at the top
3. It looks like: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

### 5. Update config.yaml
Edit `mac_factory/config.yaml`:
```yaml
signing:
  team_id: "Q3L7S9WGUT"
  api_key_id: "97K2HQXJ26"
  api_key_path: "/Users/andreasott/DriveAI-AutoGen/factory/signing/credentials/AuthKey_97K2HQXJ26.p8"
  api_issuer_id: "PASTE_HERE"
  export_options_path: "ExportOptions.plist"
```

### 6. Verify
```bash
security find-identity -v -p codesigning
# Should show: Apple Distribution: Andreas Ott (Q3L7S9WGUT)

ls ~/Library/MobileDevice/Provisioning\ Profiles/
# Should show: *.mobileprovision file
```
