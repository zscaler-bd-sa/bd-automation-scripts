#!/bin/sh

if [[ ! -z "$(ipcalc -ns $VPN_TARGET)" ]]; then
  echo "$VPN_TARGET is an IP address already."
else
  echo "$VPN_TARGET is not an IP address."
  VPN_TARGET=$(getent hosts $VPN_TARGET | grep -Eo '^[^ ]+')
  echo "Resolved to $VPN_TARGET"
fi

sed -i -e "s/VPN_SECRET/$VPN_SECRET/" /etc/ipsec.secrets
sed -i -e "s/VPN_FQDN/$VPN_FQDN/" /etc/ipsec.secrets

sed -i -e "s/VPN_FQDN/$VPN_FQDN/" /etc/ipsec.conf
sed -i -e "s/VPN_TARGET/$VPN_TARGET/" /etc/ipsec.conf
sed -i -e "s/VPN_SOURCE/$VPN_SOURCE/" /etc/ipsec.conf

ipsec start
sleep 5
ipsec up gw-zcloud &> /dev/null

until ping -c1 www.google.com >/dev/null 2>&1; do :; done

mtr $MTR_OUTPUT \
    -c $MTR_CYCLES \
    -o "$MTR_FIELDS" \
    $MTR_TYPE \
    -m $MTR_HOPS \
    -i $MTR_INTERVAL \
    $MTR_NODNS \
    $TARGET