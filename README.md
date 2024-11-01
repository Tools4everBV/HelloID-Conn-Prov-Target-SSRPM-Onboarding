# HelloID-Conn-Prov-Target-SSRPM-Onboarding

> [!IMPORTANT]
> This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.

<p align="center">
  <img src="">
</p>

## Table of contents

- [HelloID-Conn-Prov-Target-SSRPM-Onboarding](#helloid-conn-prov-target-connectorname)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Connection settings](#connection-settings)
    - [Correlation configuration](#correlation-configuration)
    - [Available lifecycle actions](#available-lifecycle-actions)
    - [Field mapping](#field-mapping)
  - [Remarks](#remarks)
  - [Development resources](#development-resources)
    - [API endpoints](#api-endpoints)
    - [API documentation](#api-documentation)
  - [Getting help](#getting-help)
  - [HelloID docs](#helloid-docs)

## Introduction

_HelloID-Conn-Prov-Target-SSRPM-Onboarding_ is a _target_ connector. _SSRPM-Onboarding_ provides a set of REST API's that allow you to programmatically interact with its data.  

It imports "Onboarding" information for the specific user into SSRPM.  This allows a user that wants to enroll in ssrpm, but does not know their AD account information, an alternative method of enrolling in ssrpm

## Getting started

### Prerequisites

An installed and configured ssrpm web site.
The OnboardingToken must be specified int the Web.config file of the SSSRPM website. This token kan be generated in the SSRPM Management console.


### Connection settings

The following settings are required to connect to the API.

| Setting  | Description                        | Mandatory |
| -------- | ---------------------------------- | --------- | 
| Token    | The onboarding API token to connect to the API | Yes       |
| BaseUrl  | The URL to the API                 | Yes       |

### Correlation configuration

The correlation configuration is used to specify which properties will be used to match an existing account within _SSRPM-Onboarding_ to a person in _HelloID_.
For this connector no correlation is done, because the interface does not support "get" operations, and the correlation settins are ignored. 

| Setting                   | Value                             |
| ------------------------- | --------------------------------- |
| Enable correlation        | `false`                           |
| Person correlation field  | `not applicable` |
| Account correlation field | `not applicable`                  |

> [!TIP]
> _For more information on correlation, please refer to our correlation [documentation](https://docs.helloid.com/en/provisioning/target-systems/powershell-v2-target-systems/correlation.html) pages_.

### Available lifecycle actions

The following lifecycle actions are available:

| Action                                  | Description                                     |
| --------------------------------------- | ----------------------------------------------- |
| create.ps1                              | Imports SSRPM onboarding information pertaining to an AD user Account. With this information the end user is later able to enroll in SSRPM by means of the onboarding method |


### Field mapping

The field mapping can be imported by using the _fieldMapping.json_ file.
These contains

## Remarks  

This connector does not have a genuine lifecycle, there is only a create script that imports onboarding information into SSRPM.  This connector only performs the "import" part of the onboarding process, which enables the end-user to complete the onboarding process by useing the SSRPM web site.

## Development resources

### API endpoints

The following endpoints are used by the connector:

| Endpoint | Description               |
| -------- | ------------------------- |
| /onboarding/import |  |

### API documentation

Detailed information about the complete onboarding process can be found in the chapter about Onboarding in the "/Admin Console/Documentation/Web Interface Guide.pdf" that comes with the SSRPM installation.

## Getting help

> [!TIP]
> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/en/provisioning/target-systems/powershell-v2-target-systems.html) pages_.

> [!TIP]
>  _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_.

## HelloID docs

The official HelloID documentation can be found at: https://docs.helloid.com/
