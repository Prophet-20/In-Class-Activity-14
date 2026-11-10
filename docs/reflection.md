# Activity 14 Reflection and Evidence

Blake Cantave | CSC 4360 | November 9, 2026

Repository: [https://github.com/Prophet-20/In-Class-Activity-14](https://github.com/Prophet-20/In-Class-Activity-14)

## Setup and payload

I kept Firebase Messaging on version 16.x to match the assignment and used the Android app registered with my Firebase project. The two data keys make the screen change straightforward: action must be update_ui, and asset selects a bundled image. With asset set to promo, the app shows the delivery van and "Out for delivery." Keeping a fixed list of supported assets prevents a message from loading an arbitrary file.

## Lifecycle and evidence

The screenshots made the different message paths easier to follow. T1 used onMessage while the app was visible. T2 used onMessageOpenedApp after the notification was tapped from the background. T3 started a new app process and used getInitialMessage, with the receipt count resetting to 1. The T1-T3 evidence shows each handler and its result. Background processing runs separately from the widget tree on Android, so that callback cannot call setState to update the screen directly.

## Validation and next step

For T4, changing only asset to unknown produced a message explaining that the asset was unsupported. The previous title and van image stayed visible, and the app kept running. One earlier issue was an extra lib folder that broke the service import; moving fcm_service.dart beside main.dart fixed it. My next improvement would be fetching the current order status from a backend after a notification, so the displayed information stays authoritative.

**AI assistance:** I used Codex to help implement and debug the app, run the device tests, organize the evidence, and draft this reflection.

## Device and permission

Pixel 10 Pro XL Android emulator (emulator-5554; sdk_gphone16k_arm64), Android 17 / API 37. Notification permission was authorized, with POST_NOTIFICATIONS granted. Tests ran on November 9, 2026, from 7:11 to 7:15 PM EST.

## Valid payload

T1-T3 used the same notification and custom string data. This is the conceptual message content, not a complete HTTP v1 request.

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

T4 changed only `data.asset` from `promo` to `unknown`.

## Four result rows

| Test | Expected handler and result | Observed result | Status | Evidence |
|---|---|---|---|---|
| T1 | onMessage and a visible update | Count 2; delivery title and van image appeared. | PASS | [T1-evidence.png](evidence/T1-evidence.png) |
| T2 | onMessageOpenedApp after a background tap | Count 3; notification tap returned to the existing process. | PASS | [T2-evidence.png](evidence/T2-evidence.png) |
| T3 | getInitialMessage on a notification cold start | New process; count 1; delivery UI loaded. | PASS | [T3-evidence.png](evidence/T3-evidence.png) |
| T4 | onMessage with rejection and preserved content | Count 2; unsupported-asset diagnostic; previous title and image retained; no crash. | PASS | [T4-evidence.png](evidence/T4-evidence.png) |

T1 began with one existing receipt, so its count increased from 1 to 2. T2 increased it to 3. T3 reset the count to 1 for the new launch, and T4 increased that count to 2.

## Limitations

These results cover one Android emulator. iOS and other platforms were not tested. Network conditions and device policies can affect FCM delivery, and the receipt counter is per launch. The complete evidence packet is in [evidence/delivery-evidence.pdf](evidence/delivery-evidence.pdf). Full device tokens and credentials are omitted.
