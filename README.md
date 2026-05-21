# ORAN O-Cloud Must-Gather

Custom OpenShift must-gather image for troubleshooting ORAN O-Cloud Manager deployments, including O2IMS, ACM/MCE, and spoke cluster provisioning.

## What it collects

| Category | Resources |
|---|---|
| **Cluster** | ClusterVersion, Infrastructure, Nodes, ClusterOperators, Proxy |
| **ORAN O2IMS** | ProvisioningRequests, ClusterInstances, ClusterTemplates, NodeAllocationRequests, AllocatedNodes, HardwareTemplates, HardwareProfiles |
| **RHACM/MCE** | MultiClusterHub, MultiClusterEngine, ManagedClusters, ClusterDeployments, AgentClusterInstalls, InfraEnvs, Agents, ClusterImageSets, AgentServiceConfig, Provisioning, ManagedClusterAddOns |
| **Hive** | ClusterDeployments, SelectorSyncSets, SyncSets, HiveConfigs |
| **Metal3/BMO** | BareMetalHosts, PreprovisioningImages, HostFirmwareSettings, HostFirmwareComponents, FirmwareSchemas, BMCEventSubscriptions |
| **GitOps/ArgoCD** | ArgoCD instances, Applications, ApplicationSets, GitOpsClusters, Placements, PlacementDecisions, ManagedClusterSets |
| **Policies** | Policies, ClusterGroupUpgrades (TALM), ConfigurationPolicies |
| **Spoke Clusters** | Per-cluster: ClusterDeployment, AgentClusterInstall, ClusterInstance, InfraEnv, Agents, BMH, NMStateConfigs, NodeAllocationRequests, Policies |
| **CRDs** | Relevant CRD definitions for all collected resource types |

For each namespace: pods (with current and previous logs, last 5000 lines), configmaps, secrets, services, endpoints, routes, deployments, statefulsets, daemonsets, replicasets, jobs, cronjobs, and events.

### Namespaces collected

| Namespace | Content |
|---|---|
| `oran-*` | Auto-discovered ORAN namespaces (oran-ocloud, oran-ocloud-clusters-sub, etc.) |
| `open-cluster-management` | ACM operator and controllers |
| `open-cluster-management-hub` | ACM hub controllers |
| `multicluster-engine` | MCE operator and controllers |
| `hive` | Hive controllers |
| `openshift-machine-api` | Metal3, Ironic, BMO pods and logs |
| `openshift-gitops` | ArgoCD server, application controller |
| `assisted-installer` | Assisted service |
| `ztp-*` | Auto-discovered ZTP namespaces |
| BMH pool namespaces | Auto-discovered from BareMetalHost locations (e.g., dell-xr8620t-pool) |
| Spoke cluster namespaces | Auto-discovered from ManagedClusters |

## Build

```bash
make build IMAGE_REPO=quay.io/bzhai/oran-must-gather

make push IMAGE_REPO=quay.io/bzhai/oran-must-gather
```

## Usage

```bash
# Collect all spoke clusters
oc adm must-gather --image=quay.io/bzhai/oran-must-gather:latest

# Save to a specific directory
oc adm must-gather --image=quay.io/bzhai/oran-must-gather:latest \
  --dest-dir=/tmp/oran-must-gather

# Collect only specific spoke clusters
oc adm must-gather --image=quay.io/bzhai/oran-must-gather:latest \
  -- SPOKE_CLUSTERS=sno171,sno146 /usr/bin/gather
```

By default, all spoke clusters (auto-discovered from ManagedClusters or ClusterDeployments) are collected. Set `SPOKE_CLUSTERS` to limit collection to specific clusters.

## Output structure

```
must-gather/
├── cluster-scoped/          # ClusterVersion, Nodes, ClusterOperators
├── oran/                    # O2IMS CRs (ProvisioningRequests, ClusterTemplates, etc.)
├── acm-mce/                 # RHACM/MCE cluster-scoped CRs
├── hive/                    # Hive CRs
├── metal3/                  # Metal3/BMO CRs (all namespaces)
├── gitops/                  # ArgoCD, Applications, Placements
├── policies/                # Policies, TALM CGUs
├── assisted-service/        # AgentServiceConfig
├── spoke-clusters/          # Per-spoke-cluster CRs
│   └── <cluster-name>/
│       ├── clusterinstance.yaml
│       ├── clusterdeployment.yaml
│       ├── agentclusterinstall.yaml
│       ├── baremetalhosts.yaml
│       ├── policies.yaml
│       └── ...
├── crds/                    # Relevant CRD definitions
└── namespaces/              # Per-namespace resources
    ├── oran-ocloud/
    ├── oran-ocloud-clusters-sub/
    ├── oran-ocloud-inventory-sub/
    ├── oran-ocloud-policies-sub/
    ├── open-cluster-management/
    ├── multicluster-engine/
    ├── hive/
    ├── openshift-machine-api/
    ├── openshift-gitops/
    ├── assisted-installer/
    ├── ztp-*/
    ├── <bmh-pool-ns>/
    └── <spoke-cluster-ns>/
        ├── pods.yaml
        ├── pod-logs/
        │   ├── <pod>_<container>.log
        │   └── <pod>_<container>_previous.log
        ├── configmaps.yaml
        ├── secrets.yaml
        ├── events.txt
        └── all-resources.txt
```
