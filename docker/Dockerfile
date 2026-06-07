# Rails公式イメージはない (ruby:3.4.9 のベースは Debian 12 bookworm)
FROM ruby:3.4.9

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

# release-4.0.1
RUN git clone https://github.com/nay/kozuchi.git -b release-4.0.1 --depth 1

# cloneしたkozuchiディレクトリに入る
WORKDIR kozuchi

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
