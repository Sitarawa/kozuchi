# Rails公式イメージはない
FROM ruby:2.6.6

# yarnをインストール
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# 標準でインストールされるnodejs 10.24は互換性がない。nodejs 16をインストール
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

RUN apt update -qq && apt upgrade -y
RUN apt install -y build-essential nodejs yarn git

# 小槌の実行ディレクトリ
RUN mkdir /kozuchi
WORKDIR /kozuchi

# release-3.1.1
RUN git clone https://github.com/nay/kozuchi.git -b release-3.1.1

# cloneしたkozuchiディレクトリに入る
WORKDIR kozuchi

RUN bundle install

COPY database.yml config/database.yml

# コンテナ起動時に実行するファイルを配置して実行権限をつける
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

#RUN rails db:create
#RUN rails db:migrate

RUN rails webpacker:install
RUN rails webpacker:compile
RUN rails assets:precompile

# コンテナの実行ファイルの指定
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]