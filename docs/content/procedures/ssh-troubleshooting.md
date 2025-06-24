---
icon: material/ssh
---

# 🔑 Troubleshooting SSH Authentication

!!! abstract "Overview"
    This guide provides definitive steps to resolve `Permission denied (publickey,password)` errors. If you are being prompted for a password instead of using your SSH key, it almost always means the SSH server on the NAS is not configured correctly or the key itself is not properly installed.

## 📝 Check the SSH Permission Service on the NAS

Your NAS uses a custom service to ensure SSH file permissions remain correct. If this service is not running, authentication will fail.

1. **Log into your NAS** using your username and password.

2. **Check the service status**:

    ```bash
    sudo systemctl status mistia-nexus-ssh-permission.service
    ```

    - If it shows `active (running)`, the service is fine. Proceed to Step 2 of this guide.
    - If it shows `inactive (dead)` or `failed`, continue to the next step.

3. **Reset and Start the Service**:
    If the service failed too many times, you may need to reset its failure counter first.

    ```bash
    sudo systemctl reset-failed mistia-nexus-ssh-permission.service
    sudo systemctl start mistia-nexus-ssh-permission.service
    ```

4. **Check the Logs if it Fails Again**:
    If the service still won't start, view its logs to find the specific error.

    ```bash
    journalctl -u mistia-nexus-ssh-permission.service -n 50 --no-pager
    ```

    A common error is `inotifywait: command not found`. If you see this, you need to install the required tools with `sudo apt install inotify-tools`. Once you fix the underlying issue, try starting the service again.

## 🔐 Verify the Authorized Key and Permissions

If the permission service is running correctly, the next step is to ensure the correct public key is on the NAS and has the right permissions.

1. **Generate the Correct Public Key in WSL**
    From your **WSL terminal**, read your private key and print the public part to the screen. This command does not change your key; it only displays the public portion.

    ```bash
    ssh-keygen -y -f ~/.ssh/id_ed25519
    ```

    **Copy the entire output line** (starting with `ssh-ed25519 AAAA...`) to your clipboard.

2. **Overwrite the Key on the NAS**
    - Log into your NAS using your username and password.
    - Open the `authorized_keys` file: `nano ~/.ssh/authorized_keys`
    - **Delete all existing content** and **paste the new public key** you copied from WSL.
    - Save and exit (`Ctrl+X`, `Y`, `Enter`).

3. **Enforce Correct Permissions on the NAS**
    - While still on the NAS, run these critical permission commands:

    ```bash
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    ```

## 📃 Enable Public Key Authentication on the SSH Server

Next, ensure the SSH server itself is configured to accept keys.

1. **Log into your NAS** using your username and password.

2. Run the following command on the **NAS** to open the SSH server's main configuration file.

    ```bash
    sudo nano /etc/ssh/sshd_config
    ```

3. Inside the file, look for the line `PubkeyAuthentication`. Ensure it is uncommented (no `#` at the beginning) and set to `yes`.

    ```sshd_config
    PubkeyAuthentication yes
    ```

4. Press `Ctrl+X`, then `Y`, then `Enter` to save the file.

5. **Restart the SSH server** on the NAS to apply the changes.

    ```bash
    sudo systemctl restart sshd
    ```

6. **Test the Connection**
    Now, from your **Windows Terminal** (with Bitwarden running) and from **WSL**, try to connect again. The key should now work, and you should not be prompted for a password.

    ```bash
    # From WSL
    ansible nas -m ping
    ```

    If the connection is successful, proceed to the final step.
