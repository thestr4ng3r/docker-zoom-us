FROM archlinux:latest
MAINTAINER thestr4ng3r

RUN pacman --noconfirm -Syu

ARG ZOOM_URL=https://zoom.us/client/latest/zoom_x86_64.pkg.tar.xz

RUN curl -sSL $ZOOM_URL -o /tmp/zoom_x86_64.pkg.tar.xz
RUN pacman --noconfirm -U /tmp/zoom_x86_64.pkg.tar.xz
RUN rm /tmp/zoom_x86_64.pkg.tar.xz \
  && rm -rf /var/cache/pacman/pkg/*

RUN pacman --noconfirm -S sudo
RUN pacman --noconfirm -S pulseaudio pavucontrol

COPY scripts/ /var/cache/zoom-us/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh
COPY sudoers /etc/sudoers

COPY pulse-client.conf /etc/pulse/client.conf

ENTRYPOINT ["/sbin/entrypoint.sh"]
