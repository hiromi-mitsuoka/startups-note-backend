#!/bin/bash
# Shebangによるインタプリタの指定

# set : シェルの設定を確認・変更するコマンド
# -e(errexit) : コマンドが1つでもエラーになったら直ちにシェルを終了( https://atmarkit.itmedia.co.jp/ait/articles/1805/10/news023.html )
set -e

rm -f /startups/tmp/pids/server.pid

# exec : 同じプロセス内で外部コマンドが実行される
# $@ : 位置パラメータを展開
# entrypoint.sh自体の親プロセスを展開したそれぞれの引数の実行結果に置き換えてコマンドラインへ出力し、
# entrypoint.shの実行以降の処理に進ませる
exec "$@"