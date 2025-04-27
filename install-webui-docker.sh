#!/bin/sh
IP_ADDRESSES=$(hostname -I | tr ' ' '\n')
FORWARDPORT=3000
PORT=8080
CONTAINERNAME=open-webui 
VOLUME=open-webui:/app/backend/data 
SOURCEIMAGE=ghcr.io/open-webui/open-webui:main
CONTAINERNETWORK=host.docker.internal
HOSTNETWORK=host-gateway

docker run -d -p ${FORWARDPORT}:${PORT} --add-host=${CONTAINERNETWORK}:${HOSTNETWORK} -v ${VOLUME} --name ${CONTAINERNAME} --restart always ${SOURCEIMAGE}

if [ -z "$IP_ADDRESSES" ]; then
    echo -e "Could not automatically determine IP addresses. You might need to find it manually (e.g., using 'ip addr')."
    echo -e "Once you have the IP, access the WebUI at: http://<YOUR_SERVER_IP>:${FORWARDPORT}"
else
    echo -e "Open WebUI should be accessible at the following URLs (try the one relevant to your network):"
    # Loop through each IP address found
    for IP in $IP_ADDRESSES; do
        # Trim potential whitespace just in case
        IP=$(echo "$IP" | xargs)
        if [ -n "$IP" ]; then # Ensure IP is not empty after trimming
          echo "  http://${IP}:${FORWARDPORT}"
        fi
    done
    # Always suggest localhost as well
    echo "  http://localhost:${FORWARDPORT}"
    echo "  http://127.0.0.1:${FORWARDPORT}"
fi

