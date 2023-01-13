# Changelog Notes

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# [PowerShellJMC](https://tools.jhacorp.com/powershelljmc "PowerShellJMC Installation Instructions")

-   [PowerShellJMC Support](https://eisportal.jhacorp.com/ToolsSupport/#/Request?id=10 "Request Support")

# Changelog
## [1.0.68] - 2023-01-09

### Fixed
- Add and Update-SGProvider -ProviderTypeName 4sight, use the correct types

## [1.0.67] - 2022-11-21

### Fixed
- Get-SGProvider -ProviderTypeName 4sight, returned all endpoint servername instead of full url

## [1.0.66] - 2022-11-17

### Removed
- Get-Input because it referenced windows forms and it causes import errors with PowerShell 7 compatibility.

## [1.0.65] - 2022-11-03

### Fixes

-   Recompiled to the newest version of jx2022.2

## [1.0.64] - 2022-05-20

### Updated

-   Makes all endpoints AbsoluteUri instead of Hostname

## [1.0.63] - 2022-04-19

### Fixes

-   Error The parameter 'CustomerIssuer' is declared in parmet multiple times.

## [1.0.62] - 2022-04-14

### Fixes

-   Duplicate providers

## [1.0.61] - 2022-04-05

### New

-   Add-EESubscription - Enterprise Event
-   Remove-EESubscription - Enterprise Event
-   Get-EESubscription - Enterprise Event
-   Add-EESubscriber - Enterprise Event
-   Remove-EESubscriber - Enterprise Event
-   Get-EESubscriber - Enterprise Event
-   Add-EEUser - Enterprise Event
-   Remove-EEUser - Enterprise Event
-   Get-EEUser - Enterprise Event
-   Update-EEInstitution - Enterprise Event
-   Remove-EEInstitution - Enterprise Event
-   Add-EEInstitution - Enterprise Event
-   Get-EEInstitution - Enterprise Event
-   Remove-PSUser - Persistent Storage
-   Get-PSUser - Persistent Storage
-   Remove-IMSUser - Identity Management System
-   Get-IMSUser - Identity Management System
-   Remove-ELUser - Enterprise Logging
-   Get-ELUser - Enterprise Logging
-   Remove-EAUser - Enterprise Audit
-   Get-EAUser - Enterprise Audit
-   Remove-BEUser - Broadcast Event
-   Get-BEUser - Broadcast Event

### Updated

-   Get-SGUser - Includes Operations and Operation Groups
-   Update-SGProvider - YellowHammer
-   Update-SGProvider - Vertex
-   Update-SGProvider - Synapsys
-   Update-SGProvider - PSCU CDE Translator
-   Update-SGProvider - PSCU Translator
-   Update-SGProvider - PSCU
-   Update-SGProvider - PPS
-   Update-SGProvider - Passport
-   Update-SGProvider - pAdapter Web Service
-   Update-SGProvider - ODI
-   Update-SGProvider - Jha Enterprise CRM
-   Update-SGProvider - iTalk
-   Update-SGProvider - International Wires
-   Update-SGProvider - FedLine Global
-   Update-SGProvider - Episys
-   Update-SGProvider - Enterprise Workflow
-   Update-SGProvider - Enterprise Logging
-   Update-SGProvider - EEMS
-   Update-SGProvider - Cspi
-   Update-SGProvider - Cps Rtp
-   Update-SGProvider - BSA
-   Update-SGProvider - Broadcast Event
-   Update-SGProvider - Argo
-   Update-SGProvider - AlertCenter

## [1.0.60] - 2022-04-01

### Updated

-   SGProviderSynergy - Handles Inquiry endpoint is null correctly
-   SGProviderJHAPayCenter - Adds Device Endpoint

### New

-   Update-SGInstitution
-   New-SGProviderBroadcastEvent
-   New-SGProviderOnBoardDeposit
-   New-SGProviderOnBoardLoad
-   New-SGProviderSymantecVip

## [1.0.59] - 2022-03-29

### Updated

-   Update-SgProvider - Supports NetTeller Provider
-   Update-SgProvider - Supports Symantec MFA Provider
-   SGProviderSynergy - Adds Inquiry endpoint

## [1.0.58] - 2021-09-20

### Updated

-   Update-SgProvider - Supports Core Director Provider
    Supports CIF2020 Provider
    Supports SilverLake Provider
    Supports Enterprise Notification Provider
-   Get-SgProvider - Enterprise Notification AllEndpoint & AllEndpointIssuer display the full url.

## [1.0.57] - 2021-08-26

### Fixed

-   Removed -IsMaster from Add-DLWSubscriber because we found out it is not set with a check box

## [1.0.56] - 2021-08-25

### Added

-   Update-SgProvider, only supports the 'Multi-Factor Authentication' provider in this version

## [1.0.55] - 2021-08-09

### Added

-   New-SGProviderJHAEnterCRM cmdlet
-   Remove-SGUser cmdlet
-   Get-PSStorageEntry cmdlet
-   Add-PSStorageEntry cmdlet
-   Remove-PSStorageEntry cmdlet
-   Update-PSStorageEntry cmdlet

### Changed

-   Get-SGProvider to return JHAEnterCRM info

## [1.0.54] - 2021-07-08

### Dependency

-   DLW 2021.0+

### Changed

-   cmdlet Add-DLWSubscriber, to allow for both broadcast event and service gateway username and password
-   cmdlet Add-DLWSubscriber, to allow for sts server setting

### Added

-   '-SgUsername' property to the Add-DLWSubscriber cmdlet
-   '-SgPassword' property to the Add-DLWSubscriber cmdlet
-   '-BeUsername' property to the Add-DLWSubscriber cmdlet
-   '-BePassword' property to the Add-DLWSubscriber cmdlet
-   '-StsServer' property to the Add-DLWSubscriber cmdlet
-   '-IsMaster' switch property to the Add-DLWSubscriber cmdlet, when the first subscriber is added, it defaults to true, otherwise you have to set it

### Removed

-   '-ServiceUsername' property to the Add-DLWSubscriber cmdlet
-   '-ServicePassword' property to the Add-DLWSubscriber cmdlet

## [1.0.53] - 2021-03-01

### Added

-   cmdlet Get-JMCFarmMember
-   cmdlet Get-JMCProduct
-   cmdlet Update-JMCFarm

### Fixed

-   cmdlet Get-JMCFarm to return only 1 thumbprint per farm
-   cmdlet Remove-JMCFarmMember because it wasn't deleting the farm member

## [1.0.52] - 2021-02-04

### Added

-   cmdlet Set-SGMessageResolution
-   cmdlet Get-SGMessageResolution

### Changed

-   Add-SGProvider so that it will default the message resolution to the previous provider when there is a conflict.
-   Add-SGProvider response to include a flag: HadMessageConflict
-   Add-SGProvider to throw warnings when the cmdlet is fixing the message resolution

## [1.0.51] - 2021-01-11

### Changed

-   New-SGProviderJHAPayCenter to accept new parms for payments
-   Add-SGProvider to accept New-SGProviderJHAPayCenter objects
-   Get-SGProvider to get New-SGProviderJHAPayCenter objects

## [1.0.50] - 2020-12-02

### Fixed

-   Get-SGProvider when getting old 4Sight provider with missing data

## [1.0.49] - 2020-12-01

### Added

-   New-SGProviderEnterpriseWorkflow

### Changed

-   Add-SGProvider to accept New-SGProviderEnterpriseWorkflow objects
-   ConvertTo-Splat to produce New-SGProviderEnterpriseWorkflow object
-   Get-SGProvider to get New-SGProviderEnterpriseWorkflow objects

## [1.0.48] - 2020-10-30

### Fixed

-   Recompiled/Republished - 1.0.47 didn't publish correctly

## [1.0.47] - 2020-10-30

### Fixed

-   Add-SGProvider to add the correct security context for New-SGProviderCPSRTP

# Changelog

## [1.0.46] - 2020-10-30

### Changed

-   New-SGProvider4Sight to include IMS endpoints
-   Add-SGProvider to accept added New-SGProvider4Sight parameters
-   Get-SGProvider to get New-SGProvider4Sight

## [1.0.45] - 2020-08-05

### Added

-   New-SGProviderPscuCdeTranslator

### Changed

-   Add-SGProvider to accept New-SGProviderPscuCdeTranslator objects
-   ConvertTo-Splat to produce New-SGProviderPscuCdeTranslator object
-   Get-SGProvider to get New-SGProviderPscuCdeTranslator objects

## [1.0.44] - 2020-06-02

### Changed

-   Get-SGProvider to get New-SGProviderMultiFactorAuth values

## [1.0.43] - 2020-04-30

### Added

-   New-SGProviderVertex

### Changed

-   Add-SGProvider to accept New-SGProviderVertex objects
-   ConvertTo-Splat to produce New-SGProviderVertex object
-   Get-SGProvider to get New-SGProviderVertex objects

## [1.0.42] - 2020-02-07

### Added

-   New-SGProviderJHAPayCenter

### Changed

-   Add-SGProvider to accept New-SGProviderJHAPayCenter objects
-   ConvertTo-Splat to produce New-SGProviderJHAPayCenter object
-   Get-SGProvider to get New-SGProviderJHAPayCenter objects

## [1.0.41] - 2020-02-07

### Added

-   support for PoshXP-2019.0

## [1.0.40] - 2020-01-13

### Fixed

-   Update-JMCFarmConfig to give better error output when one of the configs will not save

## [1.0.39] - 2020-01-10

### Fixed

-   Get-SGProvider to output the correct object types for ODI
-   Get-SGProvider to output not error on Synapsys when missing information from a previous metadata version

## [1.0.38] - 2020-01-01

### Added

-   Change log
-   New-SGProviderEEMS

### Changed

-   Get-SGProvider to support the EEMS Provider
-   ConvertTo-Splat to support the EEMS Provider
