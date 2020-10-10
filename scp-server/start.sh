#!/usr/bin/env bash

if [[ -z "$SCP_PASSWORD" ]]; then
  export SCP_PASSWORD=balena
fi

if [[ ! -z "SSH_PUBLIC_KEY" ]]; then
  mkdir -p ~/.ssh
  chmod 700 .ssh
  echo ${SSH_PUBLIC_KEY} | cat >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
fi

# here we set up the config for openSSH.
mkdir /var/run/sshd
echo "root:$SCP_PASSWORD" | chpasswd
# Enable password unless we are using SSH
if [[ -z "SSH_PUBLIC_KEY" ]]; then
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
fi

# SSH login fix. Otherwise user is kicked off after login. 
# Apparently not needed with balena image
# sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

export NOTVISIBLE="in users profile"
echo "export VISIBLE=now" >> /etc/profile

exec /usr/sbin/sshd -D
