# Setup the Bridge

Containerized script configuring Linux bridge interface as the default network
interface.

## Run the container via podman

```shell
podman run \
  -e BRIDGE_NAME=brext \
  -e NIC_NAME=eno2 \
  -e KEEP_RUNNING=0 \
  -v /run/dbus/system_bus_socket:/run/dbus/system_bus_socket \
  --network host \
  quay.io/phoracek/setup-the-bridge:devel
```

## Run the container as a daemon set

TODO:

```yaml
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: setup-the-bridge
  namespace: kube-system
  labels:
    k8s-app: setup-the-bridge
spec:
  selector:
    matchLabels:
      name: setup-the-bridge
  template:
    metadata:
      labels:
        name: setup-the-bridge
    spec:
      containers:
      - name: setup-the-bridge
        image: quay.io/phoracek/setup-the-bridge
        env:
        - name: BRIDGE_NAME
          value: "brext"
        - name: NIC_NAME
          value: "eno2"
        - name: KEEP_RUNNING
          value: "1"
EOF
```

## Build the container image for testing

Images are automatically build when a patch is merged on
`quay.io/phoracek/setup-the-bridge`. When building unmerged versions, use
following commands.

```shell
podman build -t quay.io/phoracek/setup-the-bridge:devel .
podman push quay.io/phoracek/setup-the-bridge:devel
```
