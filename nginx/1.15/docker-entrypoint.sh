#!/bin/bash

if [[ -n "${LETSENCRYPT_NO_QUIET}" ]]; then
  sed -i "s/^.*quiet = true$/# quiet = true/" /etc/letsencrypt/cli.ini
else
  sed -i "s/^.*quiet = true$/quiet = true/" /etc/letsencrypt/cli.ini
fi

if [[ -n "${LETSENCRYPT_STAGING}" ]]; then
  sed -i "s/^.*staging = true$/staging = true/" /etc/letsencrypt/cli.ini
  sed -i "s/^.*break-my-certs = true$/break-my-certs = true/" /etc/letsencrypt/cli.ini
else
  sed -i "s/^.*staging = true$/# staging = true/" /etc/letsencrypt/cli.ini
  sed -i "s/^.*break-my-certs = true$/# break-my-certs = true/" /etc/letsencrypt/cli.ini
fi

set -e

if [[ ! -f "/etc/nginx/certificates/dhparam.pem" ]]; then
  openssl dhparam -out /etc/nginx/certificates/dhparam.pem 2048
fi

if [[ ! -f "/etc/nginx/certificates/default.crt" || ! -f "/etc/nginx/certificates/default.key" ]]; then
  openssl req -x509 -nodes -sha256 -days 3650 \
    -subj "/O=D2C/CN=*" \
    -keyout /etc/nginx/certificates/default.key \
    -out /etc/nginx/certificates/default.crt
fi

check() {
  result="$(nginx -Tq 2>&1 | grep "No such file or directory" | \
    grep -Eo "/etc/letsencrypt/live/([a-z0-9\.]+)/(fullchain|privkey).pem" | uniq)"
}

while check; do
  if [[ -z "${result}" ]]; then
    break
  fi
  for f in "${result}"; do
    dirname="$(dirname ${f})"
    if [[ ! -d "${dirname}" ]]; then
      mkdir -p "${dirname}"
    fi
    if [[ ! -L "${f}" ]]; then
      filename="$(basename ${f})"
      if [[ "${filename}" == "fullchain.pem" ]]; then
        ln -s /etc/nginx/certificates/default.crt "${f}"
      else
        ln -s /etc/nginx/certificates/default.key "${f}"
      fi
    fi
  done
done

if [[ "${@:1:2}" == "cert new" ]]; then

  params=()

  if [[ -z "${3}" ]]; then
    exit 1
  fi
  name="${3}"
  params+=(--cert-name "${name}")

  params+=(--pre-hook "rm -rf \
    /etc/letsencrypt/renewal/${name}.conf \
    /etc/letsencrypt/live/${name} \
    /etc/letsencrypt/archive/${name}")

  if [[ -z "${4}" ]]; then
    exit 1
  fi
  email="${4}"
  params+=(-m "${email}")

  if [[ -z "${5}" ]]; then
    exit 1
  fi
  set -- "${@:5}"

  for d in "${@}"; do
    params+=(-d "${d}")
  done

  certbot "${params[@]}" certonly

  if [[ -f /var/run/nginx.pid ]]; then
    nginx -s reload
  fi

elif [[ "${@:1:2}" == "cert renew" ]]; then

  certbot renew

  if [[ -f /var/run/nginx.pid ]]; then
    nginx -s reload
  fi

elif [[ "${@:1:2}" == "cert delete" ]]; then

  params=()

  if [[ -z "${3}" ]]; then
    exit 1
  fi
  name="${3}"
  params+=(--cert-name "${name}")

  params+=(--post-hook "rm -rf \
    /etc/letsencrypt/renewal/${name}.conf \
    /etc/letsencrypt/live/${name} \
    /etc/letsencrypt/archive/${name}")

  certbot "${params[@]}" delete

elif [[ "${1#-}" != "$1" ]]; then

  set -- nginx "${@}"
  log "Start: ${@}"
  exec "${@}"

elif [[ "${#}" -eq "0" ]]; then

  log "Start: ${@}"
  exec nginx -g 'daemon off;'

else
  exec "${@}"
fi
