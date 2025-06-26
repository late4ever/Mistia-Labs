---
icon: material/home-minus-outline
---

# 🚀 Mistia Labs

!!! abstract "Overview"
    This guide details how to configure a Windows machine to act as an Ansible "control node" for managing your Mistia-Lab. The standard and most compatible method is to use the Windows Subsystem for Linux (WSL).

## 🐧 Install Windows Subsystem for Linux (WSL)

1. Open **PowerShell** or **Windows Terminal** as an **Administrator**

2. Run the installation command:

    ```powershell
    wsl --install
    ```

3. Reboot your computer when prompted. After rebooting, an Ubuntu terminal window will open to complete the installation

4. You will be prompted to create a **username** and **password** for your new Ubuntu environment

## 🔑 Configure SSH Key with WSL

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

## :material-dns: Configure DNS server

```bash
sudo nano /etc/resolv.conf
```

Replace existing `nameserver` to `192.168.50.2`

```conf title="resolv.conf"
nameserver 192.168.50.2
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ to save and exit

## :simple-docker: Configure Docker with WSL

1. Open `Docker Desktop` >> `Settings` >> `Resources` >> `WSL integration`

2. Enable integration with additional distros:
      - Toggle **Ubuntu**

3. Click `Apply & restart`

4. In `Ubuntu (WSL) terminal`

    ```bash
    sudo usermod -aG docker $USER
    ```

5. Close all active WSL session for the change to take effect.

## :simple-ansible: Install Ansible Inside WSL

All subsequent commands should be run inside `Ubuntu (WSL) terminal`

1. **Install Prerequisites**

    ```bash
    sudo apt update && sudo apt upgrade -y && sudo apt install -y python3-pip git python3.12-venv
    ```

2. **Create and Activate a Virtual Environment**

    ```bash
    # Create the virtual environment in your home directory
    python3 -m venv ~/ansible-env

    # Activate the environment
    source ~/ansible-env/bin/activate
    ```

    Your terminal prompt should now be prefixed with `(ansible-env)`, indicating the environment is active

3. **Install Ansible and Dependencies**

    ```bash
    # Install the Ansible package itself
    pip install ansible

    # Install the Docker collection required for managing containers
    ansible-galaxy collection install community.docker
    ```

!!! success "Initial Activation Complete"
    You have activated the environment for the initial setup. For all future work on the project, you will use a more convenient, project-specific script that you will have access to after cloning the repository in the next step.

## :simple-github: Clone Mistia-Labs Repository

```bash
git clone https://github.com/late4ever/Mistia-Labs.git
git config --global user.name "late4ever"
git config --global user.email "late4ever@gmail.com"
```

## :material-microsoft-visual-studio-code: Open in VS Code

```bash
cd Mistia-Labs/
code .
```

This will open the project in a VS Code window, but the files and terminal will be running within the context of WSL.

## 🚀 Activating the Project Environment

Now that you have the project cloned, you should use the built-in activation script for your daily workflow. This script not only activates the Ansible environment but also sets up helpful aliases and functions.

From the project root (`~/Mistia-Labs`), run:

```bash
source tools/activate.sh
```

!!! tip "What it does"
    - Activates the `ansible-env` virtual environment.
    - Sets your command prompt to `(Mistia-Labs)`.
    - Creates a `nexus_deploy` function to run the main playbook.
    - Creates an `ap` alias for `ansible-playbook`.

!!! warning "Remember This Command!"
    From now on, `source tools/activate.sh` is the only command you need to start working on the project in a new terminal.
