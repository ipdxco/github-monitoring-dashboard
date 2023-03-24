# tf-aws-gh-observer

This is the setup for GitHub Events data collection. It consists of a GitHub App with webhook events configured, AWS Lambda responsible for receiving GitHub events and AWS PostgreSQL RDS where the events are stored.

Currently, the GitHub App - https://github.com/apps/pl-strflt-tf-aws-gh-observability - is installed in:
- [testground](http://github.com/testground) 
- [pl-strflt](http://github.com/pl-strflt)
- [ipfs](http://github.com/ipfs)
- [libp2p](http://github.com/libp2p)

To start collecting events from other orgs, the list in https://github.com/pl-strflt/tf-aws-gh-observer/blob/main/main.tf#L48 has to be updated and the changes have to be applied.

Currently, we only collect GitHub Actions related events but there's nothing blocking us from expanding to other types of events.
