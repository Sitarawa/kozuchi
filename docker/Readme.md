# docker for Kozuchi

Web家計簿小槌(https://github.com/nay/kozuchi) 用docker-composeファイルです。

個人的に長年家計簿をつけるのに小槌を愛用しているのですが、  
環境構築、バージョンアップが難しいと感じているので、  
dockerで簡単に環境を立ち上げられるようにしました。

Railsについては素人のため、試行錯誤した結果動作するところまで確認したファイルですが  
より良い設定などの指摘歓迎します。

## 準備

docker、およびdocker-composeが動作する環境

### 動作確認した環境
- Windows11 Dockerversion 20.10.12, build e91ed57
- RaspberryPi3 Raspibian 10 Buster docker 20.10.12

## 実行手順

```
git clone https://github.com/Sitarawa/kozuchi.git
cd kozuchi/docker
cp .env.example .env
docker-compose build rails_kozuchi
docker-compose run --rm rails_kozuchi rails secret
 -> 実行結果のランダム文字列を .env の SECRET_KEY_BASE に設定する
docker-compose up -d
  初回実行時は時間がかかります。
http://localhost:3000/にアクセス
"アカウントを登録して使い始める(無料)"をクリック、アカウントを作成する
```

## 最低限の設定

### .env ファイル

機密情報は `.env.example` をコピーして作成した `.env` ファイルに設定します。  
`.env` はGit管理対象外のため、各自の環境で作成してください。

- SECRET_KEY_BASE  
`docker-compose run --rm rails_kozuchi rails secret` の結果の値をセットする

- KOZUCHI_DATABASE_PASSWORD  
PostgreSQLのパスワード（任意の文字列）


## その他の設定

### 環境変数

https://github.com/nay/kozuchi/wiki/%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0  
に記載されている環境変数で必要なものをrails_kozuchiのenvironment配下の  
環境変数設定に追記してください。

### HTTPS (SSL) の設定

Let's Encrypt などで取得した証明書を使って HTTPS でアクセスできます。

**前提条件**
- ドメインを取得済みであること
- Let's Encrypt の証明書がホストの `/etc/letsencrypt/live/<ドメイン名>/` に配置済みであること

**設定手順**

1. `.env` に証明書パスを追加する

```
SSL_KEY_PATH=/etc/letsencrypt/live/your.domain.example.com/privkey.pem
SSL_CERT_PATH=/etc/letsencrypt/live/your.domain.example.com/fullchain.pem
```

2. `docker-compose.yml` の `KOZUCHI_SSL` がすでに `"true"` に設定されていることを確認する

3. ポート 443 を開放してコンテナを起動する

```
docker-compose up -d
```

4. `https://your.domain.example.com/` にアクセスする

### database.yml

データベース名、ユーザ名、パスワード、ホスト名など  
docker-compose.ymlのデータベースの設定を変更した場合はそれに合わせて変更してください。


## 補足

- Raspibianでrails_kozuchiのimageのbuildがうまくいかない
メモリ不足で途中でプロセスがkillされ、nokogiri, sasscなどのビルド途中で中断することがありました。
一時的に不要なプロセスを止める、swapを増やすなどで回避できると思われます。



## 参考：データのバックアップ

サービスが停止した状態で
```
docker run --rm -v "$PWD/:/backup" -v volume_kozuchi_db:/var/lib/postgresql/data busybox tar cvf /backup/backup.tar /var/lib/postgresql/data
```
→ カレントディレクトリにbackup.tarが生成されます。

## 参考：バックアップしたデータのリストア

```
docker volume rm volume_kozuchi_db
docker run --rm -v "$PWD/:/backup" -v volume_kozuchi_db:/var/lib/postgresql/data busybox tar xvf /backup/backup.tar
```