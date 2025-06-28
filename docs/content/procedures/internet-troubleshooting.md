---
icon: octicons/globe-16
---

# 🌐 Internet Troubleshooting

!!! abstract "Overview"
    This guide outlines the procedure for investigating why the Internet is down.

## :simple-adguard:{ .adguard } Remove AdGuard Home DNS

1. Go to [https://192.168.50.1:8443](https://192.168.50.1:8443) on a device that is connected to our LAN or Wifi

    ![login](../images/procedures/internet-troubleshooting/login.png)

2. Login using `Bitwarden` search for `Asus ET12` and use this credential to login

3. On the left-hand menu, select `LAN`

    ![menu](../images/procedures/internet-troubleshooting/menu.png)

4. Select the `DHCP Server` tab

    ![dhcp](../images/procedures/internet-troubleshooting/dhcp.png)

5. Scroll down to the `DNS and WINS Server Setting`

    ![dns-server](../images/procedures/internet-troubleshooting/dns-server.png)

6. Update the values:
      - **DNS Server 1:** Clear any values
      - **DNS Server 2:** Clear any values
      - **Advertise router's IP in addition to user-specified DNS:** `Yes`
      - **WINS Server:** Clear any values

    ![dns-server-clear](../images/procedures/internet-troubleshooting/dns-server-clear.png)

7. Click `Apply` at the bottom

8. If the internet is not resumed, call `My Republic` at `+65 6717 1680`, daily from 9 am to 2 am. For Fibre broadband issues, press 2 and then 4
