#!/usr/bin/env bash

# script: macos.sh
# brief : macOS のシステム既定値 (defaults) を好みの状態へ設定する。
#   すべて冪等 (defaults write は再実行安全)。表示系・入力系のみを対象とし、
#   破壊的な変更は行わない。Darwin 以外では何もしない。
# usage : bash macos.sh

set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "macos.sh: not macOS; skipping"
  exit 0
fi

echo "==> Applying macOS defaults ..."

# --- キーボード / 入力 ---------------------------------------------------------
# キーリピートを高速化 (vim 等での hjkl 移動が快適になる)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# キー長押し時のアクセント候補表示を無効化 (押しっぱなしでリピートさせる)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# --- Finder ------------------------------------------------------------------
# 隠しファイルを表示
defaults write com.apple.finder AppleShowAllFiles -bool true
# 全ての拡張子を表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# パスバー / ステータスバーを表示
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
# 拡張子変更時の警告を出さない
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# 既定の検索範囲を「現在のフォルダ」にする
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# --- スクリーンショット -------------------------------------------------------
# 保存先を ~/Pictures/Screenshots に変更し、影を付けない
screenshot_dir="${HOME}/Pictures/Screenshots"
mkdir -p "$screenshot_dir"
defaults write com.apple.screencapture location -string "$screenshot_dir"
defaults write com.apple.screencapture disable-shadow -bool true

# --- ネットワーク / ディスク --------------------------------------------------
# ネットワーク / USB ボリュームに .DS_Store を作らない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --- 反映 --------------------------------------------------------------------
# 変更を反映するため関連プロセスを再起動する (起動していなければ無視)
for app in Finder Dock SystemUIServer; do
  killall "$app" >/dev/null 2>&1 || true
done

echo "==> macOS defaults applied. 一部の設定は再ログイン後に反映されます。"
