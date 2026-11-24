# PureTV

A calm home screen for my own Roku: Home, Library, Settings and Help, driven by the remote.

## Install on the Roku (from the Chromebook)

1. **Turn on developer mode** (one time). On the Roku remote press: Home ×3, Up ×2, Right, Left, Right, Left, Right. Accept, set a password, and write down the IP address it shows.
2. **Download the app**: get `dist/PureTV.zip` from this repo.
3. **Upload it**: in Chrome on the same Wi-Fi, open `http://<roku-ip>`, sign in as `rokudev` with your password, click **Upload**, pick `PureTV.zip`, then **Install with zip**.

PureTV opens right away. Afterwards it's on the Roku home screen as a dev app.

## Use it

- Left / Right: move between tiles. OK: open. Back: go back (or exit at Home).
- Settings: Appearance (Midnight / Graphite) and Motion (Standard / Reduced) are saved on the TV.
- Streaming apps (Netflix, YouTube…): press Home on the remote. Roku does not let other apps launch them.

## Remove or roll back

Open `http://<roku-ip>` again and click **Delete**, or upload an older zip.

## Build

    ./tools/build.sh

Makes `dist/PureTV.zip` and `dist/PureTV.sha256`. Needs Python 3 with Pillow, and `zip`.
