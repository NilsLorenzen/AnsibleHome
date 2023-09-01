# Ansible Installation

Ansible auf Ubuntu VM oder WSL installieren:

<code>

sudo apt update

sudo apt install software-properties-common

sudo add-apt-repository --yes --update ppa:ansible/ansible

sudo apt install ansible

</code>

Die Playbooks benötigen einige Ansible Librarys. Diese werden in der requirements.yml gesammelt.
Installiert werden sie in dem folgenden Befehl:


<code> sh bootstrap </code>

# To-Dos:

- [ ] Vaultwarden

# SSL Zertifikate



# Ansible-Vault / Secrets

Secrets können sicher über den Ansible-Vault abgelegt werden.
In diesem Playbook haben alle Vauts das selbe Passwort "Persephone Ansible Vault" in Bitwarden
Beispiel: wikijs:
- erstellen einer vault-datei: `ansible-vault create plex.vault.yml`
- bearbeiten einer vault-datei: `ansible-vault edit plex.vault.yml`
- anschauen einer vault-datei: `ansible-vault view plex.vault.yml`

Um ein Playbook auszuführen, dass auf den Vault zugreift muss "--ask-vault-pass" an den "ansible-playbook" Befehl angehängt werden.
