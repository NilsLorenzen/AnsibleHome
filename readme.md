In diesem Repo ist die Konfiguration meines HomeLab/Netzwerk abgelegt.
Als Host dienen aktuell folgende Geräte:
- ein Cloud Server bei Hetzner
- ein BeeLink MiniPC
- ein RasperryPi 4 ( aktuell nur als Testumgebung )
- Ein Synology Nas als Netzwerkspeicher z.B. für Plex (nicht mit Ansible verwaltet)

# Ansible Installation

Ansible auf Mac installieren per HomeBrew:

`brew install ansible`

Ansible auf Ubuntu oder WSL installieren:

`sudo apt update`

`sudo apt install software-properties-common`

`sudo add-apt-repository --yes --update ppa:ansible/ansible`

`sudo apt install ansible`

Die Playbooks können Ansible Librarys benötigen. Diese werden in der requirements.yml gesammelt.
Mit folgendem Befehl können alle auf einmal installiert werden:

` sh bootstrap `

# To-Dos:

- [X] Portainer 
- [X] Portainer-Agent
- [X] Heimdall
- [X] Plex with hardware encoding
- [X] OpenSpeedtest
- [ ] SpeedtestTracker
- [X] NGINX Reverse Proxy -> nicht mehr verwendet
- [X] Pihole
- [X] Smokeping
- [X] Tautulli
- [X] Vaultwarden
- [ ] Teslamate
- [X] IT-Tools
- [X] Traefik with dns challenge
- [X] Traefik with http challenge
- [X] Minecraft Bedrock Server
- [ ] Minecraft Java Server
- [X] Teamspeak Server
- [ ] docker-mailserver -> Rolle funktioniert aber Port 25 wird von hetzner noch blockiert
- [X] Homebridge
- [X] NGINX Webserver
- [X] Wordpress
- [ ] automatisierte Backups

# SSL Zertifikate

Alle benötigen SSL-Zertifikate werden von Traefik Docker Containern erstellt.
Es gibt 2 unterschiedliche Trafik Rollen:
- traefik -> wird für interne Dienste genutzt und generiert Zertifikate per DNS-Challenge
- traefik_httpchallenge -> wird für externe Dienste genutzt und geniert Zertifikate per HTTP-Challenge

# Ansible-Vault / Secrets

Secrets können sicher über den Ansible-Vault abgelegt werden.

Der Ansible Vault kann wie folgt benutzt werden:

- erstellen einer vault-datei: `ansible-vault create traefik.vault.yml`
- bearbeiten einer vault-datei: `ansible-vault edit traefik.vault.yml`
- anschauen einer vault-datei: `ansible-vault view traefik.vault.yml`

Um ein Playbook auszuführen, dass auf den Vault zugreift muss `--ask-vault-pass` an den `ansible-playbook` Befehl angehängt werden.
