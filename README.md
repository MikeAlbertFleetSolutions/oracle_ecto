# OracleEcto

[Ecto](https://github.com/elixir-ecto/ecto) Adapter for [Oracleex](https://github.com/MikeAlbertFleetSolutions/oracleex)

Based on [findmypast-oss/mssql_ecto](https://github.com/findmypast-oss/mssql_ecto)

## Installation

### Erlang ODBC Application

OracleEcto requires the [Erlang ODBC application](http://erlang.org/doc/man/odbc.html) to be installed.
This might require the installation of an additional package depending on how you have installed Elixir/Erlang (e.g. on Ubuntu `sudo apt-get install erlang-odbc`).

### Oracle's ODBC Driver

OracleEcto depends on Oracle's ODBC Driver.  See the Dockerfile for how to install.

## Testing

Tests require an instance of Oracle to be running on `localhost` and the appropriate environment
variables to be set.  See the docker-compose file for details

### To start the database:

```bash
docker-compose start db
```

### To open a shell at the app root:

```bash
docker-compose run oracle_ecto
```

### To run the unit tests:

```bash
mix deps.get
mix test
```
