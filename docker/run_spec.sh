#!/bin/bash
# 手元のソースで rspec を実行する（本番の DB・コンテナには触れない）
#
#   docker/run_spec.sh                                 # 全テスト
#   docker/run_spec.sh spec/features/deals_spec.rb     # ファイル指定
#
# 一時的なネットワークと PostgreSQL コンテナを作り、rails_kozuchi のイメージ（gem 入り）に
# 手元のソースをマウントしてテストする。終了時に一時コンテナ・ネットワークは削除する。
# JS を使う feature spec (js: true) は Chrome が無いため動かない。
set -u
NET=kozuchi-spec-net
DB=kozuchi-spec-db  # URI のホスト名になるのでアンダースコア不可
SRC=$(cd "$(dirname "$0")/.." && pwd)
IMAGE=${KOZUCHI_SPEC_IMAGE:-docker-rails_kozuchi}

cleanup() { docker rm -f $DB >/dev/null 2>&1; docker network rm $NET >/dev/null 2>&1; }
trap cleanup EXIT

docker network create $NET >/dev/null
docker run -d --name $DB --network $NET -e POSTGRES_PASSWORD=spec postgres:13 >/dev/null
until docker exec $DB pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
sleep 2

# tmp・log・node_modules・ビルド済みアセットはイメージ側のものを使う
docker run --rm --network $NET \
  -v "$SRC":/src:ro \
  -e RAILS_ENV=test \
  -e DATABASE_URL=postgres://postgres:spec@$DB/kozuchi_test \
  -e DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL=true \
  --entrypoint bash "$IMAGE" -c '
    set -e
    cd /kozuchi/kozuchi
    tar -C /src -cf - \
      --exclude=./.git --exclude=./docker --exclude=./tmp --exclude=./log --exclude=./node_modules \
      --exclude=./public/assets --exclude=./app/assets/builds --exclude=./config/database.yml --exclude=./config/puma.rb \
      . | tar -xf -
    # pg_dump が無いので migrate 後のスキーマダンプは失敗するが、テストには不要
    bin/rails db:create db:migrate >/dev/null 2>&1 || bin/rails db:migrate:status | tail -1
    bundle exec rspec "$@"' _ "$@"
