---
icon: simple/ansible
---

# :simple-ansible: Ansible Setup Guide

!!! abstract "Overview"
    This guide outlines the process of setting up Ansible. This provides a more robust, declarative, and idempotent way to manage your services. You will create the Ansible project structure inside your existing `Mistia-Labs` repository.

!!! info "Working Directory"
    All commands should be run from your WSL terminal, inside your activated `(ansible-env)` virtual environment, from the `Mistia-Labs` directory.

## 📂 Create the Ansible Project Structure

First, we will create a dedicated `ansible` directory inside your `Mistia-Labs` repository to hold all configuration files

1. Navigate into your repository in the WSL terminal:

    --8<-- "docs/content/.snippets/ansible.sh:ve"

2. Create the necessary directory and files:

    ```bash
    mkdir -p ansible/templates
    touch ansible/ansible.cfg ansible/inventory.ini ansible/deploy_services.yml
    ```

Your project structure should now look like this:

```text
Mistia-Labs/
└── ansible/
    ├── ansible.cfg                   # <-- Global Ansible settings
    ├── inventory.ini                 # <-- Your master inventory
    └── mistia-nexus/                 # <-- Directory for this specific environment
        ├── ansible.cfg               # <-- Ansible settings
        ├── inventory.ini             # <-- Inventory
        ├── deploy_services.yml       # <-- The main playbook for the nexus
        ├── _deploy_service_loop.yml  # <-- The loop file
        ├── secrets.yml               # <-- Encrypted secrets for the nexus
        ├── .vault_pass               # <-- Vault password file (git-ignored)
        └── templates/                # <-- Templates for nexus services
            ├── caddy.env.j2
            └── ...
```

## 🔑 Configure WSL for SSH Key Authentication

1. **Get Your Private Key:**
    - Open Bitwarden and view your SSH key item ("UGREEN NASync 4800 Plus")
    - Copy the contents of the **private key** to your clipboard

2. **Create the SSH Key File in WSL:**
    - In your WSL terminal, run the following command to open a text editor:

      ```bash
      mkdir -p ~/.ssh
      nano ~/.ssh/id_ed25519
      ```

    - **Paste your private key** into the editor. The key should start with `-----BEGIN OPENSSH PRIVATE KEY-----`
    - ++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

3. **Set Correct Permissions:**

      ```bash
      chmod 600 ~/.ssh/id_ed25519
      ```

4. **Verify**

    ```bash
    --8<-- "docs/content/.snippets/ssh.sh:ssh"
    ```

## ⚙️ Configure Ansible

Next, configure Ansible to work seamlessly within your project.

1. **Edit `ansible/ansible.cfg`:**
    This file tells Ansible where to find its inventory.

    ```cfg
    [defaults]
    inventory = ./inventory.ini
    host_key_checking = False
    ```

2. **Edit `ansible/inventory.ini`:**
    This file lists the servers you want to manage.

    ```ini
    [nexus]
    mistia-nexus.local ansible_user=late4ever
    ```

3. **Test the Connection:**
    Run a ping from the `ansible` directory to confirm everything is working.

    ```bash
    cd ansible
    ansible nexus -m ping
    ```

    You should see a green `SUCCESS` response.

## 🔐 Secure Secrets with Ansible Vault

We will use Ansible Vault to securely manage your secrets, replacing the manual creation of `.env` files.

1. **Important: Update `.gitignore`**
    Add the following line to the main `.gitignore` file at the root of `Mistia-Labs` to prevent your secrets file from ever being committed to the repository.

    ```gitignore
    # Ignore Ansible secrets
    ansible/secrets.yml
    ```

2. **Create the Vault**
    From the `ansible` directory, run the following command. You will be prompted to create a password for the vault. **Store this password in Bitwarden.**

    ```bash
    ansible-vault create secrets.yml
    ```

3. **Add Your Secrets**
    The command will open a text editor. Add all your secrets in YAML format.

    ??? note "Using Vim"
        Press ++i++ to enter `Insert mode`
        Paste your secrets
        Press ++esc++ to exit `Insert mode`
        Type ++colon++ ++w++ ++q++ and press ++enter++ to write (save) and quit.

    ```yaml
    # ansible/secrets.yml (this content will be encrypted)
    cloudflare_api_token: "your-cloudflare-api-token"
    caddy_email: "address@email.com"
    duplicati_settings_key: "your-duplicati-settings-key"
    duplicati_ui_password: "your-duplicati-ui-password"
    ts_authkey: "your-tailscale-auth-key"
    nextcloud_db_password: "your-nextcloud-db-password"
    nextcloud_db_root_password: "your-nextcloud-db-root-password"
    nextcloud_admin_user: "username"
    nextcloud_admin_password: "your-nextcloud-admin-password"
    #sudo password
    ansible_become_pass: "sudo-password"
    ```

    Save and close the editor. The file is now encrypted.

## 📃 Create `.env` Templates

For each service requiring secrets, create a template file in `ansible/templates/`. These templates will be populated with the secrets from your vault.

**Example: `ansible/templates/caddy.env.j2`**

```ini
CLOUDFLARE_API_TOKEN={{ cloudflare_api_token }}
CADDY_EMAIL={{ caddy_email }}
```

**Example: `ansible/templates/nextcloud.env.j2`**

```ini
DB_PASSWORD={{ db_password }}
DB_ROOT_PASSWORD={{ db_root_password }}
ADMIN_USER={{ admin_user }}
ADMIN_PASSWORD={{ admin_password }}
```

*Create similar `.env.j2` files for `duplicati` and `tailscale`.*

## 5. Create the Deployment Playbook

Finally, create the main playbook that will replace your scripts. This playbook will deploy all your Docker services.

**Edit `ansible/deploy_services.yml`:**

```yaml
---
- name: Deploy Mistia-Nexus Services
  hosts: nas
  become: yes
  vars_files:
    - secrets.yml
  vars:
    deploy_path: "{{ playbook_dir }}/../mistia-nexus"
    services:
      - name: caddy
      - name: portainer
      - name: duplicati
      - name: tailscale
      - name: nextcloud

  tasks:
    - name: Ensure proxy network exists
      community.docker.docker_network:
        name: mistia-proxy-net
        state: present

    - name: Create .env files from templates
      ansible.builtin.template:
        src: "templates/{{ item.name }}.env.j2"
        dest: "{{ deploy_path }}/{{ item.name }}/.env"
        mode: '0600'
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
      loop: "{{ services }}"
      when: item.name != 'portainer' # Portainer has no .env file
      become: no # Run this task as the ansible_user

    - name: Deploy all services
      community.docker.docker_compose_v2:
        project_src: "{{ deploy_path }}/{{ item.name }}"
        state: present
        pulled: yes # Pulls latest images
      loop: "{{ services }}"
      tags:
        - "{{ item.name }}"
```

## 6. Run Your First Deployment

From the `ansible` directory, you can now deploy everything with a single command. You will be prompted for your vault password.

```bash
# To deploy or update ALL services
ansible-playbook deploy_services.yml --ask-vault-pass

# To deploy or update ONLY Caddy
ansible-playbook deploy_services.yml --tags caddy --ask-vault-pass
```
