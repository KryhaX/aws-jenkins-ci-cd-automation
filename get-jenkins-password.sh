#!/bin/bash

PRIVATE_KEY_PATH="keys/jenkins-key"
INSTANCE_IP="#"  #  Change to your accurate that show's in console

sudo ssh -i "$PRIVATE_KEY_PATH" ubuntu@"$INSTANCE_IP" "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
