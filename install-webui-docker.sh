#!/bin/bash

FORWARDPORT=3000
PORT=8080
CONTAINERNAME=open-webui 
VOLUME=open-webui:/app/backend/data 
SOURCEIMAGE=ghcr.io/open-webui/open-webui:main
CONTAINERNETWORK=host.docker.internal
HOSTNETWORK=host-gateway


docker run -d -p ${FORWARDPORT}:${PORT} --add-host=${CONTAINERNETWORK}:${HOSTNETWORK} -v ${VOLUME} --name ${CONTAINERNAME} --restart always ${SOURCEIMAGE}
