# Firebase Analytics Integration Guide — Android

> DriveAI-AutoGen Android Production Line
> Cross-platform consistent with iOS analytics implementation.

## 1. Gradle Dependencies

### Project-level `build.gradle.kts`

```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("com.google.firebase.crashlytics") version "3.0.2" apply false
}
```

### App-level `build.gradle.kts`

```kotlin
plugins {
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

dependencies {
    // Firebase BoM — manages all Firebase library versions
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))

    // Analytics + Crashlytics (no version needed with BoM)
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-crashlytics-ktx")

    // Required for bundleOf() in AnalyticsEvents.kt
    implementation("androidx.core:core-ktx:1.13.1")
}
```

## 2. google-services.json

Place your `google-services.json` in the **app module root**:

```
app/
  google-services.json    <-- HERE
  src/
  build.gradle.kts
```

Download from: [Firebase Console](https://console.firebase.google.com/) > Project Settings > Your Android App > Download `google-services.json`

A template with placeholder values is provided at `google-services.json.template` for reference.

## 3. Application Setup

### Create or update your Application class:

```kotlin
import android.app.Application
import {{PACKAGE_NAME}}.analytics.AnalyticsManager

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        AnalyticsManager.configure(this)
    }
}
```

### Register in `AndroidManifest.xml`:

```xml
<application
    android:name=".MyApplication"
    ... >
```

## 4. Usage Examples

### Log a custom event

```kotlin
import {{PACKAGE_NAME}}.analytics.AnalyticsManager
import androidx.core.os.bundleOf

AnalyticsManager.logEvent("button_clicked", bundleOf(
    "button_name" to "signup",
    "screen" to "HomeScreen"
))
```

### Log a screen view

```kotlin
AnalyticsManager.logScreenView("ProfileScreen")
```

### Log feature usage

```kotlin
AnalyticsManager.logFeatureUsed("dark_mode")
```

### Log a funnel step

```kotlin
AnalyticsManager.logFunnelStep("onboarding", step = 2, stepName = "profile_setup")
```

### Log a conversion

```kotlin
AnalyticsManager.logConversion(
    type = "purchase",
    value = 9.99,
    currency = "USD"
)
```

### Set user properties

```kotlin
AnalyticsManager.setUserProperty("subscription_tier", "premium")
AnalyticsManager.setAppProfile("fitness")
```

### Use typed events (AnalyticsEvents sealed class)

```kotlin
import {{PACKAGE_NAME}}.analytics.AnalyticsEvents
import {{PACKAGE_NAME}}.analytics.AnalyticsManager

// Session
val event = AnalyticsEvents.Session.AppOpen
AnalyticsManager.logEvent(event.eventName, event.parameters)

// Onboarding funnel
val step = AnalyticsEvents.Onboarding.Step(step = 1, stepName = "welcome")
AnalyticsManager.logEvent(step.eventName, step.parameters)

// Feature usage
val feature = AnalyticsEvents.Feature.Used("camera_filter")
AnalyticsManager.logEvent(feature.eventName, feature.parameters)

// Purchase
val purchase = AnalyticsEvents.Monetization.PurchaseComplete(
    productId = "premium_monthly",
    value = 9.99,
    currency = "USD"
)
AnalyticsManager.logEvent(purchase.eventName, purchase.parameters)

// Error tracking
val error = AnalyticsEvents.Error.Occurred(
    errorCode = "NET_TIMEOUT",
    errorMessage = "API request timed out",
    screen = "FeedScreen"
)
AnalyticsManager.logEvent(error.eventName, error.parameters)
```

## 5. Cross-Platform Event Consistency

All `dai_` prefixed events are identical across iOS and Android:

| Event | Name | Platform |
|---|---|---|
| App Open | `dai_app_open` | iOS + Android |
| App Background | `dai_app_background` | iOS + Android |
| Onboarding Start | `dai_onboarding_start` | iOS + Android |
| Onboarding Step | `dai_onboarding_step` | iOS + Android |
| Onboarding Complete | `dai_onboarding_complete` | iOS + Android |
| Onboarding Skip | `dai_onboarding_skip` | iOS + Android |
| Feature Used | `dai_feature_used` | iOS + Android |
| Feature Discovered | `dai_feature_discovered` | iOS + Android |
| Session Active | `dai_session_active` | iOS + Android |
| Content Viewed | `dai_content_viewed` | iOS + Android |
| Purchase Start | `dai_purchase_start` | iOS + Android |
| Purchase Complete | `dai_purchase_complete` | iOS + Android |
| Subscription Start | `dai_subscription_start` | iOS + Android |
| Ad Impression | `dai_ad_impression` | iOS + Android |
| Error Occurred | `dai_error_occurred` | iOS + Android |

## 6. Debug / Verification

Enable debug mode to see events in real-time in Firebase DebugView:

```bash
adb shell setprop debug.firebase.analytics.app {{PACKAGE_NAME}}
```

Disable debug mode:

```bash
adb shell setprop debug.firebase.analytics.app .none.
```

## 7. ProGuard / R8

Firebase libraries include their own ProGuard rules. No additional configuration needed unless you use custom obfuscation settings.
