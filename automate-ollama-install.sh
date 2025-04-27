#!/bin/sh
curl -sSL https://raw.githubusercontent.com/KompPsy/ollama-installation/main/install-docker.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/KompPsy/ollama-installation/main/stop-ollama.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/KompPsy/ollama-installation/main/install-ollama.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/KompPsy/ollama-installation/main/remove-webui-docker.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/KompPsy/ollama-installation/main/install-webui-docker.sh | sudo bash
