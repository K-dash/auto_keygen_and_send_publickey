# auto_keygen_and_send_publickey

## これはなに？
リモートサーバにsshで公開鍵認証を行うために必要な以下の操作を自動化するスクリプト
1. クライアントマシンでキーペアを生成する
2. クライアントマシンからリモートホストへ公開鍵を転送して登録する(ssh-copy-idコマンドを使用)
3. `~/.ssh/config.d/`配下に生成した秘密鍵の情報を登録 （`ssh <リモートホスト名>`だけで接続できるようにするための設定）

    ※configファイルは本スクリプトによって自動生成される

## 前提条件
- リモートサーバのsshdで公開鍵認証が有効になっていること
- `ssh-copy-id`コマンドが使用できること

## 使い方
WIP
