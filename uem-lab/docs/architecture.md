# Architecture decisions

This document explains the design rationale behind the Unified Endpoint Management Lab environment for Northgate Solutions.

## Tenant design

The lab uses a single Microsoft 365 E5 trial tenant linked to an Azure free-tier subscription. Both services share the same tenant ID, which means Entra ID acts as the single identity provider for Azure resources, Microsoft 365 apps, and all integrated enterprise applications.

In production, many organizations maintain separate tenants for dev/test and production. This lab uses a single tenant for simplicity, but the governance structure (management groups, resource groups, tagging) mirrors a production setup.

## Resource hierarchy

```
Root Management Group
└── Northgate Solutions (Management Group)
    └── Azure Subscription ($200 free credit)
        ├── RG-Identity      — Reserved for identity-related resources
        ├── RG-Networking     — Reserved for VNets, NSGs, DNS
        └── RG-Workloads      — VMs, app services, storage
```

**Why this structure?** Management groups allow policy inheritance at scale. By placing the subscription under "Northgate Solutions," any Azure Policy assigned at the management group level automatically applies to all resource groups and resources beneath it. This is how enterprises enforce governance without manually assigning policies to each subscription.

## Tagging strategy

Every resource is tagged with:

| Tag | Purpose | Example |
|-----|---------|---------|
| `Environment` | Distinguish lab/dev/prod | `Lab` |
| `Project` | Cost attribution | `UEM-Lab` |
| `Owner` | Accountability | `YourName` |
| `CostCenter` | Chargeback simulation | `IT` |

Tags are enforced via Azure Policy — any resource created without the `Environment` tag is denied.

## Identity design

See [identity-design.md](identity-design.md) for the full user/group/role matrix.

## Network considerations

The Windows 11 VM in Parallels uses **bridged networking** so it receives its own IP address on the local network. This is important for two reasons:

1. Conditional Access location-based policies evaluate the source IP. With NAT networking, the VM shares the host's IP and location policies can't distinguish between the Mac (admin) and the VM (endpoint).
2. Bridged mode more accurately simulates a real corporate endpoint that would have its own network identity.

## Cost management

The entire lab runs within free-tier limits:

- Microsoft 365 E5 trial: 30 days, no charge
- Azure free account: $200 credit for 30 days
- No paid VM instances required (the Windows 11 VM runs locally in Parallels)
- Azure Policy assignments: free
- Entra ID P2 features (PIM, Identity Protection): included in E5 trial
