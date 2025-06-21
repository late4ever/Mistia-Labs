# Homelab Security & Monitoring Roadmap

This document outlines a comprehensive roadmap for enhancing the security and observability of your homelab. The layers are presented in a logical order, building upon each other to create a robust and resilient environment.

## **Layer 1: Network Defense & Access Control**

This is the foundational layer that controls access to your network from both the outside world and within your home.

### **1A. Perimeter & Host Firewalls**

* **What it is:** Your Asus router's firewall is the first line of defense against the internet. Your Ugreen NAS's built-in firewall is the second line, controlling which local devices can talk to the NAS.
* **Action:**
  * Ensure **no ports are forwarded** on your Asus router.
  * Enable the firewall on your Ugreen NAS and create rules to only allow access from your trusted local network subnet (e.g., `192.168.50.0/24`).

### **1B. DNS Filtering & Ad-Blocking**

* **What it is:** A network-wide ad and malware blocker that acts as your local DNS server. It prevents your devices from ever connecting to malicious or ad-serving domains.
* **Recommended Tools: AdGuard Home + Unbound**
  * **AdGuard Home:** Provides DNS filtering, ad-blocking, and a web interface for management
  * **Unbound:** A recursive DNS resolver that provides complete DNS privacy by querying authoritative servers directly (no reliance on Google/Cloudflare DNS)
* **Action:**
  1. Deploy Unbound as a Docker container to handle recursive DNS resolution
  2. Deploy AdGuard Home as a Docker container and configure it to use Unbound as its upstream DNS server
  3. Configure your router's DHCP settings to assign AdGuard Home as the DNS server for all devices on your network
  4. This setup provides enhanced privacy (no external DNS dependencies), security (DNSSEC validation), and ad-blocking capabilities

#### **1C. Secure Remote Access (VPN)**

* **What it is:** A tool to securely access your entire homelab from anywhere in the world without opening firewall ports.
* **Recommended Tool: Tailscale**
* **Action:** Deploy the Tailscale Docker container on your NAS and install the Tailscale client on your phone and laptop. This creates a secure, private virtual network for all your devices.

## **Layer 2: Service Uptime Monitoring**

This layer ensures you are immediately notified if any of your services go down.

* **Recommended Tool: Uptime Kuma**
* **What it is:** A user-friendly dashboard that pings your services (e.g., `https://portainer.mistia.xyz`) and alerts you if they become unavailable.
* **Action:** Deploy Uptime Kuma as a Docker container using your service template. Configure it to monitor the URLs for all your critical services.

## **Layer 3: Application & Intrusion Defense**

This layer actively protects your running web services from malicious actors.

* **Recommended Tool: CrowdSec**
* **What it is:** A modern, lightweight Intrusion Prevention System (IPS) that analyzes logs from Nginx Proxy Manager to detect and block malicious behavior like brute-force login attempts and web scanning.
* **Action:** Deploy the CrowdSec agent as a Docker container and configure it to read the access logs from your Nginx Proxy Manager container.

## **Layer 4: Centralized Logging & Metrics (Observability)**

This layer provides deep visibility into what your applications are doing and how they are performing.

* **Recommended Stack: Grafana + Loki + Prometheus**
* **What they are:**
  * **Loki:** Aggregates **logs** ("What happened?").
  * **Prometheus:** Collects **metrics** ("How much CPU/RAM is being used?").
  * **Grafana:** A powerful dashboard that visualizes data from both Loki and Prometheus.
* **Action:** This is a more advanced project. Start by deploying Loki and Grafana to centralize your container logs. Later, add Prometheus and `cAdvisor` to collect performance metrics for a complete observability stack.

## **Layer 5: Endpoint Security & Compliance**

This is the most advanced layer, providing enterprise-grade security monitoring for your devices.

* **Recommended Tool: Wazuh**
* **What it is:** A full SIEM and XDR platform. It uses agents installed on your devices to provide deep security insights.
* **Action:** Deploy the Wazuh server stack on your NAS and install Wazuh "agents" on your other devices. This allows for file integrity monitoring, vulnerability detection, and security auditing.

## **Layer 6: Automated Maintenance & Patching**

A secure system is an up-to-date system. This layer automates that process.

* **Recommended Tools: Watchtower & Cron**
* **What they are:**
  * **Watchtower:** A Docker container that automatically updates your other running containers to the latest image version.
  * **Cron:** The built-in Linux scheduler.
* **Action:**
  * Deploy Watchtower as a Docker container to keep your applications current.
  * Create a `cron` job on your NAS to automatically run `sudo apt-get update && sudo apt-get upgrade -y` on a weekly basis to install the latest system security patches.
