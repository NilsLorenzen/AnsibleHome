# My HomeLab Ansible Configuration

In diesem Repo ist die Konfiguration meines HomeLab/Netzwerk abgelegt.
Als Host dienen aktuell folgende Geräte:
- ein Cloud Server bei Hetzner (ARM basiert)
- ein BeeLink MiniPC
- zwei ZimaBoards als Proxmox Cluster
- ein RasperryPi 4 ( aktuell nur als Testumgebung )
- Ein Synology Nas als Netzwerkspeicher z.B. für Plex (nicht mit Ansible verwaltet)

## Ansible Installation

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

## To-Dos:

- [ ] rebuild Traefik als einzelne Rolle
- [ ] Ghost Container
- [ ] SpeedtestTracker
- [ ] Teslamate
- [ ] Teamspeak Server -> neues Hosting benötigt da kein ARM Build existiert
- [ ] automatisierte Backups
- [ ] rebuild nic_configuration

## Rollen in diesem Repo

Durchgestrichene Rollen werden aktuell nicht verwendet.

- docker: installiert immer die richtige Docker Version auf dem Host
- ~~heimdall: docker-container für ein simples Home Dashboard, wurde ersetzt durch homepage~~
- homepage-dashboard: docker-container für mein Home Dashboard
- it-tools: docker-container mit vielen nützlichen Webtools (Schweizer Taschenmesser)
- littleliink: docker-container der eine Alternative zu LinkTree darstellt
- mailserver: dockermailserver - genau das nach dem es klingt :D
- minecraft_bedrock: ein minecraft bedrock server als docker container
- minecraft_java: ein minecraft java server als docker container
- ~~nginx proxy manager~~
- openspeedtest: selbstgehosteter Netzwerkgeschwindigkeitstest
- pihole: DNS Blocker, Cache und Server als Docker Container
- plex: Medien Streaming Dienst ähnzlich zu Netflix
- ~~portainer~~
- ~~portainer_agent~~
- roundcubemail: dockerbasierter Webmail Client
- ~~smokeping~~
- tautulli: Auswertungs- und Statistikcontainer für Plex
- ~~teamspeak~~
- traefik: dockerbasierter reverse proxy mit LetsEncrypt und Docker Integration
- uptimekuma: dockerbasiertes Monitoring-Tool / Status-Website
- vaultwarden: kostenlose Implementierung von BitWarden
- webserver: simpler nginx Webserver als Docker-Container
- wordpress: wordpress Installation als Docker Container

## SSL Zertifikate

Alle benötigen SSL-Zertifikate werden von Traefik Docker Containern erstellt.
Es gibt 2 unterschiedliche Trafik Rollen:
- traefik -> wird für interne Dienste genutzt und generiert Zertifikate per DNS-Challenge
- traefik_httpchallenge -> wird für externe Dienste genutzt und geniert Zertifikate per HTTP-Challenge

## Ansible-Vault / Secrets

Secrets können sicher über den Ansible-Vault abgelegt werden.

Der Ansible Vault kann wie folgt benutzt werden:

- erstellen einer vault-datei: `ansible-vault create traefik.vault.yml`
- bearbeiten einer vault-datei: `ansible-vault edit traefik.vault.yml`
- anschauen einer vault-datei: `ansible-vault view traefik.vault.yml`

Um ein Playbook auszuführen, dass auf den Vault zugreift muss das Passwort zur jeweiligen Vault-ID in einer Umgebungsvarbiable liegen. Dafür habe ich anderer Stelle ein Script.
Alternativ kann  `--ask-vault-pass` an den `ansible-playbook` Befehl angehängt werden und das Passwort manuell eingebene werden.
