# In-Class Activity 14

My Flutter app for the delivery update scenario. It starts with **Order received** and a box image. A Firebase message changes the screen to **Out for delivery** and shows the delivery van. Invalid data displays an error and keeps the previous content.

## Run

Use an Android device or emulator with Google Play services, and allow notifications when prompted.

```bash
flutter pub get
flutter devices
flutter run -d emulator
```

For a physical device, replace `emulator` with its device ID. The project uses Firebase Core 4.x and Messaging 16.x. Android is the configured and tested platform.

## Send a test message

In Firebase Console, send a notification to the current device token and add these custom string values:

```text
action = update_ui
asset = promo
```

Use `asset = default` for the initial image or `asset = unknown` to test rejection. The [full test payload](docs/evidence/payload-valid.json) is included.

## Submission files

- Reflection: [PDF](docs/Activity14_Reflection_and_Evidence.pdf), [Word](docs/Activity14_Reflection_and_Evidence.docx), or [Markdown](docs/reflection.md)
- [Test results](docs/evidence/test-results.md) and [evidence PDF](docs/evidence/delivery-evidence.pdf)
- Screenshots: [T1](docs/evidence/T1-evidence.png), [T2](docs/evidence/T2-evidence.png), [T3](docs/evidence/T3-evidence.png), [T4](docs/evidence/T4-evidence.png)
- [Photo credits](assets/images/SOURCES.md)

All four tests passed on the Pixel 10 Pro XL emulator running Android 17: foreground receipt, background notification tap, cold start from a notification, and invalid payload rejection.
