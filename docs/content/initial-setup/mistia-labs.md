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

!!! warning "Activating the Environment"
    Remember to run this command every time you open a new WSL terminal to work on this project
    ```bash
    source ~/ansible-env/bin/activate
    ```

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
