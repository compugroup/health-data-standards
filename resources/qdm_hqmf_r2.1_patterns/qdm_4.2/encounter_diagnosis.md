Encounter Diagnosis ([QDM-106](http://jira.oncprojectracking.org/browse/QDM-106)\)
==================================================================================

**NOTE: This pattern should be considered DRAFT, as it is still awaiting confirmation for correctness.**

The QDM User Group has proposed that encounter diagnoses (including principal diagnoses) be represented by `diagnosis` and `principal diagnosis` attributes on the `Encounter, Performed` data type.

The following attributes will be added to the `Laboratory Test, Performed` data type:

-	`diagnosis`: a coded diagnosis/problem addressed during the encounter
-	`principal diagnosis`: the coded diagnosis/problem established after study to be chiefly responsible for occasioning the admission of the patient to the hospital for care

General Approach
----------------

The approach follows the basic pattern that is already established in the QRDA Cat 1 DSTU R3 specification. The `Encounter, Performed` template will be updated to include an outboundRelationship to a new `Encounter Diagnosis` template. The `Encounter Diagnosis` template will, in turn, refer to the relevant `Diagnosis` template via a `criteriaReference`. The `Diagnosis` referred to by the `criteriaReference` should be in the `Data Criteria` section in order to ensure it is included in the data requirements.

One advantage of this approach is that it can support future QDM updates that might allow authors to link encounter elements directly to diagnosis elements.

Additional Encounter, Performed Constraints
-------------------------------------------

encounterCriteria (identifier: urn:hl7ii:2.16.840.1.113883.10.20.28.3.5:TBD)

| XPath                | Card. | Verb  | Data Type | Value                                                        | QDM Attribute                  |
|:---------------------|:------|:------|:----------|:-------------------------------------------------------------|:-------------------------------|
| outboundRelationship | 0..1  | MAY   |           |                                                              |                                |
| &nbsp; @typeCode     | 1..1  | SHALL |           | 2.16.840.1.113883.5.1002 (HL7ActRelationshipType) = REFR     |                                |
| &nbsp; actCriteria   | 1..1  | SHALL |           | Encounter Diagnosis (identifier: urn:hl7ii:TBD:TBD           | principal diagnosis            |
| outboundRelationship | 0..1  | MAY   |           |                                                              |                                |
| &nbsp; @typeCode     | 1..1  | SHALL |           | 2.16.840.1.113883.5.1002 (HL7ActRelationshipType) = REFR     |                                |
| &nbsp; actCriteria   | 1..1  | SHALL |           | Encounter Principal Diagnosis (identifier: urn:hl7ii:TBD:TBD | diagnosis, principal diagnosis |

Encounter Diagnosis Contexts
----------------------------

| Contained By                    | Contains  |
|:--------------------------------|:----------|
| Encounter, Performed (optional) | Diagnosis |

Encounter Diagnosis Constraints Overview
----------------------------------------

Note that the `code/@code` has *two* possible values. If this constraint is not possible, then two templates will be needed (`Encounter Diagnosis` and `Encounter Principal Diagnosis`).

actCriteria (identifier: urn:hl7ii:TBD:TBD)

| XPath                    | Card. | Verb  | Data Type | Value                                                    | QDM Attribute                  |
|:-------------------------|:------|:------|:----------|:---------------------------------------------------------|:-------------------------------|
| @classCode               | 1..1  | SHALL |           | ACT                                                      |                                |
| @moodCode                | 1..1  | SHALL |           | 2.16.840.1.113883.5.1001 (ActMood) = EVN                 |                                |
| templateId               | 1..1  | SHALL |           |                                                          |                                |
| &nbsp; item              | 1..1  | SHALL |           |                                                          |                                |
| &nbsp;&nbsp; @root       | 1..1  | SHALL |           | TBD                                                      |                                |
| &nbsp;&nbsp; @extension  | 1..1  | SHALL |           | TBD                                                      |                                |
| id                       | 1..1  | SHALL |           |                                                          |                                |
| code                     | 1..1  | SHALL |           |                                                          |                                |
| &nbsp; @code             | 1..1  | SHALL |           | 29308-4 (diagnosis) or 52534-5 (principal diagnosis)     |                                |
| &nbsp; @codeSystem       | 1..1  | SHALL |           | 2.16.840.1.113883.6.1 (LOINC)                            |                                |
| title                    | 1..1  | SHALL |           |                                                          |                                |
| outboundRelationship     | 1..1  | MAY   |           |                                                          |                                |
| &nbsp; @typeCode         | 1..1  | SHALL |           | 2.16.840.1.113883.5.1002 (HL7ActRelationshipType) = SUBJ |                                |
| &nbsp; criteriaReference | 1..1  | SHALL |           | *reference to* Diagnosis (identifier: urn:hl7ii:TBD:TBD) | diagnosis, principal diagnosis |

Encounter, Performed w/ Principal Diagnosis Example
---------------------------------------------------

```
<encounterCriteria classCode="ENC" moodCode="EVN">
    <templateId>
        <item root="2.16.840.1.113883.10.20.28.3.5" extension="TBD"/>
    </templateId>
    <id root="d7fbe089-ff04-4f58-b604-cb6d5ebce4cc"/>
    <code valueSet="{$QDMElementValueSetOID}"/>
    <title value="Encounter, Performed"/>
    <statusCode code="completed"/>
    <outboundRelationship typeCode="REFR">
        <actCriteria classCode="ACT" moodCode="EVN">
            <templateId>
                <item root="TBD" extension="TBD"/>
            </templateId>
            <id root="9f751ae5-edb2-4fb3-b49c-d0f0fdef3999"/>
            <code code="52534-5" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC">
                <displayName value="Principal Diagnosis"/>
            </code>
            <title value="Encounter Principal Diagnosis"/>
            <outboundRelationship typeCode="SUBJ">
                <criteriaReference classCode="OBS" moodCode="EVN">
                    <id root="${PrincipalDxIdRoot}" extension="${PrincipalDxIdExt}"/>
                </criteriaReference>
            </outboundRelationship>
        </actCriteria>
    </outboundRelationship>
</encounterCriteria>
```