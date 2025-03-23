echo "Installing Dependencies"
apt-get install -y avahi-daemon
apt-get install -y curl
apt-get install -y sudo
apt-get install -y mc
apt-get install -y gpg
echo "Installed Dependencies"

echo "Setting Up Hardware Acceleration"
apt-get -y install {va-driver-all,ocl-icd-libopencl1,intel-opencl-icd,vainfo,intel-gpu-tools}
if [[ "$CTTYPE" == "0" ]]; then
  chgrp video /dev/dri
  chmod 755 /dev/dri
  chmod 660 /dev/dri/*
  adduser $(id -u -n) video
  adduser $(id -u -n) render
fi
evho "Set Up Hardware Acceleration"

echo "Setting Up Plex Media Server Repository"
wget -qO- https://downloads.plex.tv/plex-keys/PlexSign.key >/usr/share/keyrings/PlexSign.asc
echo "deb [signed-by=/usr/share/keyrings/PlexSign.asc] https://downloads.plex.tv/repo/deb/ public main" >/etc/apt/sources.list.d/plexmediaserver.list
echo "Set Up Plex Media Server Repository"

# make plex user now, make it root so that the mount will work later
useradd plex
usermod -ou 0 -g 0 plex

echo "Installing Plex Media Server"
apt-get update
apt-get -o Dpkg::Options::="--force-confold" install -y plexmediaserver
if [[ "$CTTYPE" == "0" ]]; then
  sed -i -e 's/^ssl-cert:x:104:plex$/render:x:104:root,plex/' -e 's/^render:x:108:root$/ssl-cert:x:108:plex/' /etc/group
else
  sed -i -e 's/^ssl-cert:x:104:plex$/render:x:104:plex/' -e 's/^render:x:108:$/ssl-cert:x:108:/' /etc/group
fi
echo "Installed Plex Media Server"

echo "Setting up media share"
apt install cifs-utils -y
mv media-nas.mount /etc/systemd/system/
systemctl enable media-nas.mount
systemctl start media-nas.mount
echo "media share ready!"
