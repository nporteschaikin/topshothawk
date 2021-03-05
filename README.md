# topshothawk

Microservices for collecting transaction and moment data off the [NBA Top Shot](https://www.nbatopshot.com/) [Flow blockchain](https://www.onflow.org/). [@mjspector](https://github.com/mjspector) intends to use this data for... something.

## ToC

- *[consumer](/consumer):* Code for the following services:
  - *listener:* listens to new blocks and makes request to fetchers via Redis.
  - *fetcher:* invoked with a specific event type (e.g. `Market.MomentPurchased`); pops blocks off Redis and fetches events of the aforementioned type in the block, up to a certain height.
  - *recorder*: writes moments and events to Postgres.
- *[migrator](/migrator):* Rough Ruby app I wrote for maintaining the Postgres database schema. [Runs every five minutes](/infrastructure/modules/migrator/main.tf) in the cloud.
- *[infrastructure](/infrastructure):* [Terraform](https://www.terraform.io) configuration for spawning the aforementioned services in AWS using ECS, EC2, RDS, Elasticache, etc. in a private VPC; SSH accessible via a bastion.

## Installation

All services [are conveniently orchestrated with Docker](/docker-compose.yml). The only installation steps are to clone the repository and construct the database:

```
git clone git@github.com:nporteschaikin/topshothawk
cd topshothawk
docker-compose run --rm migrator load
```

## Usage

```
docker-compose up -d
```

## License

[MIT](LICENSE.md)
