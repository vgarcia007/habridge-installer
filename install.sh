#!/bin/bash
sudo apt update
sudo apt install curl wget default-jdk
#get current directory
current_working_dir=$(pwd)
current_release=$(curl -s https://api.github.com/repos/bwssytems/ha-bridge/releases/latest | grep "browser_download_url.*jar" | cut -d : -f 2,3 | tr -d '"')
releases=($(echo $current_release | tr " " "\n"))

for release in "${releases[@]}"
do
    if [[ $release =~ "java11" ]]
    then
        filename="${release##*/}"
        echo "Get file: $filename"

        wget -Nq $release --show-progress
    fi
done

sed "s|__APP_DIR__|$current_working_dir|g" <habridge.template.service >habridge.service.temp
sed "s|__FILE_NAME__|$filename|g" <habridge.service.temp >habridge.service
rm habridge.service.temp
sudo mv habridge.service /etc/systemd/system/habridge.service
systemctl daemon-reload
systemctl start habridge
systemctl status habridge
echo "you can reach the frontend at http://$(hostname):8080"