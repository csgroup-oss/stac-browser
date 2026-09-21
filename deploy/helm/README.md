
# stac-browser

A Helm chart for STAC Browser

## Prerequisites

- Kubernetes: `>=1.23.0-0`
- Helm 3.8.0+

## Installing the Chart

```console
helm upgrade --install stac-browser ./deploy/helm \
  --namespace stac-browser \
  --create-namespace \
  -f values.yaml
```

## Common Configuration

### STAC Browser Options

Use `options` to pass STAC Browser options generically without mirroring individual upstream settings in this chart.
Each key is converted to an environment variable named `SB_<key>`.

Supported option names, expected value shapes, and feature semantics are documented upstream in the STAC Browser options reference:

- [STAC Browser options documentation](https://github.com/radiantearth/stac-browser/blob/main/docs/options.md)

Example:

```yaml
options:
  catalogUrl: https://stac.example.com
  catalogTitle: Example STAC Browser
  supportedLocales:
    - en
    - fr
  authConfig:
    type: openIdConnect
    openIdConnectUrl: https://auth.example.com/realms/METIS/.well-known/openid-configuration
    oidcConfig:
      client_id: stac-browser
```

The chart JSON-encodes non-string values automatically, which makes object and array options easier to manage from YAML.

Use `extraEnvVars` only for raw environment variable injection that is not covered by `options`.
It follows the standard Kubernetes `env` list format.

Some upstream settings require a JavaScript function or a custom config file and therefore cannot be expressed safely as environment variables alone.
For those cases, use a custom `config.js` or a custom image.

### Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: stac-browser.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: stac-browser-tls
      hosts:
        - stac-browser.example.com
```

### Gateway API

```yaml
listenerset:
  enabled: true
  parentRef:
    name: shared-gateway
    namespace: infra
  hostname: stac-browser.example.com

httproute:
  enabled: true
```

### Autoscaling And Availability

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 75

podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

### Private Images

Use a custom image and registry credentials:

```yaml
image:
  repository: registry.example.com/stac-browser
  tag: 5.1.0-custom

imagePullSecrets:
  - name: registry-credentials
```

You can also pin the image by digest instead of tag:

```yaml
image:
  repository: ghcr.io/radiantearth/stac-browser
  digest: sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
```

If both `tag` and `digest` are set, the chart renders the Kubernetes-compatible form `repository:tag@digest`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for the pod |
| autoscaling.enabled | bool | `false` | Enable HorizontalPodAutoscaler creation |
| autoscaling.maxReplicas | int | `3` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target average CPU utilization percentage |
| autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target average memory utilization percentage |
| commonAnnotations | object | `{}` | Common annotations added to Deployment, Service, and Ingress resources |
| commonLabels | object | `{}` | Common labels added to every resource |
| deploymentAnnotations | object | `{}` | Additional annotations for the Deployment |
| deploymentLabels | object | `{}` | Additional labels for the Deployment |
| deploymentStrategy | object | `{}` | Deployment strategy |
| extraEnvFrom | list | `[]` | Additional envFrom entries |
| extraEnvVars | list | `[]` | Additional raw environment variables as a Kubernetes `env` list. Prefer `options` for STAC Browser options. |
| extraObjects | list | `[]` | Extra raw Kubernetes objects rendered with `tpl` |
| extraVolumeMounts | list | `[]` | Additional volume mounts appended after `volumeMounts` |
| extraVolumes | list | `[]` | Additional volumes appended after `volumes` |
| fullnameOverride | string | `""` | String to fully override the default chart name (`stac-browser`) |
| hostAliases | list | `[]` | Host aliases added to the pod |
| httproute.annotations | object | `{}` | Additional annotations added to the HTTPRoute |
| httproute.enabled | bool | `false` | Enable HTTPRoute creation |
| httproute.hostnames | list | `[]` | Optional hostnames for the route. When empty and `listenerset.hostname` is set, that hostname is used. |
| httproute.labels | object | `{}` | Additional labels added to the HTTPRoute |
| httproute.parentRefs | list | `[]` | Explicit parent references. When empty and `listenerset.enabled=true`, the route attaches to the chart ListenerSet. |
| httproute.rules | list | `[{"matches":[{"path":{"type":"PathPrefix","value":"/"}}]}]` | HTTPRoute rules forwarded to the STAC Browser service |
| image.digest | string | `""` | Optional image digest. When both `tag` and `digest` are set, the chart renders `repository:tag@digest`. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.registry | string | `""` | Optional image registry prefix |
| image.repository | string | `"ghcr.io/radiantearth/stac-browser"` | Container image repository |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets for the STAC Browser pod |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Enable ingress creation |
| ingress.hosts | list | `[{"host":"stac-browser.example.com","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Ingress host rules |
| ingress.labels | object | `{}` | Additional labels added to the ingress |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| initContainers | list | `[]` | Extra init containers |
| listenerset.allowedRoutes | object | `{"namespaces":{"from":"Same"}}` | Allowed routes for the shared listener |
| listenerset.annotations | object | `{}` | Additional annotations added to the ListenerSet |
| listenerset.enabled | bool | `false` | Enable creation of a shared ListenerSet resource |
| listenerset.hostname | string | `""` | Listener hostname. When empty, the listener does not set a hostname |
| listenerset.labels | object | `{}` | Additional labels added to the ListenerSet |
| listenerset.listenerName | string | `"https"` | Name of the shared listener |
| listenerset.listeners | list | `[]` | Explicit listener list. When set, overrides the synthesized listener fields above. |
| listenerset.parentRef | object | `{}` | Parent Gateway reference for the ListenerSet |
| listenerset.port | int | `443` | Listener port |
| listenerset.protocol | string | `"HTTPS"` | Listener protocol |
| listenerset.tls.enabled | bool | `true` | Enable TLS on the listener |
| listenerset.tls.mode | string | `"Terminate"` | TLS termination mode |
| listenerset.tls.secretName | string | `""` | Secret name containing the TLS certificate. Defaults to `{hostname}-tls` when hostname is set. |
| livenessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | Liveness probe configuration |
| nameOverride | string | `"stac-browser"` | Provide a name in place of `stac-browser` |
| namespaceOverride | string | `.Release.Namespace` | Override the namespace |
| nodeSelector | object | `{}` | Node selector for the pod |
| options | object | `{}` | STAC Browser options exposed as `SB_*` environment variables. Use option names exactly as documented upstream, without the `SB_` prefix. Non-string values are JSON-encoded before injection. Format: `key: value`. See: https://github.com/radiantearth/stac-browser/blob/main/docs/options.md |
| podAnnotations | object | `{}` | Annotations added to the pod template |
| podDisruptionBudget.enabled | bool | `false` | Enable PodDisruptionBudget creation |
| podDisruptionBudget.maxUnavailable | string | `nil` | Maximum number of unavailable pods |
| podDisruptionBudget.minAvailable | int | `1` | Minimum number of available pods |
| podLabels | object | `{}` | Labels added to the pod template |
| podSecurityContext | object | `{}` | Pod-level security context |
| priorityClassName | string | `""` | Pod priority class name |
| readinessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | Readiness probe configuration |
| replicaCount | int | `1` | Number of STAC Browser replicas when autoscaling is disabled |
| resources | object | `{}` | Resource requests and limits for the container |
| revisionHistoryLimit | int | `3` | Number of old ReplicaSets to retain |
| runtimeClassName | string | `""` | RuntimeClass name to use for the pod |
| securityContext | object | `{}` | Container security context |
| service.annotations | object | `{}` | Additional annotations added to the service |
| service.extraPorts | list | `[]` | Additional service ports |
| service.labels | object | `{}` | Additional labels added to the service |
| service.port | int | `8080` | Main service port |
| service.portName | string | `"http"` | Main service port name |
| service.targetPort | string | `"http"` | Target port for the main service port |
| service.type | string | `"ClusterIP"` | Kubernetes service type |
| startupProbe | object | `{"failureThreshold":30,"httpGet":{"path":"/","port":"http"},"periodSeconds":2}` | Startup probe configuration |
| terminationGracePeriodSeconds | string | `nil` | Pod termination grace period in seconds |
| tolerations | list | `[]` | Tolerations for the pod |
| topologySpreadConstraints | list | `[]` | Topology spread constraints for the pod |
| volumeMounts | list | `[]` | Additional volume mounts on the Deployment definition |
| volumes | list | `[]` | Additional volumes on the Deployment definition |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs][helm-docs]

[helm-docs]: https://github.com/norwoodj/helm-docs