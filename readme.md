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
- [X] Plex with hardware encoding
- [X] OpenSpeedtest
- [ ] SpeedtestTracker
- [X] NGINX
- [X] Pihole
- [X] Smokeping
- [X] Tautulli
- [ ] Vaultwarden
- [ ] Teslamate
- [X] IT-Tools
- [X] Traefik with dns challenge
- [X] Minecraft Bedrock Server
- [ ] Minecraft Java Server
- [ ] Teamspeak Server

# SSL Zertifikate

aktuell werden alle SSL-Zertifikate per DNS-Challenge von Traefik generiert.

# Ansible-Vault / Secrets

Secrets können sicher über den Ansible-Vault abgelegt werden.
In diesem Repo haben aktuell alle Vaults das selbe Passwort "Ansible Vault" in Bitwarden

Beispiel:

- erstellen einer vault-datei: `ansible-vault create traefik.vault.yml`
- bearbeiten einer vault-datei: `ansible-vault edit traefik.vault.yml`
- anschauen einer vault-datei: `ansible-vault view traefik.vault.yml`

Um ein Playbook auszuführen, dass auf den Vault zugreift muss `--ask-vault-pass` an den `ansible-playbook` Befehl angehängt werden.
