# Overview

Operators and Traders will submit data to the EU Information System (Traces) using a GeoJSON (details for that GeoJSON described elsewhere, including in [this guide](https://www.atibt.org/files/upload/newsletter/1_EUDR_-_Gelocation_file_description_1-0.pdf?utm_source)). 

The data exchange format presented here is intended to provide a template for the additional information that will regularly be transmitted across the value chain, and are likely to be requested by operators and traders from their suppliers.  

This information may include data such as whether remote sensing detected deforestation, encroachment on protected or indigenous lands, whether there is forest present with the plot that needs to be monitored, or the timing and findings of the most recent field-audit of the site.

While not reported directly into Traces, this information may constitute part the risk assessment and mitigation steps by operators and traders and may need to be presented in the event they are selected for an audit by the competent authorities. 

## Data Model

[DBML](/dbml/diasca-model.md) file.

## Summary of Attributes

| Property Name                                                                                | Type | Format / Example | Validation | Description | Unit of Analysis | Reason for capturing | Location in Data Model |
|:---------------------------------------------------------------------------------------------| :---- | ----- | :---- | :---- | :---- | :---- | :---- |
| Name                                                                                         | String | "plots\_2025\_07.geojson" | Non-empty; no spaces or special chars; .geojson extension. | Name of file | GeoJSON file | Additional Information | DataSouce |
| type                                                                                         | String | "Feature" | Exactly "Feature" | Should be "Feature" for each object | GeoJSON file | Standard GeoJSON | NA |
| Commodity                                                                                    |  |  |  |  | contract (one or more) | EU IS Fields | Attributes (associated with Business Transaction via Records) |
| Species                                                                                      |  |  |  |  | contract (one or more) | EU IS Fields | Attributes (associated with Business Transaction via Records) |
| ProductionDate                                                                               |  |  |  |  | contract (one or more) | EU IS Fields | Attributes (associated with Business Transaction via Records) |
| QuantityKilograms                                                                          |  |  |  |  | contract (one or more) | EU IS Fields | Attributes (associated with Business Transaction via Records) |
| **geometry**                                                                                 | Object |  |  | Must include both **type** and **coordinates** | plot | Standard GeoJSON | Sites-Records-Atributes |
| geometry.type                                                                                | String | "Polygon", "Point", etc. | Must be one of valid GeoJSON types. | e.g. Polygon, Point | plot | Standard GeoJSON | Enterprises-Sites-Records-Atributes |
| geometry.coordinates                                                                         | Array | \[ \[lon, lat\], ... \] | Valid coordinate pairs in WGS84; correct structure per geometry type. | Array of coordinates | plot | Standard GeoJSON | Enterprises-Sites-Records-Atributes |
| **properties**                                                                               | Object |  |  | Section, not attribute. Must exist, can be {} | contract | Standard GeoJSON | NA |
| properties.Area                                                                              | Number | 3.2 | If geometry is Point: required (\>=0.01); if Polygon: optional. | Area in hectares for point features; optional for polygons. If omitted the EU IS will assume an area of 4 has. | plot | EU IS Fields | Enterprises-Sites |
| properties.ProducerName                                                                      | String | "Farmer Name 1" | Optional; ≤100 chars. | An optional producer name for the corresponding geometry type. This field allows one to associate multiple plots to a single producer. | plot | EU IS Fields | Sites-Enterprises |
| properties.ProductionPlace                                                                   | String | "Plot-001" | Non-empty; unique within file. | Unique name or ID of the plot. | plot | EU IS Fields | Enterprises-Sites |
| properties.ProducerCountry                                                                   | String | "CO", "BR" | Check against ISO 3166‑1 alpha‑2 list; uppercase. | ISO 3166‑1 alpha‑2 country code. Used in EU IS and essential for legal risk assessment. | Noting that the sample file from importer had this per plot, however wondering if instead plots could be grouped by region, so the hierarchy would be: 1\) contract 2\) regions (1 or more per contract) 3\) plots (1 or more per region) Although according to this article [https://www.atibt.org/files/upload/newsletter/1\_EUDR\_-\_Gelocation\_file\_description\_1-0.pdf?utm\_source=chatgpt.com](https://www.atibt.org/files/upload/newsletter/1_EUDR_-_Gelocation_file_description_1-0.pdf?utm_source=chatgpt.com) it is ProducerCountry, so maybe it needs to be at the plot level? It is also optional though | EU IS Fields | Enterprises-Sites |
| properties.ProducerRegion                                                                    | String | "Amazonas" | Optional; free-text length limit (e.g., \<=100 chars). | Subnational region for risk evaluation. | see above | Additional Information | Group\-Sites-Records-Atributes |
| properties.RegionalRiskNonCompliance                                                         | String | Documented risk of child labor, and corruption in the region | Optionally free text | Summary of regional legal compliance risks. This summary of any risks of non-compliance with relevant legislation of the country of production. While this information is not loaded to the EU IS, it is key information to inform the risk assessment and mitigation by operators, and may be referenced during an audit by the competent authorities. | region, as noted above | Additional Information | Group\-Sites-Records-Atributes |
| properties.ReferencesRegionalRiskNonCompliance                                               | String | European Forest Institute Report: Traceability, transparency and sustainability in the cocoa sector in Cameroon | Sources supporting the risk summary. | Reference(s) for the RegionalRiskNonCompliance noted above. | region, as noted above | Additional Information | Group\-Sites-Records-Atributes |
| properties.RegionalIndigenousPresence                                                        | String | Indigenous present in the subregion | Optionally free text | Indication of whether there are indigenous communities present in the surrounding area | region, as noted above | Additional Information | Group\-Sites-Records-Atributes |
| properties.ReferencesRegionalIndigenousPresence                                              | String | European Forest Institute Report: Traceability, transparency and sustainability in the cocoa sector in Cameroon | Sources supporting the risk summary. | Reference(s) for the RegionalIndigenousPresence noted above. | region, as noted above | Additional Information | Group\-Sites-Records-Atributes |
| properties.RegionalRiskDeforestation                                                         |  | Deforestation noted in focus crop within the sourcing region | Optionally free text | Subnational region for deforestation risk evaluation. | region, as noted above | Additional Information | Enterprises-Sites-Records-Atributes |
| properties.ReferencesRegionalRiskDeforestation                                               | String | Remote sensing tool X | Sources supporting the risk summary. | Reference(s) for the RegionalRiskDeforestation noted above. | region, as noted above | Additional Information | Enterprises-Sites-Records-Atributes |
|                                                                                              |  |  |  |  |  |  |  |
| properties.Contracts                                                                         | Array |  |  |  | contract | Additional Information |  |
| properties.Contracts.SellerContractReference                                                 | String | "BR-COFFEE-2024-001" | Required string | For internal traceability purposes to link plots to contracts, and in the event that | contract | Additional Information | Enterprises-BusinessTransactions |
| properties.Contracts.BuyerContractReference                                                  | String | "KT-PURCHASE-2024-789" | Required string |  | contract | Additional Information | Enterprises-BusinessTransactions |
| properties.Contracts.Date                                                                    | Date String | "2025-02-28" | Required string in date format (YYYY-MM-DD) |  | contract | Additional Information | Enterprises-BusinessTransactions |
| properties.Contracts.Container                                                               | String (with pattern) | "ABCU1234567" | Required string matching pattern ^\[A-Z\]{3}\[UJZ\]\[0-9\]{6}\[0-9\]$ (ISO 6346 container format) |  | contract | Additional Information | Enterprises-BusinessTransactions-Records-Atributes |
| properties.Contracts.Certifications                                                          | Array |  |  |  | contract | Additional Information |  |
| [properties.Contracts.Certifications.Name](http://properties.contracts.certifications.name/) | String | "Rainforest Alliance" | Required string | Name of the certification body or certification standard |  | Additional Information |  |
| [properties.Contracts.Certifications.ID](http://properties.contracts.certifications.id/)     | String | "FT-BR-2024-002" | Required string | Unique identifier or certificate number for the certification |  | Additional Information |  |
| properties.DateMostRecentRemoteSensing                                                       | Date String | "2025-06-30" | ISO8601 date; not future. | Date of the latest remote sensing analysis. | plot | Additional Information | Enterprises-Sites |
| properties.RemoteSensingTools                                                                | String or Array\<String\> | "PlanetScope", \["Sentinel-2","PlanetScope"\] | At least one entry; valid predefined list if possible. | Tools or satellites used. | plot | Additional Information | Enterprises-Sites |
| properties.DeforestationDetectedRemoteSensing                                                | Boolean | TRUE | Must be boolean. | Whether deforestation was detected via remote sensing. | plot | Additional Information | Enterprises-Sites |
| properties.DateGroundTruthing                                                                | Date String | "2025-07-01" | ISO8601 date; ≥ corresponding remote sensing date. | Date of field verification. | plot | Additional Information | Enterprises-Sites |
| properties.FindingsGroundTruthing                                                            | String | "No deforestation observed; some encroachment" | Free text; ≤500 chars. | Summary of field findings. | plot | Additional Information | Enterprises-Sites |
| properties.FindingsGroundTruthingAttachment                                                  | Attachment | \[geo-stamped photographs of crops whose size demonstrate they had been growing prior to cut-off, or document demonstrating farming activities prior to 2020 cut-off\] |  |  | plot | Additional Information | Enterprises-Sites |
| properties.IndigenousLandInfringementRemoteSensing                                           | Boolean | FALSE | Boolean (true/false) | Remote sensing detection of infringement on indigenous land. | plot | Additional Information | Enterprises-Sites |
| properties.ProtectedLandInfringementRemoteSensing                                            | Boolean | FALSE | Boolean (true/false) |  | plot | Additional Information | Enterprises-Sites |
| properties.LegalProvisionOrConcession                                                        | String | "Land use permit \#LP-2023-456" | String (optional) |  |  | Additional Information | Enterprises-Sites |
|                                                                                              |  |  |  |  |  |  |  |
| properties.DateMostRecentAudit                                                               | Date String | "2024-01-20" | String in date format (YYYY-MM-DD) | Date of the most recent audit conducted | plot | Additional Information | Enterprises-Sites |
| properties.AuditMethodImplementer                                                            | String | "Independent Audit Co." | String (optional) | Organization or entity that implemented the audit methodology | plot | Additional Information | Enterprises-Sites |
| properties.DeforestationDetectedAudit                                                        | Boolean | FALSE | Boolean (true/false) | Whether deforestation was detected during the audit | plot | Additional Information | Enterprises-Sites |
| properties.IndigenousLandInfringementAudit                                                   | Boolean | FALSE | Boolean (true/false) | Whether indigenous land infringement was found during the audit | plot | Additional Information | Enterprises-Sites |
| **properties.ProtectedLandInfringementAudit**                                                | Boolean | FALSE | Boolean (true/false) | Whether protected land infringement was found during the audit | plot | Additional Information | Enterprises-Sites |
| properties.DateMostRecentLegalityAssessment                                                  | Date String | "2024-02-10" | String in date format (YYYY-MM-DD) | Date of the most recent legality assessment | plot | Additional Information | Enterprises-Sites |
| properties.ComplianceIssuesFound                                                             | Boolean | FALSE | Boolean (true/false) | Whether any compliance issues were identified | plot | Additional Information | Enterprises-Sites |
| properties.ComplianceIssuesDetails                                                           | String | "No compliance issues identified during assessment" | String (optional) | Detailed description of any compliance issues found | plot | Additional Information | Enterprises-Sites |

## Template:

    ```json
    {  
        "$id": "http://cosa.com/schema.json\#",  
        "$schema": "http://json-schema.org/draft-07/schema\#",  
        "type": "object",  
        "properties": {  
            "type": {"type": "string", "enum": \["FeatureCollection"\]},  
            "properties": {  
                "type": "object",  
                "properties": {  
                    "ProducerCountry": {"type": "string", "pattern": "^\[A-Z\]{2}$"},  
                    "ProducerRegion": {"type": "string"},  
                    "RegionalRiskNonCompliance": {"type": "string"},  
                    "ReferencesRegionalRiskNonCompliance": {"type": "string"},  
                    "Contracts": {  
                      "type": "array",  
                      "items": {  
                        "type": "object",  
                        "properties": {  
                          "SellerContractReference": {"type": "string"},  
                          "BuyerContractReference": {"type": "string"},  
                          "Container": {"type": "string", "pattern": "^\[A-Z\]{3}\[UJZ\]\[0-9\]{6}\[0-9\]$"},  
                          "Date": {"type": "string", "format": "date"},  
                          "Certifications": {  
                              "type": "array",  
                              "items": {  
                                  "type": "object",  
                                  "properties": {  
                                      "Name": {"type": "string"},  
                                      "ID": {"type": "string"}  
                                  },  
                                  "required": \["Name", "ID"\]  
                              }  
                          }  
                        },  
                        "required": \["SellerContractReference", "BuyerContractReference", "Container", "Date", "Certifications"\]  
                      }  
                    }  
                },  
                "required": \["ProducerCountry", "ProducerRegion", "RegionalRiskNonCompliance", "ReferencesRegionalRiskNonCompliance",  "Contracts"\]  
            },  
            "features": {  
                "type": "array",  
                "items": {  
                    "type": "object",  
                    "properties": {  
                        "type": {"type": "string", "enum": \["Feature"\]},  
                        "properties": {  
                            "type": "object",  
                            "properties": {  
                                "ProducerName": {"type": "string"},  
                                "ProductionPlace": {"type": "string"},  
                                "Area": {"type": "number"},  
                                "DateMostRecentRemoteSensing": {  
                                    "type": "string",  
                                    "format": "date"  
                                },  
                                "RemoteSensingTools": {"type": "string"},  
                                "DeforestationDetectedRemoteSensing": {  
                                    "type": "boolean"  
                                },  
                                "DateGroundTruthing": {"type": "string","format": "date"},  
                                "FindingsGroundTruthing": {"type": "string"},  
                                "IndigenousLandInfringementRemoteSensing": {  
                                    "type": "boolean"  
                                },  
                                "ProtectedLandInfringementRemoteSensing": {  
                                    "type": "boolean"  
                                },  
                                "LegalProvisionOrConcession": {"type": "string"},  
                                "DateMostRecentAudit": {  
                                    "type": "string",  
                                    "format": "date"  
                                },  
                                "AuditMethodImplementer": {"type": "string"},  
                                "DeforestationDetectedAudit": {"type": "boolean"},  
                                "IndigenousLandInfringementAudit": {  
                                    "type": "boolean"  
                                },  
                                "ProtectedLandInfringementAudit": {  
                                    "type": "boolean"  
                                },  
                                "DateMostRecentLegalityAssessment": {  
                                    "type": "string",  
                                    "format": "date"  
                                },  
                                "ComplianceIssuesFound": {"type": "boolean"},  
                                "ComplianceIssuesDetails": {"type": "string"}  
                            },  
                            "required": \["ProductionPlace", "Area"\]  
                        },  
                        "geometry": {  
                            "type": "object",  
                            "properties": {  
                                "type": {  
                                    "type": "string",  
                                    "description": "Type of geometry (Point, Polygon, etc.)",  
                                    "enum": \["Polygon", "Point"\]  
                                },  
                                "coordinates": {  
                                    "description": "Coordinates of the geometry",  
                                    "oneOf": \[  
                                        {  
                                            "type": "array",  
                                            "description": "Point coordinates: \[longitude, latitude\]",  
                                            "items": {"type": "number"},  
                                            "minItems": 2,  
                                            "maxItems": 2  
                                        },  
                                        {  
                                            "type": "array",  
                                            "description": "Polygon coordinates: array of linear rings",  
                                            "items": {  
                                                "type": "array",  
                                                "items": {  
                                                    "type": "array",  
                                                    "items": {"type": "number"},  
                                                    "minItems": 2,  
                                                    "maxItems": 2  
                                                },  
                                                "minItems": 4  
                                            },  
                                            "minItems": 1  
                                        }  
                                    \]  
                                }  
                            },  
                            "required": \["type", "coordinates"\]  
                        }  
                    },  
                    "required": \["type", "properties", "geometry"\]  
                }  
            }  
        },  
        "required": \["type", "features"\]  
    }
    ```

This GeoJSON schema defines the structure for geospatial data related to agricultural commodity production, with a focus on:

- **Supply Chain Transparency**: Tracking producer information and contract details  
- **Environmental Compliance**: Monitoring deforestation and land use changes  
- R**isk Assessment**: Identifying compliance issues and regulatory violations  
- **Audit Trail**: Maintaining comprehensive audit and assessment records

### **Risk Indicators**

The schema tracks multiple compliance risk factors:

1. **Environmental Risks**  
   * Deforestation detection (remote sensing \+ audit)  
   * Protected area violations  
   * Indigenous land infringements  
2. **Compliance Risks**  
   * Legal provision violations  
   * Audit findings  
   * Certification status  
3. **Supply Chain Risks**  
   * Contract compliance  
   * Producer verification  
   * Regional risk assessments

## **Schema Structure**

```json
{
  "type": "FeatureCollection",
  "properties": {
    // Collection-level metadata
  },
  "features": [
    {
      "type": "Feature",
      "properties": {
        // Feature-specific attributes
      },
      "geometry": {
        // Spatial data (Point or Polygon)
      }
    }
  ]
}
```

### **Key Components**

* **FeatureCollection**: Root container for multiple geographic features  
* **Properties**: Collection-level metadata including producer information and contracts  
* **Features**: Array of individual geographic features with compliance data  
* **Geometry**: Spatial representation (Point or Polygon coordinates)

### **Basic Feature Collection**

```json
{
  "type": "FeatureCollection",
  "properties": {
    "ProducerCountry": "BR",
    "ProducerRegion": "Mato Grosso",
    "RegionalRiskNonCompliance": "Medium",
    "ReferencesRegionalRiskNonCompliance": "REF-2024-001",
    "Contracts": [
      {
        "SellerContractReference": "SC-001",
        "BuyerContractReference": "BC-001",
        "Container": "ABCU1234567",
        "Date": "2024-01-15",
        "Certifications": [
          {
            "Name": "RSPO",
            "ID": "RSPO-2024-001"
          }
        ]
      }
    ]
  },
  "features": [
    {
      "type": "Feature",
      "properties": {
        "ProducerName": "Fazenda Example",
        "ProductionPlace": "Municipality of Example",
        "Area": 1500.5,
        "DateMostRecentRemoteSensing": "2024-01-01",
        "RemoteSensingTools": "Sentinel-2, Planet Labs",
        "DeforestationDetectedRemoteSensing": false,
        "ComplianceIssuesFound": false
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-56.123, -15.456],
          [-56.124, -15.456],
          [-56.124, -15.457],
          [-56.123, -15.457],
          [-56.123, -15.456]
        ]]
      }
    }
  ]
}
```

### **Point Geometry Example**

```json
{
  "type": "Feature",
  "properties": {
    "ProductionPlace": "Sample Farm",
    "Area": 750.0
  },
  "geometry": {
    "type": "Point",
    "coordinates": [-56.123, -15.456]
  }
}
```

### **Geometry Types**

* **Point**: Single coordinate pair \[longitude, latitude\]  
* **Polygon**: Array of linear rings defining area boundaries