# Mistia-Labs

## Hardware

1. **Misita-Nexus | UGREEN NASync DXP4800 Plus**

   - 2x 32GB Crucial DDR5-4800 SODIMM
   - 1x 2TB Samsung 990 Pro M.2 NVMe
   - 2x 8TB WD Red Plus HDD

2. **ASUS ZenWiFi Pro ET12 2-Pack AXE11000 Tri-Band WiFi 6E Router**

3. **TP-LINK TL-SG105-M2 5-port 2.5Gbps Switch**

## Services

| Service                   | URL                                                | Port (Host:Container) | Protocol | Notes                                                                                                                                              |
| :------------------------ | :------------------------------------------------------------- | :-------------------- | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| **UGREEN NASync** | [`https://nexus.mistia.xyz`](https://nexus.mistia.xyz) | `9443`       | `https`  | The main management UI for the NAS itself.                                                                                                         |
| **Portainer** | [`https://portainer.mistia.xyz`](https://portainer.mistia.xyz) | `9444:9443`           | `https`  | The primary Docker management UI. Your browser will show a security warning on first visit because it uses a self-signed certificate. This is safe to accept. |
| **Duplicati** | [`http://duplicati.mistia.xyz`](https://duplicati.mistia.xyz)   | `8100:8100`           | `http`   | The automated backup solution. Used for configuring all backup jobs.                                                                               |
| **Nginx Proxy Manager** | [`https://proxy.mistia.xyz`](https://proxy.mistia.xyz) | `81:81`, `8880:80`, `4443:443` | `https` | The reverse proxy and SSL certificate manager for all services. |
| **AdGuard Home** | [`https://adguard.mistia.local`](https://adguard.mistia.local) | `192.168.50.251` | `http` | Network-wide ad blocker. Uses a static `macvlan` IP. |

---

## Template: Adding a New Service

This document is your standard operating procedure (SOP) for adding any new Docker containerized service to the Mistia-Nexus environment.

### Phase 1: Define the Service

Add the new service to your repository and deploy it to [Mistia-Labs GitHub Repo](https://github.com/late4ever/Mistia-Labs/)

1. **Create the Service Directory**

   - In your `Mistia-Nexus` folder, create a new directory for your service.
   - **Action:** `mkdir Mistia-Nexus/<SERVICE_NAME>`

2. **Create the `docker-compose.yml` File**

   - Inside the new `<SERVICE_NAME>` directory, create a `docker-compose.yml` file.
   - **Action:** Use the generic template below, filling in the placeholders with the information you gathered in Phase 1.

      ```yaml
      # docker-compose.yml for Duplicati
      services:
      duplicati:
         image: <SERVICE_IMAGE>
         container_name: <SERVICE_NAME>
         hostname: <SERVICE_NAME>
         logging:
            driver: 'json-file'
            options:
            max-size: '10m'
            max-file: '3'
         healthcheck:
            test: ['CMD', 'curl', '-f', '<<SERVICE_LOCAL_URL>>']
            interval: 5m
            timeout: 10s
            retries: 3
         labels:
            - 'com.mistia-nexus.service.name=<SERVICE_NAME>'
            - 'com.mistia-nexus.service.type=<SERVICE_TYPE>'
         environment:
            - TZ=Asia/Singapore
            - <REQUIRE_ENV_SETTINGS>
         volumes:
            - <REQUIRED_VOLUME>
         ports:
            - <PORT_MAPPING>
         restart: unless-stopped
         networks:
            - <SERVICE_NAME>_net

      networks:
         <SERVICE_NAME>_net:
            name: <SERVICE_NAME>_net
      ```

3. **Commit and Push the Configuration**

   - **Action:** Add the new directory to Git and push it to your repository.

      ```bash
      git add Mistia-Nexus/<SERVICE_NAME>/
      git commit -m "✨ feat: Add <SERVICE_NAME> service"
      git push
      ```

---

### Phase 2: Deploy the Service

1. **Pull Changes and Create Secrets**

   - **Action:** SSH into your NAS and navigate to your deployment directory.

      ```bash
      ssh late4ever@mistia-nexus.local
      cd /volume2/docker/Mistia-Nexus
      ```

   - **Action (if secrets are required, if not skip):** If your service needs a password, create the `.env` file now.

      ```bash
      git pull
      cd <SERVICE_NAME>
      nano .env
      # Add your secret to the file, e.g.:
      # YOUR_SECRET_NAME=YourSecretValue (make sure the env is saved in Bitwarden Mistia-Labs note)
      # Save and exit, then return to the parent directory:
      cd ..
      ```

   - **Action:** Run your update script to pull the new files.

      ```bash
      ./update_all.sh
      ```

2. **Deploy the to Mistia-Nexus**

   - **Action:** Run the `start_all.sh` script. It will automatically find the new service directory and start it for the first time.

      ```bash
      ./start_all.sh
      ```

---

### Phase 3: Setup Reverse Proxy

1. Go to [`https://proxy.mistia.xyz`](https://proxy.mistia.xyz)

2. Add a new Proxy Host for the new service

---

### Phase 4: Finalize and Document

The service is now be running. The final step is to document it.

1. **Test the Service**

   - **Action:** Open your web browser and navigate to the service's URL (e.g., `https://<proxyhost>.mistia.xyz`) to ensure it's working.

2. **Update this `README.md`**

   - **Action:** Open this `README.md` and add a new row to the table with the details for the new service.

      | Service | URL (Clickable) | Port (Host:Container) | Protocol | Notes |
      | :--- | :--- | :--- | :--- | :--- |
      | **`<SERVICE_NAME>`** | [`<SERVICE_URL>`](<SERVICE_URL>) | `<HOST_PORT>:<CONTAINER_PORT>` | `http/https` | *Briefly describe the service.* |

3. **Update [Mistia-Nexus README.md](Mistia-Nexus/README.md)**

   - **Action:** Open [Mistia-Nexus README.md](Mistia-Nexus/README.md) and update these sections:
     - `Section 2`, `Part B`, `Point 2` add a new section on the secret required
     - `Section 3`, update access url and initial setup to be done
  
4. **Commit Documentation Changes**

   - **Action:** Commit the updated `README.md` file to the [Mistia-Labs GitHub Repo](https://github.com/late4ever/Mistia-Labs/).

      ```bash
      git add .
      git commit -m "📚 docs: Add <SERVICE_NAME> to services list and setup docs"
      git push
      ```
