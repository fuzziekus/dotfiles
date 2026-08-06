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
- **Tmux** — prefix を `C-s` に変更、vim 風ペイン移動、TPM によるセッション永続化
  (resurrect/continuum で再起動後もペイン構成を自動復元)
- **Vim**
- **Git** — [delta](https://github.com/dandavison/delta) による構造化 diff (未導入時は less にフォールバック)

初回 tmux 起動時に TPM が自動 clone されます。プラグインの取得は `prefix + I`、
セッション保存/復元は `prefix + S` / `prefix + R`。macOS では `make init` 実行時に
キーリピート高速化・Finder 表示などの `defaults` を併せて適用します。

## 使い方 (Makefile)
```bash
make help     # タスク一覧を表示
make deploy   # $HOME にシンボリックリンクを作成 (既存ファイルは自動バックアップ)
make init     # OS を判定してパッケージを導入
make test     # shellcheck + zsh -n による構文チェック
make install  # update → deploy → init を一括実行
make clean    # 当リポジトリが張ったリンクのみ削除 (FORCE=1 でリポジトリ本体も削除)
```

`make deploy` は冪等で、既存の実ファイルは上書きせず `~/.dotfiles_backup/<日時>/` へ退避してからリンクを張ります。`make clean` は当リポジトリを指すシンボリックリンクだけを削除し、無関係な実ファイルには触れません。

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

## 開発 (コントリビュート)
lint/format は [pre-commit](https://pre-commit.com/) で自動化しています。ツールは [mise](https://mise.jdx.dev/) の `mise.toml` でバージョン固定されます。

```bash
mise install            # pre-commit を導入
pre-commit install      # commit 時に自動実行するフックを登録
pre-commit run --all-files   # 手動で全ファイルをチェック
```

- **shellcheck** — bash スクリプト (`src/init/`) の静的解析
- **shfmt** — bash スクリプトの整形 (indent 2)
- **zsh -n** — zsh rc の構文チェック
- **.editorconfig** — エディタ横断のインデント/改行規約

CI(`make test` / pre-commit / deploy スモーク)は push・PR で自動実行されます。
