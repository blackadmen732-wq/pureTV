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
- **TV apps** tile: a grid of streaming apps (Netflix, YouTube, Prime Video…). OK opens the app; Back on the remote returns to PureTV. Edit the list in `streamingApps()` in `roku/components/MainScene.brs`; `tools/tv.sh apps` shows the ids installed on your TV.

## Remove or roll back

Open `http://<roku-ip>` again and click **Delete**, or upload an older zip.

## Let Claude control the TV

The cloud can't reach your home Wi-Fi, so this runs on the Chromebook (or anything on the same Wi-Fi as the TV):

    export ROKU_IP=192.168.x.x          # from the TV's developer screen
    export ROKU_DEV_PASSWORD=...        # type it yourself, never paste it in chat
    tools/tv.sh install                 # upload dist/PureTV.zip
    tools/tv.sh open                    # open PureTV
    tools/tv.sh key Right               # press a remote button
    tools/tv.sh launch 12               # open Netflix
    tools/tv.sh apps                    # list installed apps and ids

## Credits

App launching is adapted from [CleanYourRoku](https://github.com/UXDreamer/CleanYourRoku) by Damien Pressley (MIT, see `LICENSES/`).

## Build

    ./tools/build.sh

Makes `dist/PureTV.zip` and `dist/PureTV.sha256`. Needs Python 3 with Pillow, and `zip`.
