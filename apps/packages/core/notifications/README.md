# core_notifications

Host-agnostic **Firebase Cloud Messaging (FCM)** and **local** notifications using:

- [`awesome_notifications`](https://pub.dev/packages/awesome_notifications) `^0.11.0`
- [`awesome_notifications_fcm`](https://pub.dev/packages/awesome_notifications_fcm) `^0.11.0` (FCM integration; **do not** add [`firebase_messaging`](https://pub.dev/packages/firebase_messaging))

Per upstream docs, **`awesome_notifications_fcm` replaces `firebase_messaging`**. Using both will break the project.

## Requirements

- **`firebase_core` 4.x** in the app workspace (this package depends on it).
- Host must call **`Firebase.initializeApp`** before initializing this package.
- Host must call **`Hive.initFlutter()`** before `CoreNotificationsFacade.initializeLocal` (preferences use a Hive box).

## Initialization order

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Firebase.initializeApp(...)`
3. `Hive.initFlutter()`
4. `CoreNotificationsBridge.instance.configure(CoreNotificationsCallbacks(...))`
5. `CoreNotificationsFacade.instance.initializeLocal(...)`
6. `CoreNotificationsFacade.instance.initializeRemote(...)`
7. `CoreNotificationsFacade.instance.attachListeners()`
8. Optional: `installActionPortBridgeForMainIsolate` if `enableActionPortBridge` is true on callbacks
9. `runApp(...)`

See `apps/preppy_app/lib/bootstrap/preppy_notifications.dart` in this repo for a reference host.

## API overview

| Piece | Role |
|--------|------|
| `NotificationChannelDefinition` | Declarative Android channels + default layout hint |
| `NotificationPreferencesStore` | Per-channel enable/disable in Hive (`core_notifications_prefs` box) |
| `PushPayloadMapper` | Maps FCM **data** keys → `NotificationContent` / JSON for `createNotificationFromJsonData` |
| `CoreNotificationsFacade` | `initializeLocal`, `initializeRemote`, `attachListeners`, permission, token, topics |
| `CoreNotificationsBridge` + entry-point files | `@pragma('vm:entry-point')` handlers required by Awesome / FCM |

## FCM `data` payload keys (for `PushPayloadMapper`)

All values are **strings** (typical FCM data map).

| Key | Purpose |
|-----|---------|
| `channel_key` / `channelKey` / `android_channel_id` | Required. Must match a registered channel. |
| `id` | Optional integer string; default: hash of channel key |
| `title`, `body`, `summary` | Text |
| `layout` / `notification_layout` | `Default`, `BigPicture`, `Messaging`, `MediaPlayer`, … (enum name, case-insensitive) |
| `large_icon`, `big_picture`, `icon`, `custom_sound` | URIs / resources as supported by Awesome |
| `lines` / `inbox_lines` | JSON array string, or `\|` separated list (used as body lines) |
| `badge`, `ticker`, `group_key`, `payload` | As supported by Awesome |
| `display_on_foreground` / `display_on_background` | `"false"` to disable; default on |
| `color`, `background_color` | `#RRGGBB` or `AARRGGBB` |
| `locked`, `wake_up_screen`, `full_screen_intent`, `hide_large_icon_on_expand` | `"true"` / `"false"` |

**iOS:** Rich layouts while the app is **backgrounded or terminated** usually need a **Notification Service Extension**, **`mutable_content: true`**, and often **App Groups**—see the [awesome_notifications_fcm readme](https://pub.dev/packages/awesome_notifications_fcm).

## Android

- **`POST_NOTIFICATIONS`** is declared in the host app for API 33+; still request permission in Dart via `CoreNotificationsFacade.requestPermission()`.
- Plugin manifests merge **INTERNET**, **FCM**, and boot receivers.

### Testing push on the Android emulator

1. Use an AVD with a **Google Play** system image (FCM needs Play services).
2. Copy a fresh FCM token from the app **Status** screen before each test batch (tokens rotate).
3. Send **data-only** messages with Awesome keys (`content.channelKey`, `content.title`, …). See `bruno/google/Push Notifications.yml` in the repo root.
4. Do not **Force stop** the app; swipe away is fine. Re-open the app if pushes stop after an emulator cold boot.
5. On the Status screen, confirm **silent** (FCM received) and **created/displayed** (tray pipeline) events. `silent` without `displayed` usually means permission, payload, or channel issues.
6. Refresh OAuth for HTTP sends (`gcloud auth print-access-token`); expired bearer tokens fail at FCM HTTP, not in the app.

## iOS

- **Minimum iOS 15** (required by Awesome Notifications 0.11.x).
- **Podfile** includes `AwesomePodFile` hooks (`update_awesome_pod_build_settings`, `update_awesome_main_target_settings`).
- **Runner.entitlements** includes `aps-environment` (development in repo; use **production** for App Store).
- **Info.plist** includes `UIBackgroundModes`: `remote-notification` (and `fetch`).
- **AppDelegate** registers `SwiftAwesomeNotificationsPlugin` / `SwiftAwesomeNotificationsFcmPlugin` **plugin registrant callbacks** (required for background / headless execution). Extend the callbacks if you need more plugins in silent FCM handlers (same pattern as the upstream example).

### Notification Service Extension (rich push in background)

For full Awesome layouts when the app is not in the foreground:

1. Xcode → **File → New → Target → Notification Service Extension** (e.g. `PreppyNotificationService`).
2. Follow [awesome_notifications_fcm](https://pub.dev/packages/awesome_notifications_fcm) **iOS** section: `DartAwesomeServiceExtension`, **App Groups**, **Push Notifications**, **Background Modes → Remote notifications**, optional **AwesomeFcmPodFile** block for the extension target.
3. Set **`mutable_content: true`** on FCM sends that should hit the extension.

## Workspace / Firebase upgrade note

`awesome_notifications` 0.11.x pulls **`intl` ^0.20**, which conflicts with **`flutterfire_cli`**’s old dependency chain. This repo dropped `flutterfire_cli` from `preppy_app` dev_dependencies; use a **global** install for FlutterFire CLI if needed:

```bash
dart pub global activate flutterfire_cli
```

Firebase packages across the workspace were bumped to **4.x / compatible** versions for `firebase_core` 4.x.
