# Overview

This is a template for Golang that has simple "Hello world" code and should be used to templatize best practices for applications on the platform. Templates like this help application teams adopt best practices from the very first commit. This templates is used in the Application Factory when a Golang application is created, the code for the application will be copied from this template repo to the source code repo of the new application.

## Table of Contents

- [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Critical Files](#critical-files)
  - [Licensing](#licensing)
  - [Usage](#usage)
  - [Contributing](#contributing)

## Critical Files

The following is a list of critical files utilized in the conventions for building
an containerized application.

| File/Folder        | Description                                                                                                                                               |  Required
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- | -----------
| Dockerfile :whale: | File used to create the Docker image                                                                                                                      | :white_check_mark:
| skaffold.yaml      | Used in local development to keep development environment in sync with changes. If not using skaffold, this file is optional (but recommended)            | :white_large_square:
| cloudbuild.yaml    | CI/CD Pipeline setup to build to the application                                                                                                          | :white_check_mark:
| k8s/               | Folder containing the Kubernetes resource manifests for "dev", "stage" and "prod". Resource files are configured to use Kustomize during the CI/CD build. | :white_check_mark:

## Usage

Copyright 2022 Google. This software is shared as sample code and not intended
for production use and provided as-is, without warranty or representation for
any use or purpose. Your use of it is discretionary and subject to your
agreement with Google.

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

