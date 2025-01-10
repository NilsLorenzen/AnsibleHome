# My HomeLab Ansible Configuration

In diesem Repo ist die Konfiguration meines HomeLab/Netzwerk abgelegt.
Als Host dienen aktuell folgende Geräte:
- ein Cloud Server bei Hetzner (ARM basiert)
- ein h100 MiniPC mit dual 2.5 Gbe NICs
- drei ZimaBoards als Proxmox Cluster (Aktuell nur Spielwiese und nicht mit Ansible verwaltet)
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

## Meine Ansbile Rollen in diesem Repo

Die meisten meiner Ansible Rollen sind Docker Dienste.
Im folgenden findest du eine Liste mit kurzer Beschreibung.‚

- convertx: Mächtiger Datei Converter mit Web-Oberfläche.
- cyberchef: Web-Tool mit fokus auf Text Formatierung und Umwandlung.
- docker: Installiert automatisch die richtige Docker Version auf dem Host.
- dozzle: Super simpler Browser basierter Docker Container Log-Viewer.
- grafana: Web-Dashboard für alle erdenkklichen Grafiken und Diagramme.
- homeassistant: Smart Home
- homebridge: Tool um nicht unterstützte Smart Home Geräte in Apple Homekit zu integrieren.
- homepage-dashboard: Mein Lieblings Homelab Dashboard. Die gesamte Konfiguration passiert in Config-Files.
- it-tools: Web-Tool mit vielen nützlichen kleinen Werkzeugen für den IT-Alltag.
- littlelink: Simple, selbstbetriebene Alternative zu LinkTree
- lubelogger: Web-Tool zum erfassen von Wartungsarbeiten und anderen Fahrzeug-Daten
- minecraft_bedrock: Ein Minecraft Bedrock Edition Server
- minecraft_java: Ein Minecraft Java Edition Server
- ntp_server: NTP-Server ohne overhead
- openspeedtest: Selbstgehosteter Netzwerkgeschwindigkeitstest (leider nicht wirklich Reverse Proxy kompatibel)
- overseerr: Ermöglicht Nutzern das Anfragen neu gewünschter Filme und Serien für Plex oder Jellyfin
- pairdrop: AirDrop artiger Datei-Sharing Dienst für alle Betriebssysteme
- pihole: DNS Blocker, Cache und Server als Docker Container
- plex: Genialer Medien Streaming Dienst ähnlich zu Netflix.
- prometheus: Metric-Collector der in meinem Fall für Traefik Metriken verwendet wird.
- ~~promtail_loki: Log-Collector den ich für Traefik nutzen möchte. Aktuell funktioniert das noch nicht wie ich es möchte.~~
- speedtest-tracker: Web-Tool das automatisch regelmäsig Internet-Speedtest durchführt und diese in einer Historie dokumentiert.
- spotify_tracker: Geniales Statistik Tool für sämtliche Informationen über den eigenen Spotify Musik Konsum.
- stirling-pdf: Webanwendung mit einer menge nützlicher Werkzeuge zur arbeit mit PDF Dateien.
- ~~teamspeak: Sprach und Chat Serveranwendung.~~
- tautulli: Auswertungs- und Statistik Dashboard für Plex.
- traefik: Dockerbasierter Reverse Proxy mit LetsEncrypt und Docker Socket Integration
- uptimekuma: Monitoring-Tool / Status-Website
- vaultwarden: Kostenlose Rust Implementierung des Bitwarden Passwort Managers
- webserver: Simpler nginx Webserver als Docker-Container
- whats-up-docker: Docker Image Überwachungstool das z.B. Discord Benachrichtigung sendet wenn neue Images verfügbar sind oder diese auf Wunsch automatisch installiert.
- wordpress: Wordpress Installation als Docker Container

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
