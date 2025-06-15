# Guide: Deploying AdGuard Home

This guide provides a complete, start-to-finish walkthrough for deploying AdGuard Home as a Docker container on your NAS.

## Prerequisites

Before starting, ensure you have completed the following on your Ugreen NAS:

1. **Created a "Virtual Network Bridge"**. This new primary interface on your NAS is likely named `VBR-LAN1`.

### Phase 1: Preparation

1. **Choose a Static IP Address for AdGuard Home:**
    * You must assign a dedicated IP address to your AdGuard Home container. This IP must be:
        * Within your network's subnet (e.g., `192.168.50.x`).
        * **Outside** of your router's DHCP assignment range (e.g., outside `192.168.50.2` to `192.168.50.199`).
    * For this guide, we will use **`192.168.50.251`**.

### Phase 2: Define and Deploy the Service

1. **Create Service Files:** Follow the steps in your local Git repository to create the `adguard-home` directory and its `docker-compose.yml` file.
2. **IMPORTANT - Create Ignore File:** Because AdGuard is critical infrastructure, we must prevent it from being stopped by the `update_all.sh` script. Create an empty `.ignore` file inside the `adguard-home` directory.
3. **Commit and Push:** Commit both the service files and the new `.ignore` file to your repository.
4. **Pull and Deploy on the NAS:**
    * SSH into your NAS and `cd` to your deployment directory.
    * Run `git pull` to get the new files.
    * Use the **`update.sh`** script to start AdGuard Home for the first time without affecting any other running services.

        ```bash
        # From the Mistia-Nexus root directory
        ./scripts/update.sh adguard-home
        ```

### Phase 3: First-Time Setup of AdGuard Home

AdGuard Home has a one-time setup wizard that you must complete.

1. **Navigate to the Setup Page:**
    * In your browser, go to `http://192.168.50.251:3000`. (Use the static IP you assigned).

2. **Complete the Wizard:**
    * **Step 1:** Click "Get Started".
    * **Step 2 (Web Interface):** Leave the listen interface as "All interfaces" and the port as `80`.
    * **Step 3 (DNS Server):** Leave the listen interface as "All interfaces" and the port as `53`.
    * **Step 4 (Authentication):** Create a strong username and password for your AdGuard Home admin panel. Save these in your password manager.
    * **Step 5 (Done):** Finish the setup. You will be automatically redirected to your new dashboard.

### **Phase 4: Configure Your Network**

The final step is to tell all the devices on your network to use AdGuard Home as their DNS server.

1. **Log into your Asus router's admin page.**
2. Navigate to the **LAN > DHCP Server** settings page.
3. Find the field named **"DNS Server 1"**.
4. **Action:** Enter the static IP address of your AdGuard Home container: `192.168.50.251`.
5. **Important:** Ensure `Advertise router's IP in addition to user-specified DNS` is set to **No**.
6. Click **"Apply"**.
