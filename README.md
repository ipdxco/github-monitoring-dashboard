# tf-aws-gh-observer

This is the setup for GitHub Events data collection. It consists of a GitHub App with webhook events configured, AWS Lambda responsible for receiving GitHub events and AWS PostgreSQL RDS where the events are stored.

Currently, the GitHub App - https://github.com/apps/pl-strflt-tf-aws-gh-observability - is installed in "filecoin-shipyard", "ipfs", "ipfs-examples", "ipfs-shipyard", "ipld", "ipni", "libp2p", "multiformats", "pl-strflt", "plprobelab", "testground", "quic-go".

To start collecting events from other orgs
1. create a PR that adds the org to the list in https://github.com/pl-strflt/tf-aws-gh-observer/blob/main/main.tf#L48
1. install https://github.com/apps/pl-strflt-tf-aws-gh-observability for all the repositories in the org

Currently, we only collect GitHub Actions related events but there's nothing blocking us from expanding to other types of events.
