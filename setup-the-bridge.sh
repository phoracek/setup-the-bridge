#!/usr/bin/env bash

set -xe

bridge_name=${BRIDGE_NAME}
nic_name=${NIC_NAME}
keep_running=${KEEP_RUNNING:-0}

VLAN_RANGE="1-4094"

if [ -z "${bridge_name}" ]; then
    echo 'Please define name of the bridge via BRIDGE_NAME variable'
    exit 1
fi

if [ -z "${nic_name}" ]; then
    echo 'Please define name of the NIC via NIC_NAME variable'
    exit 1
fi

if [[ ! $(ip address show $nic_name) ]]; then
    echo "Interface ${nic_name} has not been found in the system"
    exit 1
fi

BRIDGE_PROFILE_NAME="setup-the-bridge-${bridge_name}"
PORT_PROFILE_NAME="setup-the-bridge-port-${nic_name}"

if [[ ! $(nmcli --fields connection.id con show ${BRIDGE_PROFILE_NAME}) ]]; then
    echo 'Bridge connection profile does not exists yet, creating it'
    nmcli con add type bridge ifname ${bridge_name} con-name ${BRIDGE_PROFILE_NAME}
    nmcli con mod ${BRIDGE_PROFILE_NAME} connection.autoconnect-slaves 1
fi

if [[ ! $(nmcli --fields connection.id con show ${PORT_PROFILE_NAME}) ]]; then
    echo 'Port connection profile does not exists yet, creating it'
    nmcli con add type bridge-slave ifname ${nic_name} con-name ${PORT_PROFILE_NAME} master ${BRIDGE_PROFILE_NAME}
fi

echo 'Activate bridge connection profile'
nmcli con up ${BRIDGE_PROFILE_NAME}

echo 'Enable vlan filtering on the bridge'
ip link set dev ${bridge_name} type bridge vlan_filtering 1

echo 'Enable trunk on the southbound port'
bridge vlan add dev ${bridge_name} vid ${VLAN_RANGE} self
bridge vlan add dev ${nic_name} vid ${VLAN_RANGE}

if [ ${keep_running} -ne 0 ]; then
    echo 'Blocking forever'
    sleep INF
fi
