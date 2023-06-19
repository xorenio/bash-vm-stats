# Collect.sh

A basic Bash script to collect runetime stats of a linux system to be ran as root/sudo

## Requirements

- jq
- sysstat
- ethtool
- netstat
- curl


## Example

```json
{
  "hostname": "hp-laptop",
  "uname_info": "Linux code-here 6.3.2-AMD #1 SMP PREEMPT_DYNAMIC Sun May 14 11:46:46 BST 2023 x86_64 GNU/Linux",
  "users": [
    "john",
  ],
  "lsb_release": "Manjaro Linux 23.0.0",
  "clocksource": "tsc",
  "ntp_status": "yes",
  "time_date": "Mon 19 Jun 17:50:56 BST 2023",
  "uptime": "up 6 days, 2 hours, 39 minutes",
  "install_date": "Jul 30 2022",
  "cpu": {
    "total": "12",
    "usage": {
      "user": "1.34%",
      "nice": "0.00%",
      "system": "0.33%",
      "idle": "98.33%"
    },
    "min_freq": "1600.00",
    "max_freq": "4287.79",
    "cur_freq": "4220.76"
  },
  "memory_usage": {
    "total": "31Gi",
    "used": "474Mi",
    "free": "31Gi",
    "shared": "",
    "available": ""
  },
  "network": {
    "public_address": "31.48.0.1",
    "network_address": "192.168.1.2/24",
    "usage": {
      "rxpck_s": "0.00",
      "txpck_s": "0.00"
    },
    "port_speed": "1000Mb/s",
    "ports": [
      {
        "protocol": "tcp",
        "address": "127.0.0.1:33435"
      },
      {
        "protocol": "tcp6",
        "address": ":::3000"
      },
      {
        "protocol": "tcp6",
        "address": ":::24678"
      },
      {
        "protocol": "udp",
        "address": "0.0.0.0:35474"
      },
      {
        "protocol": "udp",
        "address": "0.0.0.0:5353"
      },
      {
        "protocol": "udp6",
        "address": ":::5353"
      },
      {
        "protocol": "udp6",
        "address": ":::55226"
      }
    ]
  }
}

```
