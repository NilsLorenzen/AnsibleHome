# Ansible Installation

Ansible auf Ubuntu VM oder WSL installieren:

`sudo apt update`

`sudo apt install software-properties-common`

`sudo add-apt-repository --yes --update ppa:ansible/ansible`

`sudo apt install ansible`

Die Playbooks benötigen einige Ansible Librarys. Diese werden in der requirements.yml gesammelt.
Installiert werden sie mit dem folgenden Befehl:

<code> sh bootstrap </code>

# To-Dos:

- [X] Portainer 
- [X] Portainer-Agent
- [X] Heimdall
- [X] Plex_docker
- [X] OpenSpeedtest
- [ ] SpeedtestTracker
- [X] NGINX
- [ ] Minecraft
- [ ] Teamspeak
- [X] Pihole
- [X] Smokeping
- [X] Tautalui
- [ ] Vaultwarden
- [ ] Teslamate

# SSL Zertifikate



# Ansible-Vault / Secrets

Secrets können sicher über den Ansible-Vault abgelegt werden.
In diesem Repo haben aktuell alle Vaults das selbe Passwort "Ansible Vault" in Bitwarden

Beispiel: plex:

- erstellen einer vault-datei: `ansible-vault create plex.vault.yml`
- bearbeiten einer vault-datei: `ansible-vault edit plex.vault.yml`
- anschauen einer vault-datei: `ansible-vault view plex.vault.yml`

Um ein Playbook auszuführen, dass auf den Vault zugreift muss `--ask-vault-pass` an den `ansible-playbook` Befehl angehängt werden.
