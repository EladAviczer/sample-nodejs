# ADR-0004: Workload type: Deployment

## Context
- The app is a stateless Express server: no database, no files written, no volumes.
- Its only state is the in-memory `root_access_total` counter, which is per pod and resets on restart by design; Prometheus aggregates it across pods with `rate()`.
- Pods are interchangeable: any pod can serve any request, and none needs a stable name, a stable network identity, or its own storage.
- The workload must support rolling updates and horizontal autoscaling (HPA).

## Decision
Use a Deployment because:
- Stateless and interchangeable pods are exactly what a Deployment manages: a ReplicaSet with random pod names.
- Rolling updates with `maxSurge`/`maxUnavailable` replace pods without downtime, in parallel.
- HPA scales it directly, and pods start and stop in any order.
- Simplest controller to operate and explain; no PVCs or headless Service to manage.

## Alternatives considered
- StatefulSet: gives each pod a stable name (`sample-app-0`), stable DNS via a headless Service, and its own PVC through `volumeClaimTemplates`, with ordered start, stop, and updates. Rejected because the app needs none of these, and ordered one-at-a-time rollouts and PVC lifecycle management would only add slowness and operational cost.

## Consequences
- Good: fast parallel rollouts and scaling, no storage to back up or clean up, any pod can be rescheduled on any node.
- Bad: if the app ever needs durable state, it must go to an external store (database, S3) or the workload type must be revisited; per-pod in-memory counters are lost on restart.
