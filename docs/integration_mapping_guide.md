# DIASCA Integration Mapping Guide

This guide explains how external applications (Farm Registries, GIS Apps, Traceability Systems) should integrate with the DIASCA Central DPI Node.

## 1. Integration Philosophy

The golden rule of DIASCA integration is: **You do not need to change your internal database schema.**

A participating application only needs to:
1. **Understand** the DIASCA canonical resources (Person, Enterprise, Site, Lot, Claim).
2. **Map** its internal objects to those canonical resources when communicating with the DPI API.
3. **Respect** DIASCA identifiers (UUIDs) when transmitting data.

## 2. Platform Archetypes & Mapping Workflows

### A. Farmer Registry / Cooperative App
**Goal**: Sync farmer and farm data to the central node.
* **Internal Concept**: `Farmer` or `Member`
  * **DIASCA Mapping**: `Person` (role: farmer)
* **Internal Concept**: `Cooperative Group`
  * **DIASCA Mapping**: `Enterprise` (type: cooperative)
* **Internal Concept**: `Farm Plot`
  * **DIASCA Mapping**: `Site` (type: plot)
* **Required Scopes**: `people:read`, `people:create`, `enterprises:read`, `sites:create`

### B. Farm Mapping / Drone App
**Goal**: Provide high-accuracy plot geometries for EUDR compliance.
* **Workflow**: 
  1. App reads existing Sites from DIASCA (`sites:read`).
  2. App collects drone/GPS polygon.
  3. App calls the Domain Operation `POST /v2/sites/{site_id}:updateGeometry`.
* **Required Scopes**: `sites:read`, `sites:update_geometry`

### C. Traceability System (Chain of Custody)
**Goal**: Track product movement and transformation.
* **Internal Concept**: `Batch`, `Shipment`, `Silo`
  * **DIASCA Mapping**: `Lot`
* **Workflow (Transformation)**: 
  When a wet mill processes 5 batches of cherries into 1 batch of parchment, the Traceability system calls `POST /v2/lots:merge` or `POST /v2/events/{event_id}:recordTransformation` on the DIASCA node.
* **Required Scopes**: `lots:read`, `lots:create`, `lots:transform`, `lineage:create`

### D. Certification Body
**Goal**: Issue or verify compliance certificates.
* **Internal Concept**: `Audit Finding`, `Certificate`
  * **DIASCA Mapping**: `Claim` (type: certification) + `Evidence`
* **Workflow**:
  1. Call `POST /v2/claims` to issue a new certification claim against a Site or Enterprise.
  2. Upload the certificate PDF and call `POST /v2/evidence` to link it.
* **Required Scopes**: `claims:read`, `claims:create`, `claims:verify`, `evidence:create`

## 3. Example Client Integration (Python)

Here is a simple example using `httpx` to register a Farmer and their Plot.

```python
import httpx
import uuid

API_BASE = "https://api.diasca.org/v2"
HEADERS = {"Authorization": "Bearer your_oauth_token"}

# 1. Register the Farmer
person_data = {
    "name": "Kofi Mensah",
    "role": "farmer",
    "created_by_system": "coop_registry_v1",
    "authority_type": "cooperative_registry"
}
resp = httpx.post(f"{API_BASE}/people", json=person_data, headers=HEADERS)
person_id = resp.json()["person_id"]

# 2. Register the Plot
site_data = {
    "name": "Mensah Plot 1",
    "type": "plot",
    "owner_person_id": person_id,
    "country": "CI",
    "size": 2.4,
    "geometry": {
        "type": "Polygon",
        "coordinates": [[[-6.44, 6.84], [-6.43, 6.84], [-6.43, 6.83], [-6.44, 6.84]]]
    }
}
httpx.post(f"{API_BASE}/sites", json=site_data, headers=HEADERS)
```
