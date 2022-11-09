# README

## 工夫した点

- RSSによるクローリング（Feedfira利用）の際に，
  1. バルクインサート（activerecord-import）を使用したこと
     - 1回のSQL文で複数行のデータをINSERTし，効率的に
  2. ニュースに紐づくタグ情報も同時に取得し，DB内で紐づけて保存することで，タグの用意と，ニュースとタグの紐付けを行う工数を削減できたこと
- タグによる検索（ファセット）でヒットする記事数を毎回計算しないよう，企業数を格納するカラムの作成とバッチ処理用のrakeコマンド用意
- 表示非表示機能に論理削除（paranoia）を使用し，状態の切り替えを容易にしたこと
- 最初のサービス立ち上げ時にデータが自動的に入るよう，migrationファイルにrakeタスクの実行コマンドを仕込み，立ち上げ時のコマンド数を削減したこと
- 管理者画面のRails単体のアプリケーションでも操作感を良くしたいと思い，Hotwireを使用し，一部SPA化したこと

## 課題点

- Active Model Serializerがうまく導入できず，APIに不必要な値まで返してしまっている．
  - → 必要な値のみを返す安全性の高いAPIにしたい
- APIコントローラーと，管理者用のRailsアプリケーションを分割（マイクロサービス化）したい．
  - APIコントローラーで十分な点，マイクロサービスアーキテクチャと相性が良い点から，Goで実装できたら良さそう．
  - → デプロイ独立性を上げたい
- 提出締め切りまでギリギリだったことを理由にRspecを書いていない
  - → テストをしっかり書き，安全性を高める必要がある
- delayed_jobを導入できていない
  - → 多くのユーザーに利用される運用を想定し，非同期処理を走らせることで，負荷を軽減したい
- タグに紐づく記事数の計算時，タグの数分Elasticsearchにクエリを発行してしまう
  - Elasticsearchのaggregationsを使うことで，一括で取得可能であることが判明
