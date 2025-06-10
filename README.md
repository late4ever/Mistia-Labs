# Mistia-Labs Services

This document provides a quick reference for all running services, their access URLs, and exposed network ports. The base URL for all local services is `http://mistia-nexus.local` or `https://mistia-nexus.local`.

| Service                   | URL (Clickable)                                                | Port (Host:Container) | Protocol | Notes                                                                                                                                              |
| :------------------------ | :------------------------------------------------------------- | :-------------------- | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Ugreen NAS (UGOS Pro)** | [`https://mistia-nexus.local:9443`]([https://mistia-nexus.local:9443](https://mistia-nexus.local:9443)) | `9443`       | `https`  | The main management UI for the NAS itself.                                                                                                         |
| **Portainer** | [`https://mistia-nexus.local:9444`]([https://mistia-nexus.local:9444](https://mistia-nexus.local:9444)) | `9444:9443`           | `https`  | The primary Docker management UI. Your browser will show a security warning on first visit because it uses a self-signed certificate. This is safe to accept. |
| **Duplicati** | [`http://mistia-nexus.local:8200`]([http://mistia-nexus.local:8200](http://mistia-nexus.local:8200))   | `8200:8200`           | `http`   | The automated backup solution. Used for configuring all backup jobs.                                                                               |

## Port Details

* **Host Port:** This is the port you use to access the service from your browser or other devices on your network (e.g., `:9444`).
* **Container Port:** This is the internal port the application is listening on inside its isolated Docker container (e.g., `:9443`).

The port mapping `Host:Container` is defined in each service's `docker-compose.yml` file.
