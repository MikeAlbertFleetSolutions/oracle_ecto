# OracleEcto

[Ecto](https://github.com/elixir-ecto/ecto) Adapter for [Oracleex](https://github.com/MikeAlbertFleetSolutions/oracleex)

Based on [findmypast-oss/mssql_ecto](https://github.com/findmypast-oss/mssql_ecto)

## Installation

### Erlang ODBC Application

OracleEcto requires the [Erlang ODBC application](http://erlang.org/doc/man/odbc.html) to be installed.
This might require the installation of an additional package depending on how you have installed Elixir/Erlang (e.g. on Ubuntu `sudo apt-get install erlang-odbc`).

### Oracle's ODBC Driver

OracleEcto depends on Oracle's ODBC Driver.  See the Dockerfile for how to install.

### Application changes:

You need to add the following dependencies to your application:

```elixir
def deps do
  [
    {:oracle_ecto, github: "MikeAlbertFleetSolutions/oracle_ecto"},
    {:oracleex, github: "MikeAlbertFleetSolutions/oracleex"}
 ]
end
```

Be sure to run `mix deps.get`

### Configuration

Example configuration:

```elixir
config :my_app, MyApp.Repo,
  adapter: OracleEcto,
  dsn: "OracleODBC-12c",
  service: "db",
  username: "jeff",
  password: "password1"
```

## Testing

Tests require an instance of Oracle to be running on `localhost` and the appropriate environment
variables to be set.  See the docker-compose file for details

### To start the database:

```bash
docker-compose up db
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

## Testing against 19c

### To start the database:

```bash
docker-compose -f docker-compose.19c.yml up db
```

### To open a shell at the app root:

```bash
docker-compose -f docker-compose.19c.yml run oracle_ecto
```

### To run the unit tests:

```bash
mix deps.get
mix test
```

## Notes

* I started down this project because we have a very large existing Oracle database that our apps need to leverage.  I tried to implement so this would be reusable by others regardless of their situation but sometimes fell back to just making it work for our use case in order to save time.
* As of Oracle 12c, there is a concept of Identity Columns but no good 'Returning' functionality so the tests had to be changed to provide IDs.
* I struggle with Ecto's prefix for the schema_migration table so now I just assume no prefix.
* Oracle is case sensitive when you quote names so now I force everything to uppercase (back to point #1, that was the naming convention already in place).
