# --8<-- [start:ve]
Open the repo in `WSL terminal`

```bash
cd ~/Mistia-Labs/ansible/mistia-nexus/
source ~/ansible-env/bin/activate
```
# --8<-- [end:ve]

# --8<-- [start:vault-edit]
ansible-vault edit secrets.yml
# --8<-- [end:vault-edit]

# --8<-- [start:playbook]
ansible-playbook deploy-services.yml --tags proxy-reload, [service_name]
# --8<-- [end:playbook]