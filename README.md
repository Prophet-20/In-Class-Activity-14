# In-Class Activity 14

Flutter Firebase Cloud Messaging app for the **Order updates** delivery scenario in CSC 4360. A valid cloud message changes the screen from **Order received** with a packing-box image to **Out for delivery** with a delivery-van image.

## Submission materials

- [Reflection and evidence document](docs/Activity14_Reflection_and_Evidence.docx)
- [Reflection and test details in Markdown](docs/reflection.md)
- [Evidence summary PDF](docs/evidence/delivery-evidence.pdf)
- Four labeled screenshot composites: [T1](docs/evidence/T1-evidence.png), [T2](docs/evidence/T2-evidence.png), [T3](docs/evidence/T3-evidence.png), [T4](docs/evidence/T4-evidence.png)
- [Detailed result rows](docs/evidence/test-results.md), [CSV results](docs/evidence/test-results.csv), and [sanitized handler evidence](docs/evidence/handler-evidence.txt)

## Run the app

Use Flutter compatible with the Dart SDK constraint in `pubspec.yaml`. The tested target is Android with Google Play services. Firebase Core stays on 4.x and Firebase Messaging on 16.x to match the activity's registration-token APIs; resolved package versions are committed in `pubspec.lock`.

```bash
flutter pub get
flutter analyze
flutter devices
flutter run -d YOUR_ANDROID_DEVICE_ID
```

For the existing emulator on the development computer:

```bash
flutter emulators --launch Pixel_10_Pro_XL
flutter run -d emulator
```

The Android app identifier is `com.example.delivery_updates`, registered in Firebase project `delivery-updates-ee90f`. The client configuration files `lib/firebase_options.dart`, `android/app/google-services.json`, and `firebase.json` are included so the submitted Android project uses the same configuration that was tested. Firebase [documents these client configuration values as public identifiers](https://firebase.google.com/docs/projects/learn-more#config-files-objects); they do not provide permission to send notifications or administer the project.

Notification sending still requires access to the Firebase project. Allow notifications when the app requests permission. For manual testing, obtain the current install's token from the development console and use Firebase Console's **Send test message** with that token. Full device tokens, administrative credentials, signing keys, and local build caches are not included in this repository.

Only Android Firebase configuration and Android message delivery were tested. The other platform folders are Flutter scaffolding and do not establish configured or tested FCM support on those platforms.

## Payload contract

Send a notification with custom **string** data. See [the exact valid test payload](docs/evidence/payload-valid.json).

```json
{
  "notification": {
    "title": "Order #1001 is out for delivery",
    "body": "Your driver is on the way."
  },
  "data": {
    "action": "update_ui",
    "asset": "promo"
  }
}
```

`asset: default` selects the packing-box image; `asset: promo` selects the van image. Missing or unsupported values are rejected with a visible diagnostic while preserving the current title and image. This JSON illustrates the message content, not a complete HTTP v1 request. Enter its data keys separately in the Firebase Console composer.

## Message handling

- `lib/main.dart` initializes Firebase before widgets, registers the top-level background callback, validates payloads, and shows handler/count/message-ID evidence.
- `lib/fcm_service.dart` centralizes permission requests, token access and refresh, `onMessage`, `onMessageOpenedApp`, and `getInitialMessage`.
- The background callback performs no widget updates. Android executes that work separately from the widget tree.

## Observed test results

All four required cases passed on **Pixel 10 Pro XL emulator, Android 17 / API 37**, on November 9, 2026. Notification permission was authorized. The app source and configuration were unchanged throughout these tests.

| Test | Observed handler | Result |
|---|---|---|
| T1 Foreground receipt | `onMessage` | Delivery title/image updated; count 2. |
| T2 Background notification tap | `onMessageOpenedApp` | Existing process resumed; count 3. |
| T3 Notification-triggered cold start | `getInitialMessage` | New process; count reset to 1; delivery UI loaded. |
| T4 Invalid `asset: unknown` | `onMessage` | Visible rejection; count 2; prior title/image preserved; no crash. |

One earlier receipt existed before T1. Counts are per app launch, which explains the reset at T3. T2 and T3 were opened through actual delivered notification taps; Android Settings force-stop was not used. T4's title/image screenshot region was pixel-identical before and after rejection.

## Assets and assistance

The two images are existing Pexels stock photographs, converted to PNG. [Photo sources and credits](assets/images/SOURCES.md) are included. No image generation was used.

Codex assisted with implementation/debugging, device test operation, evidence assembly, and drafting the reflection. The reflection includes this disclosure. LMS submission is a separate step.

[Assignment guide](https://codd.cs.gsu.edu/~lhenry23/mad/ica/act14/v2/index.html) | [Required tests](https://codd.cs.gsu.edu/~lhenry23/mad/ica/act14/v2/testing.html#essential-tests)
