# Changelog

## [2.0.0](https://github.com/CloudNationHQ/terraform-azure-lb/compare/v1.5.0...v2.0.0) (2025-05-08)


### ⚠ BREAKING CHANGES

* The data structure changed, causing a recreate on existing resources.

### Features

* small refactor ([#24](https://github.com/CloudNationHQ/terraform-azure-lb/issues/24)) ([895ca86](https://github.com/CloudNationHQ/terraform-azure-lb/commit/895ca869d8c8d3bbb30651225243c32bab4d030b))

## [1.5.0](https://github.com/CloudNationHQ/terraform-azure-lb/compare/v1.4.1...v1.5.0) (2025-05-08)


### Features

* **deps:** bump golang.org/x/net from 0.36.0 to 0.38.0 in /tests ([#23](https://github.com/CloudNationHQ/terraform-azure-lb/issues/23)) ([a861042](https://github.com/CloudNationHQ/terraform-azure-lb/commit/a86104252935593e591997c3e3f548b68babfd30))

## [1.4.1](https://github.com/CloudNationHQ/terraform-azure-lb/compare/v1.4.0...v1.4.1) (2025-04-14)


### Bug Fixes

* fix submodule generation from makefile ([#21](https://github.com/CloudNationHQ/terraform-azure-lb/issues/21)) ([be20946](https://github.com/CloudNationHQ/terraform-azure-lb/commit/be2094682b1a5e0290dfe65fd59a0eb1933207ad))

## [1.4.0](https://github.com/CloudNationHQ/terraform-azure-lb/compare/v1.3.0...v1.4.0) (2025-03-20)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#17](https://github.com/CloudNationHQ/terraform-azure-lb/issues/17)) ([a6a0d04](https://github.com/CloudNationHQ/terraform-azure-lb/commit/a6a0d041153df210564e5cf2914e18d4585452c0))
* **deps:** bump golang.org/x/net from 0.33.0 to 0.36.0 in /tests ([#18](https://github.com/CloudNationHQ/terraform-azure-lb/issues/18)) ([d137c81](https://github.com/CloudNationHQ/terraform-azure-lb/commit/d137c810f138fe61ae4fd0a01218932d2a8ebd7e))
* format documentation to include type definitions ([#19](https://github.com/CloudNationHQ/terraform-azure-lb/issues/19)) ([9164c91](https://github.com/CloudNationHQ/terraform-azure-lb/commit/9164c91b1c500957b5ccbb43f6671bfb6fc2086e))

## [1.3.0](https://github.com/CloudNationHQ/terraform-azure-lb/compare/v1.2.1...v1.3.0) (2025-01-15)


### Features

* added functionality in nat pools, rules, loadbalancer probes and remove temporary files when deployment tests fails ([#12](https://github.com/CloudNationHQ/terraform-azure-lb/issues/12)) ([3f1b8a6](https://github.com/CloudNationHQ/terraform-azure-lb/commit/3f1b8a64291209225e7aa094c356115d3eb90f69))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#11](https://github.com/CloudNationHQ/terraform-azure-lb/issues/11)) ([30ab62f](https://github.com/CloudNationHQ/terraform-azure-lb/commit/30ab62f099d2f65cf4d440f30d35480315952bac))
* **deps:** bump golang.org/x/crypto from 0.29.0 to 0.31.0 in /tests ([#15](https://github.com/CloudNationHQ/terraform-azure-lb/issues/15)) ([2e12c5c](https://github.com/CloudNationHQ/terraform-azure-lb/commit/2e12c5cfff5afc7b2481f192f58f80cf14beb48b))
* **deps:** bump golang.org/x/net from 0.31.0 to 0.33.0 in /tests ([#16](https://github.com/CloudNationHQ/terraform-azure-lb/issues/16)) ([5e1b6d3](https://github.com/CloudNationHQ/terraform-azure-lb/commit/5e1b6d3d117bddff37401a2eacf98331fc7fb346))

## [1.2.1](https://github.com/CloudNationHQ/terraform-azure-lb/compare/v1.2.0...v1.2.1) (2024-11-20)


### Bug Fixes

* bounced all modules to latest verion in usages ([#8](https://github.com/CloudNationHQ/terraform-azure-lb/issues/8)) ([5cd2956](https://github.com/CloudNationHQ/terraform-azure-lb/commit/5cd2956f316ac2a2f6ca2fa662944b1bd495041c))

## [1.2.0](https://github.com/CloudNationHQ/terraform-azure-lb/compare/v1.1.0...v1.2.0) (2024-11-11)


### Features

* enhance testing with sequential, parallel modes and flags for exceptions and skip-destroy ([#6](https://github.com/CloudNationHQ/terraform-azure-lb/issues/6)) ([11b0c5e](https://github.com/CloudNationHQ/terraform-azure-lb/commit/11b0c5ea0efad1e952ae126e69cf82094443049c))

## [1.1.0](https://github.com/CloudNationHQ/terraform-azure-lb/compare/v1.0.0...v1.1.0) (2024-10-11)


### Features

* auto generated docs and refine makefile ([#4](https://github.com/CloudNationHQ/terraform-azure-lb/issues/4)) ([39ccc79](https://github.com/CloudNationHQ/terraform-azure-lb/commit/39ccc793e6e24f8344ed08f91bef60c843e5c3c8))

## 1.0.0 (2024-10-09)


### Features

* add initial resources ([#2](https://github.com/CloudNationHQ/terraform-azure-lb/issues/2)) ([7e28915](https://github.com/CloudNationHQ/terraform-azure-lb/commit/7e28915dba90a0af36b5873f1ca25d6e2e8e7cc6))
