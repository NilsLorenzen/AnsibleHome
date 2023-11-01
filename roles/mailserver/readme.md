## Installation

Bei der Erstinstallation muss nach Start innerhalb von 2 Minuten ein Postfach angelegt werden!

Für den Mail-Server sollte nur eine IPv4 Adresse im DNS hinterlegt werden.
-> https://docker-mailserver.github.io/docker-mailserver/edge/config/advanced/ipv6/

Die Rolle fügt standardmäßig einen zweiten Docker-Container namens "mailserver-cert-companion" hinzu.
Dieser dient lediglich dazu, dass Traefik ein SSL-Zertifikat für den Mail-Server generieren kann.

## Commands

Postfach anlegen: 
    `docker exec -ti mailserver setup email add admin@home-lorenzen.de`

Alias anlegen:
    `docker exec -ti mailserver setup alias add postmaster@home-lorenzen.de admin@home-lorenzen.de`

## setup.sh Script

Die Mailserver Rolle lädt automatisch ein setup.sh script auf den Docker-Host herunter.
Mit diesem lassen sich schnell und einfach die nötigen Commands herausfinden und ausführen.

Beispiel: `bash setup.sh email list` -> zeigt eine Liste aller Postfächer inklusvie der Speichernutzung und deren Aliase an.

## Webmail

Docker-Mailserver bringt kein eigenes Webmail-Interface mit. Dafür benutzte ich RoundCubeMail als eigenen Docker-Container.
Will man den Webmail-Container unter der Adresse des Mail-Servers veröffentlichen spart man sich den oben genannten "mailserver-cert-companion" Container.

Diese Rolle passt sich automatisch an in dem die host_var `mx_use_webmail: "yes"` oder `no` genutzt wird.

## Anti-SPAM