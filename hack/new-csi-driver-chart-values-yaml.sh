#!/bin/bash

if [[ $# -ne 1 ]]
then
  echo "usage: $0 <suffix>"
  echo "this script will generate chart values.yaml to deploy a new csi hostpath driver. The new driver will have its own data dir, storage class, snapshot class, driver name etc, so that you can deploy multiple hostpath csi drivers in one cluster."
  echo "e.g. $0 -a"
  exit 1
fi

chart=../deploy/chart
out="/tmp/values-$RANDOM.yaml"
suffix="$1"

echo "
storageClass:
  name: csi-hostpath${suffix}
  isDefaultStorageClass: false

snapshotClass:
  name: csi-hostpath${suffix}
  isDefaultSnapshotClass: false

driver:
  name: hostpath.csi.k8s.io${suffix}

snapshot-controller:
  enabled: false

attacher:
  clusterRoleName: external-attacher-runner${suffix}
  clusterRoleBindingName: csi-attacher-role${suffix}

plugins:
  healthMonitorController:
    clusterRoleName: external-health-monitor-controller-runner${suffix}
    clusterRoleBindingName: csi-health-monitor-controller-role${suffix}
  hostPathPlugin:
    tag: v0.9.0
    dataDir: /var/lib/csi-hostpath-data${suffix}/

provisioner:
  clusterRoleName: external-provisioner-runner${suffix}
  clusterRoleBindingName: csi-provisioner-role${suffix}

resizer:
  clusterRoleName: external-resizer-runner${suffix}
  clusterRoleBindingName: csi-resizer-role${suffix}

snapshotter:
  clusterRoleName: external-snapshotter-runner${suffix}
  clusterRoleBindingName: csi-snapshotter-role${suffix}

" > $out

echo "new values.yaml file: $out"

echo "to install: helm install csi-hostpath${suffix} $chart -n csi-hostpath${suffix} --create-namespace -f $out"