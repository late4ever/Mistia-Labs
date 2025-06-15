# Nginx Proxy Manager Setup Guide

**Note:** The default and recommended reverse proxy for this project is Caddy. This guide is for reference only, should you choose to run the `npm` profile instead. The setup process for Caddy is fully automated.

This document details the step-by-step process for configuring Nginx Proxy Manager (NPM) after it has been deployed via Docker.

The primary goal is to obtain a valid wildcard SSL certificate and use it to create secure, user-friendly URLs for your other homelab services.

---

## 1. First-Time Login & Setup

Before you can configure anything, you must complete the mandatory first-time setup process.

1. **Navigate to the NPM Admin UI:**
    * In your browser, go to [`http://mistia-nexus.local:81`](http://mistia-nexus.local:81).

2. **Log In with Default Credentials:**
    * **Email:** `admin@example.com`
    * **Password:** `changeme`

3. **Change Your Details Immediately:**
    * You will be immediately prompted to change your administrative details.
    * Update your Full Name, Nickname, and Email.
    * Create a new, strong, and unique password for your NPM admin account.

---

## 2. SSL Certificate Setup (Prerequisite)

This is the most important phase. You must have a valid SSL certificate before you can create secure proxy hosts.

### A. Generate a Cloudflare API Token

First, you need to grant NPM permission to modify your domain's DNS records via the Cloudflare API.

1. **Log into your Cloudflare account.**
2. Navigate to **My Profile > API Tokens**.
3. Click **Create Token**.
4. Find the **"Edit zone DNS"** template and click **"Use template"**.
5. Under the **"Zone Resources"** section, ensure you select your `mistia.xyz` domain.
6. Continue to the summary page and click **"Create Token"**.
7. **Action:** Copy the generated token secret. This is a critical secret and the only time you will see it.

### B. Request Wildcard Certificate in NPM

Now, use the API token to request the certificate from Let's Encrypt.

1. **Log into the NPM Admin UI** with your new credentials.

2. **Navigate to SSL Certificates:**
    * Click on the **"SSL Certificates"** tab.
    * Click **"Add SSL Certificate"** and select **"Let's Encrypt"**.

3. **Fill out the Certificate Details:**
    * **Domain Names:** Enter your root domain and a wildcard. Type `mistia.xyz`, press Enter, then type `*.mistia.xyz` and press Enter.
    * **Use a DNS Challenge:** Toggle this **ON**.
    * **DNS Provider:** Select **"Cloudflare"** from the dropdown list.
    * **Credentials File Content:** In the text box, paste the following, replacing `<YOUR_CLOUDFLARE_API_TOKEN>` with the token you copied from Cloudflare:

        ```txt
        dns_cloudflare_api_token = <YOUR_CLOUDFLARE_API_TOKEN>
        ```

    * **Agree to Terms:** Check the box to agree to the Let's Encrypt Terms of Service.
    * **Click Save.** Wait 1-2 minutes. The status should update, and you will have a valid wildcard certificate ready to use.

---

## 3. Create Proxy Hosts

With a valid certificate, you can now create secure routes to your services.

1. **Navigate to Proxy Hosts:**
    * Click on **Hosts** > **"Proxy Hosts"**.

2. **Add a New Host (Example: Portainer):**
    * Click the **"Add Proxy Host"** button.
    * **Details Tab:**
        * Domain Names: `portainer.mistia.xyz`
        * Scheme: `https`
        * Forward Hostname / IP: `mistia-nexus.local`
        * Forward Port: `9444`
        * Enable **"Block Common Exploits"**.
    * **SSL Tab:**
        * SSL Certificate: Select your `*.mistia.xyz` certificate from the dropdown list.
        * Enable **"Force SSL"**.
        * Enable **"HSTS Enabled"**.
        * Enable **"HTTP/2 Support"**.
    * **Click Save.**

Repeat this process for all your other services (like Duplicati), adjusting the domain name, scheme, and forward port as needed.

---

## 4. Configure Local DNS

The final step is to tell your home network devices where to find these new subdomains.

1. **Log into your router's administration page.**
2. Find the **LAN DNS** or "Static DNS" settings.
3. Add new records that point your subdomains to your NAS's static IP address:
    * `portainer.mistia.xyz` -> `192.168.50.150`
    * `duplicati.mistia.xyz` -> `192.168.50.150`
    * *Add a new entry for every proxy host you create.*
4. Save the changes on your router.

After these DNS changes take effect, you will be able to access all your services via their secure `https://` URLs.
