# dotfiles

macOS / Linux 両対応の個人用 dotfiles。zsh を中心に、XDG Base Directory 準拠・起動高速化・モダン CLI ツールへの自動フォールバックを備えています。

## クイックスタート
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/fuzziekus/dotfiles/master/src/init/install)"
```

## 必要要件
- zsh 5.0+
- git
- tmux (optional)

インストール時に `make init` が OS を判定し、パッケージ (`src/init/asset/<distro>`) を導入します。主なもの: coreutils, git, tmux, vim, direnv, fzf, ghq, pet, eza, ripgrep, bat, fd。

## 含まれる設定
- **Zsh** — zinit (zdharma-continuum) によるプラグイン管理、turbo モードでの遅延ロード
- **Tmux** — prefix を `C-s` に変更、vim 風ペイン移動
- **Vim**
- **Git**

## 使い方 (Makefile)
```bash
make help     # タスク一覧を表示
make deploy   # $HOME にシンボリックリンクを作成
make init     # OS を判定してパッケージを導入
make test     # shellcheck + zsh -n による構文チェック
make install  # update → deploy → init を一括実行
```

## 主なキーバインド (zsh)
対話シェルで利用できる fzf ベースのウィジェット:

| キー   | 機能                                       |
|--------|--------------------------------------------|
| `^r`   | 履歴をインクリメンタル検索                 |
| `^s`   | ghq 管理リポジトリへ `cd`                  |
| `^b`   | git ブランチを選択して checkout            |
| `^g`   | ファイル名を検索してコマンドラインへ挿入   |
| `^o`   | ghq リポジトリへのシンボリックリンクを作成 |
| `^\`   | `~/.ssh/config` の Host を選んで ssh        |
| `^l`   | kubectl pod/container のログを表示          |
| `^k`   | kubectl pod/container へ exec               |

## パフォーマンス
- `brew shellenv` / `mise activate` の初期化結果をキャッシュし、バイナリ更新時のみ再生成
- `compinit` は 24h 以内なら監査 (compaudit) をスキップ
- zinit の `wait lucid` によるプラグイン遅延ロード

## カスタマイズ
- `~/.zshrc.local` — ローカル固有の zsh 設定
- `~/.zshenv.local` — ローカル固有の環境変数
