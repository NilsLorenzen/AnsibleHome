Bei der Erstinstallation muss nach Start innerhalb von 2 Minuten ein Postfach angelegt werden!

Postfach anlegen: 
    docker exec -ti mailserver setup email add test@home-lorenzen.de

Alias anlegen:
    docker exec -ti mailserver setup alias add postmaster@home-lorenzen.de test@home-lorenzen.de