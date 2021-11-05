# FROM : ベースとなるDockerImageを指定
FROM ruby:2.7.1

# RUN : Docker内でコマンド実行
# コンテナへ依存するライブラリやパッケージのインストールやユーザーの設定などの処理を実行
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# apt-get [スイッチ] [オプション] [パッケージ] : Debian系のディストリビューション（DebianやUbuntu）のパッケージ管理システムであるAPT(Advanced Package Tool)ライブラリを利用してパッケージの操作・管理を行うLinuxコマンド
# オプション -qq : エラー以外は表示しない( http://www.ne.jp/asahi/it/life/it/linux/linux_command/linux_apt-get.html )
RUN apt-get update -qq && apt-get install -y nodejs yarn
# credentials:editを利用するためにvimをdockerに追加
RUN apt-get install -y vim
RUN mkdir /startups
WORKDIR /startups

# COPY [ホスト側のディレクトリ]　[Docker側のディレクトリ] : Docker内へホストのファイル・ディレクトリをコピー( https://y-ohgi.com/introduction-docker/2_component/dockerfile/#copy )
COPY Gemfile /startups/Gemfile
COPY Gemfile.lock /startups/Gemfile.lock
RUN bundle install
COPY . /startups

COPY entrypoint.sh /usr/bin/

# 実行(x)権限追加
RUN chmod +x /usr/bin/entrypoint.sh

# ENTRYPOINT : 指定されたコマンドを実行( https://y-ohgi.com/introduction-docker/2_component/dockerfile/#entrypoint )
# CMDとは異なり、docker run 時に指定したコマンドを ENTRYPOINT の引数として使用
ENTRYPOINT ["entrypoint.sh"]

# コンテナ起動時に公開することを想定されているポートを記述( https://y-ohgi.com/introduction-docker/2_component/dockerfile/#expose )
EXPOSE 3000

# Docker起動時にデフォルトで実行されるコマンド( https://y-ohgi.com/introduction-docker/2_component/dockerfile/#cmd )
# -b = --binding : ipアドレスにバインドする( https://qiita.com/Masato338/items/f162394fbc37fc490dfb )
# 0.0.0.0 : 全てのネットワーク・インターフェースを意味。別ホストからアクセス可能( https://qiita.com/1ain2/items/194a9372798eaef6c5ab )
CMD ["rails", "server" , "-b", "0.0.0.0"]
