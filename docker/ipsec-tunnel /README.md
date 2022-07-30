# Run
```
docker run  --rm \
            --privileged \
            -v /lib/modules:/lib/modules \
            -e VPN_SECRET="" \
            -e VPN_FQDN="" \
            -e VPN_SOURCE="" \
            -e VPN_TARGET="" \
            -e TARGET="" \
            -p 500:500 \
            -p 4500:4500 \
            willguibr/zia-ipsec-tunnel:latest
```

# Build
`docker build -t <Repository>/<Image>:<Tag> .`

# Runtime Options
| Name         | Required | Default              | Options                           |
| ------------ | -------- | -------------------- | --------------------------------- |
| VPN_SECRET   | Yes      |                      |                                   |
| VPN_FQDN     | Yes      |                      |                                   |
| VPN_TARGET   | Yes      |                      |                                   |
| VPN_SOURCE   | Yes      |                      | Hostname or IP of Tunnel Endpoint |
| TARGET       | Yes      |                      | Hostname or IP to check           |
| MTR_OUTPUT   | No       | `--csv`              |                                   |
| MTR_CYCLES   | No       | 5                    |                                   |
| MTR_FIELDS   | No       | BAW                  | Check `man mtr`                   |
| MTR_TYPE     | No       | If empty - ICMP Echo | `--udp` , `--tcp`, `--sctp`       |
| MTR_HOPS     | No       | 30                   |                                   |
| MTR_INTERVAL | No       | 1                    |                                   |
| MTR_NODNS    | No       |                      | `--no-dns`                        |