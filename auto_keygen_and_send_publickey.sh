#!/bin/bash
set -eu

# If the arguments are incorrect, display usage instructions and exit
arg_error() {
    echo "[ERROR]  usage: ./auto_keygen_and_put_publickey.sh [-h remote_host_ipaddress] [-u user_name] [-k key_name]"
    echo "[ERROR]  required arg --->  '-h', '-u'"
    echo "[ERROR]  optional arg --->  '-k' (default key name: id_rsa_by_auto_keygen)"
    exit 1
}

# Error message if a key with the same name already exists
key_name_error() {
    echo "[ERROR]  A key with the same name ($ARG_KEY_NAME) already exists in ~/.ssh/"
    echo "[ERROR]  Please specify a different key name for the '-k' arg."
    exit 1
}

SSH_DIR=~/.ssh
SSH_CONF_DIR=~/.ssh/conf.d
ARG_USER_NAME=
ARG_REMOTE_HOST=
ARG_KEY_NAME=id_rsa_by_auto_keygen

# ---------------- Determine and store command arguments ----------------
# Error if no arguments are provided
if [ $# = 0 ]; then
    arg_error
fi

# Use getopts to store the specified argument values in variables
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
        # If an undefined argument is specified, display an error message
        arg_error
        ;;
    esac
done

# Error if required values are missing
if [ -z "$ARG_REMOTE_HOST" ] || [ -z "$ARG_USER_NAME" ]; then
    arg_error
fi

# Treat it as an error, not an overwrite, if a key with the same name already exists (because the subsequent config file is created)
if [ -e "$SSH_DIR/$ARG_KEY_NAME" ]; then
    key_name_error
fi

echo "[INFO] Start processing."


# ---------------- Create directories ----------------
# Check if ~/.ssh directory exists
if [ ! -d "$SSH_DIR" ]; then
    mkdir -m 700 "$SSH_DIR"
    echo "[INFO] Created $SSH_DIR directory."
fi

# Check if ~/.ssh/conf.d/ directory exists
if [ ! -d "$SSH_CONF_DIR" ]; then
    mkdir -m 700 "$SSH_CONF_DIR"
    echo "[INFO] Created $SSH_CONF_DIR directory."
fi

# ---------------- Append Include directive to .ssh/config ----------------
# To read the content of config files under .ssh/conf.d/, add Include to .ssh/config
INCLUDE_DIRECTIVE="Include ~/.ssh/conf.d/*"

# Skip if Include directive already exists
if ! grep ^"$INCLUDE_DIRECTIVE" "$SSH_DIR"/config; then
    # Although sed command could be used to add, GNU and non-GNU (e.g., macOS) sed options behave differently,
    # so printf is used
    printf '%s\n' 0a "$INCLUDE_DIRECTIVE" . x | ex "$SSH_DIR"/config
fi

# ---------------- Generate key-pair ----------------
echo "[INFO] Created key name: $ARG_KEY_NAME"
ssh-keygen -N "" -f ~/.ssh/"$ARG_KEY_NAME"

echo "[INFO] Key generation is complete."

# ---------------- Transfer public key to remote server ----------------
echo "[INFO] Start ssh-copy-id."
ssh-copy-id -i ~/.ssh/"$ARG_KEY_NAME".pub "$ARG_USER_NAME"@"$ARG_REMOTE_HOST"

# If ssh connection to the remote server is possible, it will prompt for ARG_USER_NAME's password

# ---------------- Create config file ----------------
# Create a config file to allow ssh with just 'ssh <remote server name>' (create using the same name as the created key)
# Create the config file in '~/.ssh/conf.d'
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
