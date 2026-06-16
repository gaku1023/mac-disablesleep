# DisableSleep

A tiny macOS **menu bar** app to toggle `pmset disablesleep` on and off with one click.

`disablesleep 1` stops your Mac from sleeping at all — **even with the lid closed**
(clamshell mode). It is stronger than `caffeinate` / Amphetamine-style assertions,
which is exactly why it requires root. DisableSleep handles that for you with a
narrowly-scoped, password-free `sudo` rule.

> 日本語版は [README.ja.md](README.ja.md) を参照してください。

## Screenshot

A sun (`☀︎`) / moon (`🌙`) icon sits in the **menu bar**. Sun = sleep disabled
(stays awake), moon = normal. The app has no Dock icon (it is a menu bar agent);
its crescent-moon app icon shows in Finder / Spotlight.

## Requirements

- macOS 13 (Ventura) or later
- Xcode command line tools (`xcode-select --install`) — only to build from source

## Install (prebuilt — easiest)

Grab `DisableSleep.zip` from the [latest release](https://github.com/gaku1023/mac-disablesleep/releases/latest), unzip it, then:

```sh
xattr -dr com.apple.quarantine DisableSleep.app   # unsigned app: clear Gatekeeper quarantine
mv DisableSleep.app /Applications/
curl -fsSL https://raw.githubusercontent.com/gaku1023/mac-disablesleep/main/setup-permissions.sh | bash
open -a DisableSleep
```

`setup-permissions.sh` adds the password-free sudo rule (asks for your password once).

## Install (from source)

```sh
git clone https://github.com/gaku1023/mac-disablesleep.git
cd mac-disablesleep
./install.sh        # run as your normal user; it asks for your password once
```

This builds `DisableSleep.app`, copies it to `/Applications`, and adds a sudoers
rule so the toggle works without a password.

The installer then asks whether to launch the app now. DisableSleep also
**starts automatically at login by default** (via `SMAppService`); you can turn
that off from the menu's **Launch at login** item.

Launch **DisableSleep** from Spotlight or `/Applications`. Click the menu bar
icon to disable / allow sleep.

> First launch of an unsigned app: if macOS blocks it, right-click the app in
> `/Applications` → **Open**, or run `xattr -dr com.apple.quarantine /Applications/DisableSleep.app`.

## How it works

- Reads state with `pmset -g` (parses the `SleepDisabled` line).
- Writes state with `sudo -n /usr/bin/pmset -a disablesleep {0,1}`.
- **Quitting the app (or logging out) automatically restores normal sleep**
  (`disablesleep 0`), so the setting never gets stuck if you close the app or
  drag it to the Trash while sleep is disabled. Sleep stays disabled only while
  the app is running.
- The installer adds this single line to `/etc/sudoers.d/mac-disablesleep`:

  ```
  <you> ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1
  ```

  It grants password-free root for **only** those two exact commands — nothing else.

## Manual equivalent

```sh
sudo pmset -a disablesleep 1   # disable sleep (stay awake, even lid closed)
sudo pmset -a disablesleep 0   # back to normal
pmset -g | grep SleepDisabled  # check current state
```

## Uninstall

```sh
./uninstall.sh
```

Asks for confirmation, then restores normal sleep, deregisters the login item,
removes the app, clears its preferences, and removes the sudoers rule.

## Notes & troubleshooting

- **"DisableSleep can't be opened" on first launch** — it's unsigned. Right-click
  the app → **Open**, or run `xattr -dr com.apple.quarantine /Applications/DisableSleep.app`.
- **Launch at login asks for approval** — for unsigned apps macOS may list the
  login item under System Settings → General → Login Items as needing approval.
  Enable it there if prompted.
- **Old/generic icon after install** — that's the Finder/Dock icon cache. Log out
  and back in (or it refreshes on its own) to see the crescent-moon icon.

## Security notes

- The sudoers rule is intentionally minimal — it cannot run arbitrary `pmset`
  subcommands, only `disablesleep 0` / `disablesleep 1`.
- The app is distributed unsigned (no Apple Developer account). Build it
  yourself from source if you prefer.

## License

[MIT](LICENSE)

---

Enjoy vibe coding 😎
