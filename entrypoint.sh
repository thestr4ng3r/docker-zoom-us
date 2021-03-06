#!/bin/bash

echo "Entrypoint"

set -x
set -e

USER_UID=1000 #${USER_UID:-1000}
USER_GID=1000 #${USER_GID:-1000}

ZOOM_US_USER=zoom

install_zoom_us() {
  echo "Installing zoom-us-wrapper..."
  install -m 0755 /var/cache/zoom-us/zoom-us-wrapper /target/
  install -m 0755 /var/cache/zoom-us/zoom /target/
}

uninstall_zoom_us() {
  echo "Uninstalling zoom-us-wrapper..."
  rm -rf /target/zoom-us-wrapper
  echo "Uninstalling zoom-us..."
  rm -rf /target/zoom
}

create_user() {
  if ! getent group ${ZOOM_US_USER} >/dev/null; then
    groupadd -f -g ${USER_GID} ${ZOOM_US_USER} >/dev/null 2>&1
  fi

  # create user with USER_UID
  if ! getent passwd ${ZOOM_US_USER} >/dev/null; then
	useradd -m --uid ${USER_UID} --gid ${USER_GID} -G wheel,audio,video,utmp -s /bin/bash ${ZOOM_US_USER}
	chown ${ZOOM_US_USER} /home/${ZOOM_US_USER} -R
  fi
}

grant_access_to_video_devices() {
  for device in /dev/video*
  do
    if [[ -c $device ]]; then
      VIDEO_GID=$(stat -c %g $device)
      VIDEO_GROUP=$(stat -c %G $device)
      if [[ ${VIDEO_GROUP} == "UNKNOWN" ]]; then
        VIDEO_GROUP=zoomusvideo
        groupadd -g ${VIDEO_GID} ${VIDEO_GROUP}
      fi
      usermod -a -G ${VIDEO_GROUP} ${ZOOM_US_USER}
      break
    fi
  done
}

launch_zoom_us() {
  cd /home/${ZOOM_US_USER}
  exec sudo -HEu ${ZOOM_US_USER} PULSE_SERVER=/home/$ZOOM_US_USER/.pulse.socket QT_GRAPHICSSYSTEM="native" $@
}

case "$1" in
  install)
    install_zoom_us
    ;;
  uninstall)
    uninstall_zoom_us
    ;;
  root)
	bash
	;;
  *)
    create_user
    grant_access_to_video_devices
    echo "$1"
    launch_zoom_us $@
    ;;
esac
