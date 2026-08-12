# dotfiles

macOS / Linux 両対応の個人用 dotfiles。zsh を中心に、XDG Base Directory 準拠・起動高速化・モダン CLI ツールへの自動フォールバックを備えています。

## クイックスタート
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/fuzziekus/dotfiles/master/src/init/install)"
```

> URL 中の `master` はこのリポジトリのデフォルトブランチ名です。別ブランチから
> 入れる場合は URL のブランチ名を変え、`DOTFILE_BRANCH=<branch>` も指定します。

インストーラはモードを取れます (既定は `init`)。パッケージ導入 (sudo 昇格を伴う)
を避け、シンボリックリンクの作成だけ行いたい場合は `deploy` を使います。

```bash
# リンク作成のみ (パッケージ導入なし)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/fuzziekus/dotfiles/master/src/init/install)" -- deploy
```

対話端末で `init` を実行するとパッケージ導入の前に確認を求めます。自動化時は
`ASSUME_YES=1` で確認をスキップできます。`bash -c "$(...)" -- help` で全モードを表示します。

## 必要要件
- zsh 5.0+
- git
- tmux (optional)

インストール時に `make init` が OS を判定し、パッケージ (`src/init/asset/<distro>`) を導入します。主なもの: coreutils, git, tmux, vim, direnv, fzf, ghq, pet, eza, ripgrep, bat, fd。

## 含まれる設定
- **Zsh** — zinit (zdharma-continuum) によるプラグイン管理、turbo モードでの遅延ロード。
  fzf / ghq / pet / zoxide / starship / **lazygit** (git TUI・`lg` で起動) などの CLI は
  GitHub Release バイナリを zinit の `gh-r` で取得するため apt/sudo 不要
- **Tmux** — prefix を `C-s` に変更、vim 風ペイン移動、TPM によるセッション永続化
  (resurrect/continuum で再起動後もペイン構成を自動復元)
- **Vim**
- **Git** — [delta](https://github.com/dandavison/delta) による構造化 diff (未導入時は less にフォールバック)。個人情報 (氏名 / メール / GPG 署名鍵) は `~/.gitconfig.local` に分離 (「カスタマイズ」参照)

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
対話シェルで利用できる fzf ベースのウィジェット (fzf 未導入時はこれらのキーは
無効で、`fzf.zsh` はロードされません):

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
- `~/.gitconfig.local` — 個人情報 (氏名 / メール / GPG 署名鍵) やマシン固有の git 設定

個人情報は追跡対象の `src/.gitconfig` には含めず、`~/.gitconfig.local`（git 管理外）へ
分離しています。`~/.gitconfig` の末尾から include されるため、ここに書いた設定は
リポジトリ側のどの設定も上書きできます。新しいマシンではテンプレートをコピーして設定します:

```bash
cp ~/.config/dotfiles/src/.gitconfig.local.example ~/.gitconfig.local
# 氏名 / メール / signingkey を自分の値に編集
```

ファイルが無い場合 git は include を黙って無視するため、未設定でも問題なく動作します。

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

CI は `master`/`main` への push・PR で自動実行されます (lint / shellcheck /
`make test` / deploy スモーク、および macOS での `make test` + deploy スモーク)。

手元で警告レベルまで含めた追加チェックを行う場合は `mise run lint-strict` を実行
します (CI は誤検知を避けるため error 相当のみで失敗させます)。

> 補足: `src/.gitconfig` の `puhs` / `psuh` / `pus` / `puh` は `git push` のタイプミス
> 救済用に**意図的に**用意した別名です。
