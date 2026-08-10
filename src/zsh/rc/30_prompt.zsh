# prompt 設定
#
# プロンプトは starship が管理する (導入は 70_plugin.zsh、初期化は
# 99_post_load.zsh、見た目は $ZDOTDIR/starship.toml)。
# 従来の vcs_info ベースの独自プロンプトは starship へ完全移行したため撤去した
# (git 履歴に残っているので必要なら参照可能)。

# コマンド確定時に「過去の行」の右プロンプトを消去する。
# → スクロールバックをコピー & ペーストしても右プロンプト (git 情報や k8s /
#   時刻) がノイズとして混入しない。右プロンプトは常に現在の入力行のみ表示。
# starship が設定する RPROMPT (right_format) にもそのまま効く。
setopt transient_rprompt
