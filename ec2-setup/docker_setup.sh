#!/bin/bash

sudo apt-get update -y
sudo apt install docker.io

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jenkins