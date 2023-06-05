<div align="center">

![observability-banner](https://github.com/pl-strflt/tf-aws-gh-observer/assets/6688074/77b35ed7-63dd-49a5-b549-51b46f1d3a6b)

  
# tf-aws-gh-observer: Holistic Monitoring for GitHub Actions

A comprehensive solution for monitoring GitHub Actions that bridges data collection through AWS infrastructure with intuitive data presentation using Grafana.
  
</div>

## Overview

Our setup for GitHub Events data collection includes a GitHub App with configured webhook events, an AWS Lambda function for receiving GitHub events, and an AWS PostgreSQL RDS database for storing these events.

Currently, our GitHub App - [pl-strflt-tf-aws-gh-observability](https://github.com/apps/pl-strflt-tf-aws-gh-observability) - is installed across a wide range of organizations, including:
- `filecoin-shipyard`
- `ipfs`
- `ipfs-examples`
- `ipfs-shipyard`
- `ipld`
- `ipni`
- `libp2p`
- `multiformats`
- `pl-strflt`
- `plprobelab`
- `testground`
- `quic-go`

## Getting Started

### Monitoring Additional Organizations

To start gathering events from other organizations:

1. Initiate a PR that incorporates the new organization to the list in [main.tf#L48](https://github.com/pl-strflt/tf-aws-gh-observer/blob/main/main.tf#L48).
2. Install the [pl-strflt-tf-aws-gh-observability](https://github.com/apps/pl-strflt-tf-aws-gh-observability) app for all the repositories within the organization.

Currently, our focus is on collecting GitHub Actions-related events. However, our infrastructure is flexible and ready for expansion to include other types of events.

## Visualizing Your Data

For a high-level view of your GitHub Actions, consult our Grafana dashboard. The configuration for the dashboard is stored in the [JSON configuration file](GitHub Actions-1685974370939.json). The image below provides a glimpse into the kind of insights available with our setup.

![protocollabs grafana net_d_a11c5e9e-b6f0-44b4-9b54-10f4207d110e_github-actions_orgId=1 (8)](https://github.com/pl-strflt/tf-aws-gh-observer/assets/6688074/bd59095d-3887-4545-8f5f-9a943c2aa51c)
