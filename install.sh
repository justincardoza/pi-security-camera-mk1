#!/usr/bin/env bash

# This file is part of the Raspberry Pi security camera project by Justin Cardoza and is distributed under the MIT license.
# See the  original repository for more information: https://github.com/justincardoza/pi-security-camera-mk1

# Set up directories including the one the install script is running from (https://stackoverflow.com/a/246128).
scriptDirectory=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
mediaMtxDirectory=/opt/mediamtx
installersDirectory=$mediaMtxDirectory/installers

# Create the directory tree we need.
sudo mkdir -p $installersDirectory
# Set up an in-memory directory for installer files so we don't use storage writes on those.
sudo mount -t tmpfs pi-security-camera-installers $installersDirectory
# Switch to the installers directory.
cd $installersDirectory

# Install dependencies.
sudo apt install python3-picamera2 -y

# Remove the swapfile package so it doesn't cause excess storage writes.
sudo apt remove dphys-swapfile -y

# Determine what architecture to download MediaMTX for.
declare -A architectures
architectures["x86_64"]="amd64"
architectures["aarch64"]="arm64"
mediaMtxArchitecture=${architectures[$(uname -m)]}

# It should be possible to do something here with the output from `uname -s`, but more research is required.
# For now, it seems like a fair assumption that a bash script is likely running under Linux, especially in 
# the context of installing software than depends on picamera2.
mediaMtxKernel="linux"

# Download and install MediaMTX.
mediaMtxVersion=$(curl -I https://github.com/bluenviron/mediamtx/releases/latest | awk -F/ '/location: https:\/\/github.com/ { gsub(/[\s\n\r]/, "", $NF); print $NF }')
mediaMtxFilename=mediamtx_${mediaMtxVersion}_${mediaMtxKernel}_${mediaMtxArchitecture}.tar.gz
mediaMtxUrl=https://github.com/bluenviron/mediamtx/releases/download/$mediaMtxVersion/$mediaMtxFilename
echo "MediaMTX version is $mediaMtxVersion"
echo "Downloading MediaMTX from $mediaMtxUrl..."
wget $mediaMtxUrl
tar xzf $mediaMtxFilename

# Modify the default config to have the stream paths we want.
head --lines=-1 mediamtx.yml > config.yml
echo "  main:" >> config.yml
echo "    runOnDemand: python3 $mediaMtxDirectory/multistream.py" >> config.yml
echo "  lores:" >> config.yml
echo "    runOnDemand: python3 $mediaMtxDirectory/multistream.py" >> config.yml

# Copy files into the main directory.
sudo mv config.yml $mediaMtxDirectory/mediamtx.yml
sudo mv mediamtx $mediaMtxDirectory
sudo cp $scriptDirectory/multistream.py $mediaMtxDirectory

# Set up MediaMTX as a service.
sudo tee /etc/systemd/system/mediamtx.service >/dev/null << EOF
[Unit]
Wants=network.target
[Service]
ExecStart=$mediaMtxDirectory/mediamtx $mediaMtxDirectory/mediamtx.yml
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable mediamtx

# Set up log2ram to reduce storage writes more.
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ $(bash -c '. /etc/os-release; echo ${VERSION_CODENAME}') main" | sudo tee /etc/apt/sources.list.d/azlux.list
sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
sudo apt update
sudo apt install log2ram -y

# Disable the daily log flushes to storage.
sudo systemctl disable log2ram-daily.timer

# All done, so just print a reboot reminder now.
printf "\n================================================\n\n"
echo "The installation has finished! Please reboot when ready."
