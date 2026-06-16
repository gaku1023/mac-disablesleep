# DisableSleep

`pmset disablesleep` のオン/オフをメニューバーからワンクリックで切り替える、小さな macOS アプリです。

`disablesleep 1` は Mac を一切スリープさせません（**フタを閉じたクラムシェル状態でも有効**）。
`caffeinate` や Amphetamine 系のアサーションより強力で、その分 root 権限が必要です。
DisableSleep は対象コマンドだけに絞ったパスワード不要の `sudo` ルールでこれを処理します。

## アイコン

メニューバーに 太陽(`☀︎`) / 月(`🌙`) のアイコンが出ます。太陽 = スリープ無効（起きたまま）、月 = 通常。

## 動作要件

- macOS 13 (Ventura) 以降
- ソースからビルドするための Xcode コマンドラインツール（`xcode-select --install`）

## インストール

```sh
git clone https://github.com/gaku1023/mac-disablesleep.git
cd mac-disablesleep
./install.sh        # 通常ユーザーで実行。途中で一度だけパスワードを聞かれます
```

`DisableSleep.app` をビルドして `/Applications` にコピーし、パスワード不要で
切り替えられるよう sudoers ルールを追加します。

Spotlight か `/Applications` から **DisableSleep** を起動し、メニューバーの
アイコンをクリックして スリープ無効 / 通常 を切り替えてください。

> 未署名アプリの初回起動: macOS にブロックされたら `/Applications` のアプリを
> 右クリック →**開く**、または
> `xattr -dr com.apple.quarantine /Applications/DisableSleep.app` を実行。

## しくみ

- 状態の取得: `pmset -g`（`SleepDisabled` 行を解析）
- 状態の変更: `sudo -n /usr/bin/pmset -a disablesleep {0,1}`
- インストーラが `/etc/sudoers.d/mac-disablesleep` に以下の1行だけを追加します:

  ```
  <あなた> ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1
  ```

  この2つの厳密なコマンドに**だけ**パスワード不要の root を許可します。それ以外は不可。

## 手動で実行する場合

```sh
sudo pmset -a disablesleep 1   # スリープ無効（フタを閉じても起きたまま）
sudo pmset -a disablesleep 0   # 通常に戻す
pmset -g | grep SleepDisabled  # 現在の状態を確認
```

## アンインストール

```sh
./uninstall.sh
```

通常スリープに戻し、アプリと sudoers ルールを削除します。

## セキュリティについて

- sudoers ルールは最小限です。任意の `pmset` サブコマンドは実行できず、
  `disablesleep 0` / `disablesleep 1` のみに限定されます。
- アプリは未署名で配布されます（Apple Developer アカウント不要）。気になる場合は
  自分でソースからビルドしてください。

## ライセンス

[MIT](LICENSE)
