#!/usr/bin/env sh
# Client-Zertifikate (mTLS) für den Zugriff von außen auf Home Assistant über Traefik auf tyrion.
#
# Läuft nur lokal auf dem Mac. Das Zielverzeichnis muss außerhalb des Repos liegen.
# Danach gehören ca.key (mit Passwort) und die .p12-Dateien in Vaultwarden, nie ins Repo oder auf einen Host.
# Nur ca.crt ist öffentlich und kommt als traefik_mtls_ca_cert in die host_vars.
#
# Aufruf:
#   scripts/mtls_ca.sh <verzeichnis> ca                        CA anlegen (einmalig, bricht ab, wenn es sie schon gibt)
#   scripts/mtls_ca.sh <verzeichnis> client <name>             Zertifikat für ein Gerät, z.B. iphone oder mac
#
# Schlüssel sind ECDSA P-256: RSA-Clientzertifikate scheitern in der HA-App am WebSocket (OSStatus -9800).
# Die .p12 ist mit 3DES/SHA1 verschlüsselt: Den OpenSSL-3-Standard (AES-256, PBKDF2) lehnt der macOS-Schlüsselbund
# mit "MAC verification failed" ab. Schutz kommt deshalb vor allem vom Passwort – lang wählen.
# Widerruf: Traefik prüft keine Sperrlisten. Ist ein Gerät verloren, CA neu anlegen und alle Geräte neu ausstatten.

set -eu

CA_DAYS=3650
CLIENT_DAYS=730

usage() {
  sed -n 's/^#   //p' "$0" >&2
  exit 2
}

[ $# -ge 2 ] || usage
dir=$1
cmd=$2

repo=$(cd "$(dirname "$0")/.." && pwd -P)
dir=$(cd "$(dirname "$dir")" && pwd -P)/$(basename "$dir")
case "$dir/" in
  "$repo"/*)
    echo "Fehler: $dir liegt im Repo. Schlüssel gehören nicht hierher." >&2
    exit 1
    ;;
esac
umask 077
mkdir -p "$dir"

case "$cmd" in
  ca)
    [ $# -eq 2 ] || usage
    if [ -e "$dir/ca.key" ] || [ -e "$dir/ca.crt" ]; then
      echo "Fehler: In $dir gibt es schon eine CA." >&2
      exit 1
    fi
    echo "Passwort für den CA-Schlüssel festlegen (danach in Vaultwarden ablegen):"
    openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -aes-256-cbc -out "$dir/ca.key"
    openssl req -x509 -new -key "$dir/ca.key" -sha256 -days "$CA_DAYS" \
      -subj "/CN=AnsibleHome mTLS CA" \
      -addext "basicConstraints=critical,CA:TRUE,pathlen:0" \
      -addext "keyUsage=critical,keyCertSign,cRLSign" \
      -addext "subjectKeyIdentifier=hash" \
      -out "$dir/ca.crt"
    chmod 644 "$dir/ca.crt"
    echo
    echo "CA angelegt. Öffentliches Zertifikat für traefik_mtls_ca_cert:"
    cat "$dir/ca.crt"
    ;;

  client)
    [ $# -eq 3 ] || usage
    name=$3
    case "$name" in
      '' | *[!a-z0-9-]*)
        echo "Fehler: Gerätename nur aus a-z, 0-9 und -." >&2
        exit 1
        ;;
    esac
    if [ ! -e "$dir/ca.key" ] || [ ! -e "$dir/ca.crt" ]; then
      echo "Fehler: Keine CA in $dir, zuerst: $0 $dir ca" >&2
      exit 1
    fi
    if [ -e "$dir/$name.crt" ] || [ -e "$dir/$name.p12" ]; then
      echo "Fehler: Für $name gibt es schon ein Zertifikat in $dir." >&2
      exit 1
    fi

    # Der unverschlüsselte Schlüssel lebt nur bis zum Export in die .p12.
    trap 'rm -f "$dir/$name.key" "$dir/$name.csr" "$dir/$name.ext"' EXIT
    openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out "$dir/$name.key"
    openssl req -new -key "$dir/$name.key" -subj "/CN=$name" -out "$dir/$name.csr"
    cat > "$dir/$name.ext" <<EOF
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature
extendedKeyUsage=clientAuth
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
EOF
    echo "Passwort des CA-Schlüssels:"
    openssl x509 -req -in "$dir/$name.csr" -CA "$dir/ca.crt" -CAkey "$dir/ca.key" \
      -days "$CLIENT_DAYS" -sha256 -extfile "$dir/$name.ext" -out "$dir/$name.crt"
    chmod 644 "$dir/$name.crt"
    echo "Passwort für $name.p12 festlegen (wird beim Import auf dem Gerät abgefragt):"
    openssl pkcs12 -export -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1 \
      -name "$name" -inkey "$dir/$name.key" -in "$dir/$name.crt" -out "$dir/$name.p12"
    echo
    echo "Fertig: $dir/$name.p12 (gültig bis $(openssl x509 -in "$dir/$name.crt" -noout -enddate | cut -d= -f2))"
    ;;

  *)
    usage
    ;;
esac
