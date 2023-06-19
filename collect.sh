#!/bin/bash

##
## https://github.com/xorenio/bash-vm-stats
##

# Variables
date=$(date +%Y-%m-%d_%H-%M-%S)
jsonfile="system_info_$date.json"

# Get hostname
hostname=$(hostname)

# Get uname
uname_info=$(uname -a)

# Get users
users=$(getent passwd | cut -d: -f1 | grep -v -E 'root|nobody|dbus|bin|daemon|mail|ftp|http|systemd-coredump|systemd-network|systemd-oom|systemd-journal-remote|systemd-resolve|systemd-timesync|tss|uuidd|dhcpcd|dnsmasq|rpc|avahi|colord|git|lightdm|nm-openconnect|nm-openvpn|ntp|openvpn|polkitd|rtkit|usbmux|cups|geoclue|gluster|rpcuser|unbound|rabbitmq' | jq -R . | jq -s .)

# Get lsb_release
lsb_release_info=$(lsb_release -a 2>/dev/null | awk -F':' '/Description|Release/ {printf "%s", $2}' | xargs)

# Get clocksource
clocksource=$(cat /sys/devices/system/clocksource/clocksource0/current_clocksource)

# Get timedatectl status
ntp_status=$(timedatectl show --property=NTP --value)

# Get current time and date
time_date=$(date)

# Get uptime
uptime=$(uptime -p)

# Get install date
install_date=$(ls -alct /|tail -1|awk '{print $6, $7, $8}')

# Get public IP
public_ip=$(curl -s ifconfig.me)

# PROCCESSOR

## Get CPU totals
cpu_total=$(lscpu | grep '^CPU(s):' | awk '{print $2}')

## Get detailed cpu usage
cpu_usage=$(sar -u 1 1 | tail -n 1 | awk '{printf "{\"user\":\"%s%%\", \"nice\":\"%s%%\", \"system\":\"%s%%\", \"idle\":\"%s%%\"}", $3, $4, $5, $8}')

## Get CPU min, max, and current frequency
cpu_min_freq=$(awk '{printf ("%.2f\n", $1/1000)}' /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq 2>/dev/null || echo "Unknown")
cpu_max_freq=$(awk '{printf ("%.2f\n", $1/1000)}' /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null || echo "Unknown")
cpu_cur_freq=$(awk '{printf ("%.2f\n", $1/1000)}' /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo "Unknown")

# MEMORY

# Get detailed memory usage
memory_usage=$(free -h | awk 'NR==3{printf "{\"total\":\"%s\", \"used\":\"%s\", \"free\":\"%s\", \"shared\":\"%s\", \"available\":\"%s\"}", $2, $3, $4, $5, $7}')

# NETWORK

## Detect primary network interface
network_interface=$(ip -br addr | grep UP | grep -vE "lo|docker|veth|br-|tun|tap|vnet|wlan" | awk '{print $1}' | head -n 1)

## Get the IP address associated with the primary network interface
network_ip_address=$(ip -br addr show $network_interface | awk '{print $3}')

## Get network usage (replace eth0 with your network interface name)
network_usage=$(sar -n DEV 1 1 | grep "$network_interface" | tail -n 1 | awk '{printf "{\"rxpck_s\":\"%s\", \"txpck_s\":\"%s\"}", $3, $4}')

## Get network speed (replace eth0 with your network interface name)
network_port_speed=$(ethtool $network_interface 2>/dev/null | grep -i 'Speed:' | awk '{print $2, $3}' | sed 's/ //g' || echo "Unknown")

## Get netstat port usage
port_usage=$(netstat -tuln | tail -n +3 | awk '{printf "{\"protocol\":\"%s\", \"address\":\"%s\"}\n", $1, $4}' | jq -s '.')

# Create JSON
jq -n \
  --arg hn "$hostname" \
  --arg ui "$uname_info" \
  --argjson us "$users" \
  --arg lsb "$lsb_release_info" \
  --arg cs "$clocksource" \
  --arg ntp "$ntp_status" \
  --arg td "$time_date" \
  --arg up "$uptime" \
  --arg id "$install_date" \
  --arg ct "$cpu_total" \
  --argjson cu "$cpu_usage" \
  --arg cmf "$cpu_min_freq" \
  --arg cxf "$cpu_max_freq" \
  --arg ccf "$cpu_cur_freq" \
  --argjson mu "$memory_usage" \
  --arg ip "$public_ip" \
  --arg nip "$network_ip_address" \
  --argjson nu "$network_usage" \
  --arg nps "$network_port_speed" \
  --argjson pu "$port_usage" \
  '{
    hostname: $hn,
    uname_info: $ui,
    users: $us,
    lsb_release: $lsb,
    clocksource: $cs,
    ntp_status: $ntp,
    time_date: $td,
    uptime: $up,
    install_date: $id,
    cpu: {
      total: $ct,
      usage: $cu,
      min_freq: $cmf,
      max_freq: $cxf,
      cur_freq: $ccf
    },
    memory_usage: $mu,
    network: {
      public_address: $ip,
      network_address: $nip,
      usage: $nu,
      port_speed: $nps,
      ports: $pu
    }
  }' > $jsonfile

echo "Data has been written to $jsonfile"
