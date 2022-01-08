# installation steps for local snapshot test
**NOTE**: hostpath snapshot is a simulation for csi snapshot interface. It's restricted to only single node env.

1. install CSI snapshot environment. 
- git clone https://github.com/kubernetes-csi/external-snapshotter
- install snapshot crd and controller

```
git checkout origin/release-4.0
kubectl apply -f client/config/crd
kubectl apply -f deploy/kubernetes/snapshot-controller

# replace snapshot controller's image to registry.cn-shanghai.aliyuncs.com/jibu-ys1000-testsnapshot-controller:v4.0.0
kubectl edit  statefulsets.apps snapshot-controller

[root@gyj-dev external-snapshotter]# kubectl get pods
NAME                              READY   STATUS      RESTARTS   AGE
...
snapshot-controller-0             1/1     Running     0          7m1s
```

2. git clone repo https://github.com/jerry-jibu/csi-driver-host-path and switch to `staging` branch
locate to hack directory and execute it. 
https://github.com/jerry-jibu/csi-driver-host-path/blob/staging/hack/new-csi-driver-chart-values-yaml.sh 

```
$ ./new-csi-driver-chart-values-yaml.sh
usage: ./new-csi-driver-chart-values-yaml.sh <suffix>
this script will generate chart values.yaml to deploy a new csi hostpath driver. The new driver will have its own data dir, storage class, snapshot class, driver name etc, so that you can deploy multiple hostpath csi drivers in one cluster.
e.g. ./new-csi-driver-chart-values-yaml.sh -b
```

3. check the configuraiton and pods are launached and storageclass and volumesnapshotclass should be installed.

```
[root@ui-dev-master samples]# k get pods -n csi-hostpath-b
NAME                         READY   STATUS    RESTARTS   AGE
csi-hostpath-attacher-0      1/1     Running   0          33m
csi-hostpath-provisioner-0   1/1     Running   0          33m
csi-hostpath-resizer-0       1/1     Running   0          33m
csi-hostpath-snapshotter-0   1/1     Running   0          33m
csi-hostpath-socat-0         1/1     Running   0          33m
csi-hostpathplugin-0         5/5     Running   0          33m

[root@ui-dev-master samples]# k get sc
NAME                  PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
csi-hostpath-b        hostpath.csi.k8s.io-b   Delete          Immediate           true                   34m

[root@ui-dev-master samples]# k get volumesnapshotclasses.snapshot.storage.k8s.io
NAME             DRIVER                  DELETIONPOLICY   AGE
csi-hostpath-b   hostpath.csi.k8s.io-b   Delete           34m

```

4. test the pvc and snapshot under hack/samples examples.

```
kubectl apply -f ./pvc.yaml

kubectl get pvc
NAME                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
csi-pvc                     Bound    pvc-ea810b8c-c680-4c9b-9068-58da1563ef41   1Gi        RWO          csi-hostpath-b        5m48s

kubectl apply -f snapshot.yaml

[root@gyj-dev external-snapshotter]# kubectl get volumesnapshots.snapshot.storage.k8s.io
NAME               READYTOUSE   SOURCEPVC   SOURCESNAPSHOTCONTENT   RESTORESIZE   SNAPSHOTCLASS    SNAPSHOTCONTENT                                    CREATIONTIME   AGE
csi-pvc-snapshot   true         csi-pvc                             1Gi           csi-hostpath-b   snapcontent-79e07b69-c84b-4c3d-99ff-fa77de967637   6m32s          6m32s

```