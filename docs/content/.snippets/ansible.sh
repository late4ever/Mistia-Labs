# --8<-- [start:ve]
Open the repo in `WSL terminal`

```bash
cd ~/Mistia-Labs/
source tools/activate.sh
```
# --8<-- [end:ve]

# --8<-- [start:vault-edit]
nexus_vault
# --8<-- [end:vault-edit]

# --8<-- [start:playbook]
nexus_deploy --tags proxy-reload,[service_name]
# --8<-- [end:playbook]