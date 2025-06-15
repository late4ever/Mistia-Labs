# Mistia-Labs

This repository contains the full Infrastructure as Code (IaC) for the Mistia-Labs homelab environment, deployed on a UGREEN NASync DXP4800 Plus.

The primary guide for setting up, managing, and extending this environment can be found in the **[Mistia-Nexus IaC Guide](./Mistia-Nexus/README.md)**.

---

## Hardware

| Component | Details |
| :--- | :--- |
| **NAS** | UGREEN NASync DXP4800 Plus |
| **RAM** | 2x 32GB Crucial DDR5-4800 SODIMM |
| **NVMe Storage**| 1x 2TB Samsung 990 Pro (For Docker & Applications) |
| **HDD Storage** | 2x 8TB WD Red Plus in RAID 1 (For Data & Backups) |
| **Router** | ASUS ZenWiFi Pro ET12 (AXE11000) |
| **Switch** | TP-LINK TL-SG105-M2 5-port 2.5Gbps |

---

## Core Services Overview

All services are managed by Docker and fronted by a Caddy reverse proxy, which provides automatic HTTPS.

| Service | URL | Purpose |
| :--- | :--- | :--- |
| **Caddy** | _(Infrastructure)_ | The primary reverse proxy, providing secure access and SSL for all services. |
| **Portainer** | `https://portainer.mistia.xyz` | Web UI for Docker container management. |
| **Duplicati** | `https://duplicati.mistia.xyz` | Encrypted, automated backup solution for all critical data. |
| **AdGuard Home**| `http://adguard.mistia.xyz` | Network-wide DNS sinkhole for blocking ads and malware. |
| **NAS UI** | `https://nexus.mistia.xyz` | The main management UI for the UGREEN NAS itself. |

---
