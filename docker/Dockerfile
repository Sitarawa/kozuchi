# 小槌のソースの取得方法 (build arg で切り替える)
#   git   : GitHub から clone する（本番用、既定）
#   local : 手元のソースをコピーする（動作確認用。docker-compose.yml の rails_kozuchi_local を参照）
ARG KOZUCHI_SOURCE=git

# Rails公式イメージはない (ruby:4.0.7 のベースは Debian 13 trixie)
FROM ruby:4.0.7 AS base

# jsbundling-rails / esbuild で JS をビルドするため Node.js 20 (LTS) をインストール
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

RUN apt-get update -qq && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      build-essential \
      nodejs \
      git \
      libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# yarn.lock が v1 形式のため classic yarn (1.x) をインストール
RUN npm install -g yarn

# 小槌の実行ディレクトリ
RUN mkdir /kozuchi
WORKDIR /kozuchi

# --- ソース取得: git ---
FROM base AS source-git
# release-4.0.5 に Sitarawa の修正を加えたもの
RUN git clone https://github.com/Sitarawa/kozuchi.git -b release-4.0.5-sitarawa.1 --depth 1

# --- ソース取得: local ---
# kozuchi_src はビルド時に追加コンテキストとしてリポジトリのルートを渡す
# 除外するファイルはリポジトリのルートの .dockerignore で指定する
FROM base AS source-local
COPY --from=kozuchi_src . kozuchi

# --- 共通 ---
FROM source-${KOZUCHI_SOURCE}

# kozuchiディレクトリに入る
WORKDIR /kozuchi/kozuchi

RUN bundle install

# JSの依存をインストール (esbuild など)
RUN yarn install

COPY database.yml config/database.yml
COPY puma.rb config/puma.rb

# コンテナ起動時に実行するファイルを配置して実行権限をつける
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

#RUN rails db:create
#RUN rails db:migrate

# jsbundling-rails が assets:precompile 時に yarn build (esbuild) を実行する
RUN rails assets:precompile

RUN mkdir -p tmp/pids

# コンテナの実行ファイルの指定
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
EXPOSE 443

#CMD ["rails", "server", "-b", "0.0.0.0"]
CMD ["bundle", "exec", "pumactl", "start"]
