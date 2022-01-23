#!/bin/bash

# エラーで終了する
set -e

# pidファイルを削除
rm -f /kozuchi/kozuchi/tmp/pids/server.pid

rails db:create
rails db:migrate

# DockrefileのCMDで指定したコマンドを実行する
exec "$@"
