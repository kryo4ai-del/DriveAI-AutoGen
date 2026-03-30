# Firebase Analytics Integration Guide — Unity

> DAI-Core Unity Analytics Template.
> Cross-platform consistent with iOS (`AnalyticsManager.swift`) and Android (`AnalyticsManager.kt`).

## 1. Install Firebase Unity SDK

### Option A: Unity Package Manager (recommended)

1. Download the **Firebase Unity SDK** from [firebase.google.com/docs/unity/setup](https://firebase.google.com/docs/unity/setup)
2. Extract the `.zip`
3. Import these packages via **Assets > Import Package > Custom Package**:
   - `FirebaseAnalytics.unitypackage` (required)
   - `FirebaseApp.unitypackage` (dependency, usually auto-included)

### Option B: Package Manager with EDM4U

If using **External Dependency Manager for Unity** (EDM4U):

1. Add the Firebase SDK packages as above
2. EDM4U resolves Android/iOS native dependencies automatically
3. Run **Assets > External Dependency Manager > Android Resolver > Force Resolve**

## 2. Platform Config Files

### Android: `google-services.json`

1. Download from Firebase Console > Project Settings > Android app
2. Place at: `Assets/google-services.json`
3. Unity's Firebase plugin auto-processes this during build

### iOS: `GoogleService-Info.plist`

1. Download from Firebase Console > Project Settings > iOS app
2. Place at: `Assets/GoogleService-Info.plist`
3. Included in Xcode project automatically during build

> **Important:** Both files must be in the `Assets/` root. Subfolders won't work.

## 3. Scene Setup

1. Create an **empty GameObject** in your **first scene** (e.g. `Splash` or `Bootstrap`)
2. Name it `AnalyticsManager`
3. Attach the `AnalyticsManager.cs` script
4. The singleton uses `DontDestroyOnLoad` — it persists across all scene loads

## 4. Async Initialization

Firebase Unity SDK requires async dependency checking before any API call.
Call `Configure()` once at startup:

```csharp
using UnityEngine;
using DriveAI.Analytics;

public class AppBootstrap : MonoBehaviour
{
    private async void Start()
    {
        bool success = await AnalyticsManager.Instance.Configure();

        if (success)
        {
            // Firebase is ready — log first event
            AnalyticsManager.Instance.SetAppProfile("gaming");

            var (name, parameters) = AnalyticsEvents.AppOpen();
            AnalyticsManager.Instance.Log(name, parameters);
        }
        else
        {
            Debug.LogError("Firebase init failed — analytics disabled.");
        }
    }
}
```

> **Why async?** `FirebaseApp.CheckAndFixDependenciesAsync()` verifies that Google Play Services
> (Android) or Firebase framework (iOS) is available and up-to-date. This can take a frame or two.

## 5. Usage Examples

### Simple Event Logging

```csharp
// Log a custom event with parameters
AnalyticsManager.Instance.LogEvent("level_completed", new Dictionary<string, object>
{
    { "level_id", 42 },
    { "time_seconds", 128.5 }
});

// Log a screen view
AnalyticsManager.Instance.LogScreenView("MainMenu");

// Log feature usage
AnalyticsManager.Instance.LogFeatureUsed("dark_mode");
```

### Using Pre-Built Events (AnalyticsEvents)

```csharp
using DriveAI.Analytics;

// Onboarding funnel
var (name, parameters) = AnalyticsEvents.OnboardingStart();
AnalyticsManager.Instance.Log(name, parameters);

var (stepName, stepParams) = AnalyticsEvents.OnboardingStep(1, "select_avatar");
AnalyticsManager.Instance.Log(stepName, stepParams);

var (completeName, completeParams) = AnalyticsEvents.OnboardingComplete();
AnalyticsManager.Instance.Log(completeName, completeParams);

// Purchase flow
var (purchaseStartName, purchaseStartParams) = AnalyticsEvents.PurchaseStart("gem_pack_100");
AnalyticsManager.Instance.Log(purchaseStartName, purchaseStartParams);

var (purchaseName, purchaseParams) = AnalyticsEvents.PurchaseComplete("gem_pack_100", 4.99, "USD");
AnalyticsManager.Instance.Log(purchaseName, purchaseParams);

// Error tracking
var (errorName, errorParams) = AnalyticsEvents.ErrorOccurred("network", 503, "Server unavailable");
AnalyticsManager.Instance.Log(errorName, errorParams);
```

### Conversion & Funnel Tracking

```csharp
// Funnel steps
AnalyticsManager.Instance.LogFunnelStep("checkout", 1, "cart_viewed");
AnalyticsManager.Instance.LogFunnelStep("checkout", 2, "payment_entered");
AnalyticsManager.Instance.LogFunnelStep("checkout", 3, "purchase_confirmed");

// Conversion
AnalyticsManager.Instance.LogConversion("purchase", value: 9.99, currency: "EUR");
```

### User Properties

```csharp
AnalyticsManager.Instance.SetUserProperty("premium_user", "true");
AnalyticsManager.Instance.SetUserProperty("preferred_language", "de");
AnalyticsManager.Instance.SetAppProfile("utility");
```

## 6. App Lifecycle Events

Track app foreground/background in a persistent script:

```csharp
using UnityEngine;
using DriveAI.Analytics;

public class AppLifecycleTracker : MonoBehaviour
{
    private void Start()
    {
        DontDestroyOnLoad(gameObject);
    }

    private void OnApplicationPause(bool paused)
    {
        if (paused)
        {
            var (name, parameters) = AnalyticsEvents.AppBackground();
            AnalyticsManager.Instance.Log(name, parameters);
        }
        else
        {
            var (name, parameters) = AnalyticsEvents.AppOpen();
            AnalyticsManager.Instance.Log(name, parameters);
        }
    }
}
```

## 7. Event Reference

All events use the `dai_` prefix. Identical across iOS, Android, Web, and Unity.

| Event Name | Parameters | Category |
|---|---|---|
| `dai_app_open` | none | Session |
| `dai_app_background` | none | Session |
| `dai_onboarding_start` | none | Onboarding |
| `dai_onboarding_step` | `step`, `step_name` | Onboarding |
| `dai_onboarding_complete` | none | Onboarding |
| `dai_onboarding_skip` | none | Onboarding |
| `dai_feature_used` | `feature_name` | Feature |
| `dai_feature_discovered` | `feature_name` | Feature |
| `dai_session_active` | `duration_seconds` | Engagement |
| `dai_content_viewed` | `content_id`, `content_type` | Engagement |
| `dai_purchase_start` | `product_id` | Monetization |
| `dai_purchase_complete` | `product_id`, `value`, `currency` | Monetization |
| `dai_subscription_start` | `plan_id` | Monetization |
| `dai_ad_impression` | `ad_type` | Monetization |
| `dai_error_occurred` | `error_domain`, `error_code`, `error_description` | Errors |

## 8. Troubleshooting

| Problem | Solution |
|---|---|
| `DependencyStatus` is not `Available` | Google Play Services outdated on device. EDM4U should prompt update. |
| Events not appearing in Firebase Console | Events can take up to 24h. Use **DebugView** for real-time: `adb shell setprop debug.firebase.analytics.app <package>` |
| `NullReferenceException` on `Instance` | AnalyticsManager GameObject missing in scene. Add it to your first scene. |
| `Configure()` never completes | Check `google-services.json` / `GoogleService-Info.plist` is in `Assets/` root. |
| IL2CPP build errors | Ensure Firebase SDK version matches your Unity version. Check [compatibility matrix](https://firebase.google.com/docs/unity/setup). |
