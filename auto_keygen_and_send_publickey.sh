#!/bin/bash
set -eu

# 引数が異常な場合、利用方法を表示して処理を終了する
arg_error() {
    echo "[ERROR]  usage: ./auto_keygen_and_put_publickey.sh [-h remote_host_ipaddress] [-u user_name] [-k key_name]"
    echo "[ERROR]  required arg --->  '-h', '-u'"
    echo "[ERROR]  optional arg --->  '-k' (default key name: id_rsa_by_auto_keygen)"
    exit 1
}

# 同じ名前のkeyがすでに存在する場合のエラーメッセージ
key_name_error() {
    echo "[ERROR]  A key with the same name ($ARG_KEY_NAME) already exists in ~/.ssh/"
    echo "[ERROR]  Please specify a different key name for the '-k' arg."
    exit 1
}

SSH_DIR=~/.ssh
SSH_CONF_DIR=~/.ssh/conf.d
# コマンド引数を格納する変数を定義
ARG_USER_NAME=
ARG_REMOTE_HOST=
ARG_KEY_NAME=id_rsa_by_auto_keygen

# ---------------- コマンド引数の判定＆格納 ----------------
# 引数が空の場合はエラー
if [ $# = 0 ]; then
    arg_error
fi

# getoptsを使用して指定された引数の値を変数に格納
while getopts "h:u:k:" opt; do
    case $opt in
    h)  # required
        ARG_REMOTE_HOST=$OPTARG
        ;;
    u)  # required
        ARG_USER_NAME=$OPTARG
        ;;
    k)
        ARG_KEY_NAME=$OPTARG
        ;;
    *)
        # 指定された引数が定義されたものではない場合、エラーメッセージを表示
        arg_error
        ;;
    esac
done

# 必須の値が空の場合、エラー
if [ -z "$ARG_REMOTE_HOST" ] || [ -z "$ARG_USER_NAME" ]; then
    arg_error
fi

# すでに同じ名前のkeyがある場合、上書きではなくエラー扱いとする(後続のconfigファイルを作るので)
if [ -e "$SSH_DIR/$ARG_KEY_NAME" ]; then
    key_name_error
fi

echo "[INFO] Start processing."


# ---------------- ディレクトリ作成 ----------------
# ~/.sshディレクトリ存在確認
if [ ! -d "$SSH_DIR" ]; then
    # なければ作る
    mkdir -m 700 "$SSH_DIR"
    echo "[INFO] Created $SSH_DIR directory."
fi

# ~/.ssh/conf.d/ディレクトリ存在確認
if [ ! -d "$SSH_CONF_DIR" ]; then
    # なければ作る
    mkdir -m 700 "$SSH_CONF_DIR"
    echo "[INFO] Created $SSH_CONF_DIR directory."
fi

# ---------------- .ssh/configにincludeディレティブを追記 ----------------
# .ssh/conf.d配下のconfigの内容を読み込めるようにするため、.ssh/configにIncludeを追記

INCLUDE_DIRECTIVE="Include ~/.ssh/conf.d/*"

# すでにIncludeの記述があればスキップ
if ! grep ^"$INCLUDE_DIRECTIVE" "$SSH_DIR"/config; then
    # sedコマンドで追加する方法もあるが、GNUと非GNU（macOS等）ではsedのオプションの挙動が異なるため、printfを採用
    printf '%s\n' 0a "$INCLUDE_DIRECTIVE" . x | ex "$SSH_DIR"/config
fi

# ---------------- key-pair作成 ----------------
echo "[INFO] Created key name: $ARG_KEY_NAME"
ssh-keygen -N "" -f ~/.ssh/"$ARG_KEY_NAME"

echo "[INFO] Key generation is complete."

# ---------------- リモートサーバに公開鍵を転送 ----------------
echo "[INFO] Start ssh-copy-id."
ssh-copy-id -i ~/.ssh/"$ARG_KEY_NAME".pub "$ARG_USER_NAME"@"$ARG_REMOTE_HOST"

# リモートサーバにssh接続できる場合、ARG_USER_NAMEのパスワードの入力が求められる

# ---------------- configファイルの作成 ----------------
# ‘ssh <リモートサーバ名>‘ だけでsshできるように設定ファイルを作る（作成したkeyと同じ名前で作成する）
#  configファイルは ‘~/.ssh/conf.d‘ 配下に作成する
echo "[INFO] Start creating config file."

cat <<EOF >~/.ssh/conf.d/"$ARG_KEY_NAME"
Host $ARG_KEY_NAME
    Hostname $ARG_REMOTE_HOST
    User $ARG_USER_NAME
    IdentityFile ~/.ssh/$ARG_KEY_NAME
EOF

echo "[INFO] Process completed successfully."
echo "[INFO] Try the command to verify public key authentication ---->  ssh $ARG_REMOTE_HOST"
exit 0
