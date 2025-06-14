# Guide: Deploying AdGuard Home

This guide provides a complete, start-to-finish walkthrough for deploying AdGuard Home as a Docker container on your NAS.

## **Prerequisites**

Before starting, ensure you have completed the following on your Ugreen NAS:

1. **Disabled Link Aggregation.**
2. **Created a "Normal Network Bridge"**. This new primary interface on your NAS is likely named `br0`.

### **Phase 1: Preparation**

1. **Choose a Static IP Address for AdGuard Home:**
    * You must assign a dedicated IP address to your AdGuard Home container. This IP must be:
        * Within your network's subnet (e.g., `192.168.50.x`).
        * **Outside** of your router's DHCP assignment range (e.g., outside `192.168.50.2` to `192.168.50.199`).
    * For this guide, we will use **`192.168.50.251`**.

### **Phase 2: Define and Deploy the Service**

Now, we will follow your standard IaC template to add the service to your repository.

1. **Create the Service Directory (on your local computer):**
    * In your `Mistia-Nexus` folder, create a new directory named `adguardhome`.

2. **Create the `docker-compose.yml` File (on your local computer):**
    * Inside the new `adguardhome` directory, create a `docker-compose.yml` file.
    * **Action:** Paste the following content into the file. It has been pre-configured with all best practices and points to your new `br0` network bridge.

    ```yaml
    # Mistia-Nexus/adguardhome/docker-compose.yml
    services:
      adguardhome:
        image: adguard/adguardhome:latest
        container_name: adguardhome
        hostname: adguardhome
        logging:
          driver: "json-file"
          options:
            max-size: "10m"
            max-file: "3"
        healthcheck:
          test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1"]
          interval: 5m
          timeout: 10s
          retries: 3
        labels:
          - "com.mistia-nexus.service.name=AdGuard Home"
          - "com.mistia-nexus.service.type=Network Security"
        environment:
          - TZ=Asia/Singapore
        networks:
          adguard_net:
            ipv4_address: 192.168.50.251
        volumes:
          - ./workdir:/opt/adguardhome/work
          - ./confdir:/opt/adguardhome/conf
        restart: unless-stopped

    networks:
      adguard_net:
        driver: macvlan
        driver_opts:
          # This MUST point to the name of your Network Bridge interface.
          parent: br0
        ipam:
          config:
            - subnet: 192.168.50.0/24
              gateway: 192.168.50.1
    ```

3. **Commit and Push the Configuration (from your local computer):**

    ```bash
    git add Mistia-Nexus/adguardhome/
    git commit -m "feat(adguard): Add AdGuard Home service"
    git push
    ```

4. **Pull and Deploy on the NAS:**
    * SSH into your NAS, navigate to your deployment directory (`/volume2/Mistia-Labs/Mistia-Nexus`), and run your update script.

    ```bash
    ./scripts/update_all.sh
    ```

    This will pull the new files and start the AdGuard Home container.

### **Phase 3: First-Time Setup of AdGuard Home**

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

### **Phase 5: Finalize and Document**

1. **Test:** Disconnect your computer from the network and reconnect it to get the new DNS settings. Try browsing a few websites. You should notice that ads are gone. You can also see the query logs populating in your AdGuard Home dashboard.
2. **Update `SERVICES.md`:** Add a new row for your new service.
