# DisableSleep

A tiny macOS **menu bar** app to toggle `pmset disablesleep` on and off with one click.

`disablesleep 1` stops your Mac from sleeping at all — **even with the lid closed**
(clamshell mode). It is stronger than `caffeinate` / Amphetamine-style assertions,
which is exactly why it requires root. DisableSleep handles that for you with a
narrowly-scoped, password-free `sudo` rule.

> 日本語版は [README.ja.md](README.ja.md) を参照してください。

## Screenshot

A sun (`☀︎`) / moon (`🌙`) icon sits in the menu bar. Sun = sleep disabled
(stays awake), moon = normal.

## Requirements

- macOS 13 (Ventura) or later
- Xcode command line tools (`xcode-select --install`) to build from source

## Install

```sh
git clone https://github.com/gaku1023/mac-disablesleep.git
cd mac-disablesleep
./install.sh        # run as your normal user; it asks for your password once
```

This builds `DisableSleep.app`, copies it to `/Applications`, and adds a sudoers
rule so the toggle works without a password.

Launch **DisableSleep** from Spotlight or `/Applications`. Click the menu bar
icon to disable / allow sleep.

> First launch of an unsigned app: if macOS blocks it, right-click the app in
> `/Applications` → **Open**, or run `xattr -dr com.apple.quarantine /Applications/DisableSleep.app`.

## How it works

- Reads state with `pmset -g` (parses the `SleepDisabled` line).
- Writes state with `sudo -n /usr/bin/pmset -a disablesleep {0,1}`.
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

Restores normal sleep, removes the app and the sudoers rule.

## Security notes

- The sudoers rule is intentionally minimal — it cannot run arbitrary `pmset`
  subcommands, only `disablesleep 0` / `disablesleep 1`.
- The app is distributed unsigned (no Apple Developer account). Build it
  yourself from source if you prefer.

## License

[MIT](LICENSE)
