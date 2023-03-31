# Azure Container Instances Terraform module

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![Equinor Terraform Baseline](https://img.shields.io/badge/Equinor%20Terraform%20Baseline-1.0.0-blueviolet)](https://github.com/equinor/terraform-baseline)

Terraform module which creates Azure Container Instances resources.

## WARNING

This module uses variables of type `list(object)` or `map(object)` to dynamically create Terraform blocks based on the input value.

Terraform currently doesn't support using the `sensitive()` function as a type constructor, thus it's not possible to create objects with sensitive properties ([hashicorp/terraform#32414](https://github.com/hashicorp/terraform/issues/32414)).

The following object properties should be sensitive:

- `containers[*].secure_environment_variables`
- `containers[*].volumes[*].secret`
- `containers[*].volumes[*].storage_account_key`
- `image_registry_credentials[*].password`

As a result, the values of these properties could be exposed if used as the value of a non-sensitive resource argument inside this module.

**Use these properties at your own risk!**

An option could be to use the `sensitive()` function to force the values of these properties to be sensitive before passing them to this module.
