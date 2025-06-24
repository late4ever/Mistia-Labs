---
icon: material/key-chain
---

# 🔑 Automating the Vault Password

!!! abstract "Overview"
    This guide explains how to automate providing the Ansible Vault password by using a vault password file. This allows you to run playbooks without being interactively prompted for a password, which is essential for scripting and automation.

!!! warning "Security Consideration"
    This method involves storing your vault password in a plaintext file on your control node's filesystem. It is critical that you set the correct file permissions (`600`) to ensure only your user account can read it.

## Step 1: Create the Vault Password File

1. From your WSL terminal, navigate into your Ansible project directory:

    ```bash
    cd ~/Mistia-Labs/ansible
    ```

2. Create a new file to store the password. It's conventional to name it `.vault_pass`.

    ```bash
    # Create the file and paste your vault password into it.
    # Make sure there are no extra spaces or newlines.
    echo "YourVaultPassword" > .vault_pass
    ```

3. **Set Strict Permissions.** This is the most important step. This command ensures that only your user can read the file.

    ```bash
    chmod 600 .vault_pass
    ```

## Step 2: Update `.gitignore`

To ensure you never accidentally commit your password file to the Git repository, add it to your main `.gitignore` file.

1. Open the `.gitignore` file at the root of your `Mistia-Labs` repository.
2. Add the following line:

    ```gitignore
    # Ignore Ansible vault password file
    ansible/.vault_pass
    ```

## Step 3: Configure Ansible to Use the File

Now, we need to tell Ansible where to find this password file by updating the `ansible.cfg` file.

1. Open `ansible/ansible.cfg` in your editor.
2. Add the `vault_password_file` line to the `[defaults]` section.

    ```ini
    [defaults]
    inventory = ./inventory.ini
    host_key_checking = False
    vault_password_file = ./.vault_pass
    ```

## Step 4: Run Your Playbook

You can now run your playbooks without the `--ask-vault-pass` flag. Ansible will automatically and securely read the password from the file you created.

```bash
# Navigate to your ansible directory
cd ~/Mistia-Labs/ansible

# Run the playbook - no password prompt!
ansible-playbook deploy_services.yml
