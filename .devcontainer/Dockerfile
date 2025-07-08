FROM mcr.microsoft.com/devcontainers/python:1-3.12-bullseye
# path to virtual machine
ARG VirtualMachine="/mnt/c/Program Files/Oracle/VirtualBox" 
RUN apt-get update && \
    apt-get install -y wget gpg lsb-release gnupg software-properties-common curl && \
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list && \
    sudo apt update && sudo apt install vagrant && \
    pip install boto3
ENV VirtualMachineHome=$VirtualMachine