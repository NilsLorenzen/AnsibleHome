## Installation

Bei der Erstinstallation muss nach Start innerhalb von 2 Minuten ein Postfach angelegt werden!

Für den Mail-Server sollte nur eine IPv4 Adresse im DNS hinterlegt werden.
-> https://docker-mailserver.github.io/docker-mailserver/edge/config/advanced/ipv6/

## Commands

Postfach anlegen: 
    docker exec -ti mailserver setup email add test@home-lorenzen.de

Alias anlegen:
    docker exec -ti mailserver setup alias add postmaster@home-lorenzen.de test@home-lorenzen.de