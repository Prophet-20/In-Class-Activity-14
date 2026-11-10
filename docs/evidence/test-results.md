# Delivery Updates - ICA 14 test results

All four required tests passed on November 9, 2026. The application code, dependencies, and platform configuration were not changed during this testing session. The app was not rebuilt or reinstalled.

## Device and permission

- Android emulator: Pixel 10 Pro XL; emulator-5554; reported model sdk_gphone16k_arm64.
- OS: Android 17, API 37.
- App package: com.example.delivery_updates.
- Firebase project: delivery-updates-ee90f.
- Notification permission: authorized in the app; POST_NOTIFICATIONS granted=true on Android.
- Sender: Firebase Console in Safari, using Send test message / Test campaign with only the current emulator's device token selected.
- No campaign was published and the existing active campaign was not edited. A separate unsaved test composer was used and restored to asset=promo afterward.
- Full device tokens and credentials are omitted from this evidence package.

## Payload

T1-T3 reused exactly this notification content with two custom string values. This is the conceptual message content, not a complete HTTP v1 request.

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

T4 changed only `data.asset` from `promo` to `unknown`. The title, body, and `action: update_ui` stayed the same.

## Four result rows

| Test | Expected handler/result | Observed result | Result | Evidence |
|---|---|---|---|---|
| T1 | onMessage; delivery title and image update; fresh receipt metadata. | onMessage; receipt count 1 to 2; Out for delivery and van image; valid update diagnostic. | PASS | T1-evidence.png; delivery-evidence.pdf page 2 |
| T2 | Delivered notification; onMessageOpenedApp after tap; delivery UI retained. | Notification delivered; tap ran onMessageOpenedApp; receipt count 3; delivery UI present; PID stayed 4248. | PASS | T2-evidence.png; delivery-evidence.pdf page 3 |
| T3 | Notification-triggered launch; getInitialMessage; receipt count 1; delivery UI. | New process PID 5780; getInitialMessage; receipt count 1; Out for delivery and van image. | PASS | T3-evidence.png; delivery-evidence.pdf page 4 |
| T4 | onMessage; visible rejection; increased receipt metadata; previous title/image retained; no crash. | onMessage; count 1 to 2; Rejected: unsupported asset "unknown".; previous delivery title/image preserved; app stayed running. | PASS | T4-evidence.png; delivery-evidence.pdf page 5 |

## Event identifiers and procedure

### T1: Foreground receipt

Kept the app visible and sent the valid payload to its current device token.

- Handler time: November 9, 2026, 7:11:57 PM EST.
- Message ID: `0:1794269516848575%89395b5089395b50`.
- On-screen handler: `onMessage`; receipt count: 2.
- Note: The app already had one earlier receipt before this test. T1 is the fresh event at count 2.

### T2: Background notification tap

Pressed Home, sent the same valid payload, opened the notification shade, and tapped the notification.

- Handler time: November 9, 2026, 7:13:12 PM EST.
- Message ID: `0:1794269561360653%89395b5089395b50`.
- On-screen handler: `onMessageOpenedApp`; receipt count: 3.
- Note: The same app process (PID 4248) resumed. The new handler, count, and message ID establish a fresh event.

### T3: Notification-triggered cold start

Dismissed the app from recents, verified its process ended and stopped=false, sent the same valid payload, then tapped its notification.

- Handler time: November 9, 2026, 7:14:43 PM EST.
- Message ID: `0:1794269653398385%89395b5089395b50`.
- On-screen handler: `getInitialMessage`; receipt count: 1.
- Note: Normal recents dismissal ended the app process. No Settings force-stop, launcher-icon start, or flutter run was used.

### T4: Unsupported asset rejected

Kept the app foregrounded and changed only data.asset from promo to unknown.

- Handler time: November 9, 2026, 7:15:34 PM EST.
- Message ID: `0:1794269733864634%89395b5089395b50`.
- On-screen handler: `onMessage`; receipt count: 2.
- Note: The title/image area is pixel-identical before and after (original screenshot region x=0..1344, y=160..1350).

## Interpretation and limitations

The app began this session with one prior receipt and a rejected action diagnostic. T1 therefore increased the existing launch's count from 1 to 2, and T2 increased it to 3. T3 created a new Flutter app launch and reset the count to 1; T4 increased that new launch's count to 2. These counts are per launch, not a permanent delivery history.

T2 and T3 also produced onBackgroundMessage log entries for the same message IDs. Those entries are supplementary background-processing evidence; the required notification-open results are onMessageOpenedApp for T2 and getInitialMessage for T3. The background callback does not directly update widget state.

This evidence establishes the four required behaviors on this one Android emulator. It does not establish delivery on iOS/macOS, guaranteed network delivery, every device policy, or persistence across all future launches. No optional tests or additional platforms were needed.

The four labeled PNG composites contain actual, unmodified emulator screenshots placed side by side with explanatory captions. Raw screenshots are retained in screenshots/. No application content or receipt indicators were edited into the images.

## Submission materials

The repository contains the app code and the [reflection document](../Activity14_Reflection_and_Evidence.docx), with [the same reflection in Markdown](../reflection.md). LMS submission remains a separate student action. Codex assisted with implementation/debugging, operating the tests, organizing the evidence, and drafting the reflection.

Assignment testing guide: https://codd.cs.gsu.edu/~lhenry23/mad/ica/act14/v2/testing.html#essential-tests
