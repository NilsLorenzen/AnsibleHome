## Installation

Bei der Erstinstallation muss nach Start innerhalb von 2 Minuten ein Postfach angelegt werden!

Für den Mail-Server sollte nur eine IPv4 Adresse im DNS hinterlegt werden.
-> https://docker-mailserver.github.io/docker-mailserver/edge/config/advanced/ipv6/

## Commands

Postfach anlegen: 
    `docker exec -ti mailserver setup email add admin@home-lorenzen.de`

Alias anlegen:
    `docker exec -ti mailserver setup alias add postmaster@home-lorenzen.de admin@home-lorenzen.de`

## setup.sh Script

Die Mailserver Rolle lädt automatisch ein setup.sh script auf den Docker-Host herunter.
Mit diesem lassen sich schnell und einfach die nötigen Commands herausfinden und ausführen.

Beispiel: `bash setup.sh email list` -> zeigt eine Liste aller Postfächer inklusvie der Speichernutzung und deren Aliase an.