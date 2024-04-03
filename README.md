# auto_keygen_and_send_publickey

## Overview
This tool, auto_keygen_and_put_publickey.sh, automates the process of generating an SSH key pair and transferring the public key to a specified remote server. This simplifies the setup of SSH key-based authentication, making it quicker and reducing the potential for manual errors.

## Requirements
- Bash environment
- SSH client installed on the local machine
- `ssh-keygen` and `ssh-copy-id` tools available
- Access to the remote server with the specified user account

## Usage
### Basic Command

```bash
./auto_keygen_and_put_publickey.sh -h [remote_host_ipaddress] -u [user_name] [-k key_name]
```
### Arguments
- `-h` (required): Specifies the IP address or hostname of the remote server.
- `-u` (required): Specifies the username on the remote server.
- `-k` (optional): Specifies the name of the key to be created. Defaults to id_rsa_by_auto_keygen if not provided.

### Examples
- To generate a key with the default name and copy it to the user admin on the server 192.168.1.100:
```
./auto_keygen_and_put_publickey.sh -h 192.168.1.100 -u admin
```

- To specify a custom key name:
```
./auto_keygen_and_put_publickey.sh -h 192.168.1.100 -u admin -k my_custom_key
```

## Features
- Key Generation:
  - Automatically generates an SSH key pair in the ~/.ssh directory of the local user.
- Public Key Transfer
  - Utilizes ssh-copy-id to securely transfer the public key to the specified remote server.
- Configuration Management:
  - Automatically creates and manages SSH configuration for easy access by appending an Include directive to `~/.ssh/config` and creating specific host configurations in `~/.ssh/conf.d/`.

## Error Handling
- Validates required arguments and displays usage instructions if any are missing or incorrect.
- Prevents overwriting existing keys by checking for key name conflicts before proceeding with key generation.
- Ensures the local SSH configuration is correctly updated to include custom configurations.

## Security Considerations
- The script does not handle the secure storage or generation of passphrase for SSH keys. Users are encouraged to follow best practices for SSH key management.
- Ensure that the username and remote host provided are correct to avoid unintentional access or key copying.

## Troubleshooting
- If the script fails to connect to the remote server, verify that the server is accessible over the network and that the specified user has SSH access.
- For issues with key permissions or authentication, check the SSH server configuration and the permissions of the ~/.ssh directory and its contents on both the local and remote machines.

## License
Specify the license under which this tool is released, ensuring users understand their rights to use, modify, and distribute the script.






