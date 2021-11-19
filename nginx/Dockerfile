# # NOTE: バージョンは調査していない
# FROM nginx:1.19.1

# # conf.d/default.confを削除
# # RUN rm -f /etc/nginx/conf.d/*

# # unix:/startups/tmp/sockets/puma.sock failed (2: No such file or directory) 対応、コンテナ入り確認したところsocketsディレクトリが存在しなかった
# # RUN mkdir -p /startups/tmp/sockets

# # /startups でコマンド叩く想定、localのnginx.confの内容をコンテナに追加
# ADD nginx.conf /etc/nginx/nginx.conf
# ADD startups.conf /etc/nginx/conf.d/startups.conf
# # nginxをフォアグラウンドで動作させる、バックグラウンドで動かすとコンテナが終了する
# CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf

# EXPOSE 80

# NOTE: test
FROM nginx:1.15.8

RUN rm -f /etc/nginx/conf.d/*

ADD nginx.conf /etc/nginx/conf.d/startups.conf
CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf