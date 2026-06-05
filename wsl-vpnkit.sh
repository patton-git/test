sudo apt-get update && sudo apt-get install iproute2 iptables iputils-ping dnsutils wget -y



# 최신 버전 정의 및 디렉터리 확보
VERSION=v0.4.1 
sudo mkdir -p /opt/wsl-vpnkit
# tar 내부의 app/ 바이너리만 필터링하여 압축 해제
wget https://github.com/sakai135/wsl-vpnkit/releases/download/$VERSION/wsl-vpnkit.tar.gz -O - | sudo tar -xz -C /opt/wsl-vpnkit --strip-components=1 app/wsl-vpnkit app/wsl-gvproxy.exe



sudo nano /etc/systemd/system/wsl-vpnkit.service
[Unit]
Description=WSL VPNKit Service
After=network.target

[Service]
Type=simple
ExecStart=/opt/wsl-vpnkit/wsl-vpnkit
Restart=always
RestartSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target



sudo systemctl daemon-reload
sudo systemctl enable wsl-vpnkit.service
sudo systemctl start wsl-vpnkit.service




sudo nano /opt/wsl-vpnkit/wsl-interop-helper.sh


#!/bin/bash
INTEROP_SOCKET=$(ls -t /run/WSL/*_interop 2>/dev/null | head -n 1)
if [ -n "$INTEROP_SOCKET" ]; then
    export WSL_INTEROP=$INTEROP_SOCKET
fi
exec /opt/wsl-vpnkit/wsl-vpnkit



sudo chmod +x /opt/wsl-vpnkit/wsl-interop-helper.sh



sudo nano /etc/systemd/system/wsl-vpnkit.service
[Unit]
Description=WSL VPNKit Service
After=network.target

[Service]
Type=simple
# 기존 /opt/wsl-vpnkit/wsl-vpnkit 에서 아래 경로로 변경
ExecStart=/opt/wsl-vpnkit/wsl-interop-helper.sh
Restart=always
RestartSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target







