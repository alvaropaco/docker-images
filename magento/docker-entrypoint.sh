#!/bin/bash

set -e

version="${MAGENTO_VERSION}"

log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') $@"
}

if [[ "${1}" == "extract" ]]; then

  file="/usr/src/${SERVICE}-${version}.tar.xz"

  log "Extract archive ${file} to /var/www"

  if [[ -f "$file" ]]; then
    tar xJf "${file}" -C /var/www --keep-newer-files
  else
    log "Archive ${file} not found" >&2
    exit 1
  fi

elif [[ "${@:1:2}" == "backup file" ]]; then

  mkdir -p /var/backups/

  if [[ -n "${3}" && ! -f "/var/backups/${3}" ]]; then
    backup_file="/var/backups/${3}"
  else
    backup_file="/var/backups/${SERVICE}-${version}-$(date '+%Y%m%d%H%M%S.%N')"
  fi

  log "Backup /var/www/${SERVICE} to ${backup_file}"

  exclude_path=
  for p in $(echo "${EXCLUDE_PATH}" | tr ':' ' '); do
    p="$(echo "${p}" | grep "^/var/www/${SERVICE}" | sed 's/^\/var\/www\///')"
    if [[ -n "${p}" ]]; then
      exclude_path="${exclude_path} --exclude=\"${p}\""
    fi
  done
  if [[ -n "${exclude_path}" ]]; then
    log "Exclude args: ${exclude_path}"
  fi

  free_size="$(df -B1 --output=avail / | tail -n 1)"
  backup_size="$(tar c ${exclude_path} -C /var/www "${SERVICE}" | wc -c)"
  if [[ "${backup_size}" -gt "${free_size}" ]]; then
    log "Disk space is too low" >&2
    exit 1
  fi

  tar cf "${backup_file}" ${exclude_path} -C /var/www "${SERVICE}"
  mv "${backup_file}" "${backup_file}.tar"

elif [[ "${@:1:2}" == "restore file" ]]; then

  if [[ ! -d "/var/backups" ]]; then
    log "Backup path not found" >&2
    exit 1
  fi

  if [[ -n "${3}" && -f "/var/backups/${3}.tar" ]]; then
    backup_file="/var/backups/${3}.tar"
  else
    backup_file=$(find /var/backups -maxdepth 1 -type f -name "${SERVICE}-${version}-*.tar" | sort | tail -n 1)
    if [[ ! -f "${backup_file}" ]]; then
      log "Backup not found" >&2
      exit 1
    fi
  fi

  log "Restore ${backup_file} to /var/www/${SERVICE}"

  tar xf "${backup_file}" -C /var/www

elif [[ "${1}" == "remove" ]]; then

  log "Remove all data in /var/www/${SERVICE}"

  set +e
  rm -rf "/var/www/${SERVICE}" 2>/dev/null
  set -e

elif [[ "${1#-}" != "$1" ]]; then

  set -- php-fpm "${@}"
  log "Start: ${@}"
  exec "${@}"

elif [[ "${#}" -eq "0" ]]; then

  log "Start: ${@}"
  exec php-fpm

else
  exec "${@}"
fi
