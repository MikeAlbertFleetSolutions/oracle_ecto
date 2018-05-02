Logger.configure(level: :info)
ExUnit.start exclude: [
                        :strict_savepoint,
                        :transaction_isolation,
                        :array_type,
                        :rename_table,
                        :rename_column,
                        :modify_foreign_key_on_update,
                        :alter_primary_key,
                        :modify_foreign_key_on_delete,
                        :modify_column,
                        :remove_column,
                        :map_type,
                        :decimal_type,
                        :unique_constraint,
                        :returning,
                        :upsert,
                        :upsert_all,
                        :id_type,
                        :foreign_key_constraint,
                        :uses_usec,
                        :read_after_writes,
                        :delete_with_join,
                        :update_with_join,
                        :prefix
                      ]

# Configure Ecto for support and tests
Application.put_env(:ecto, :primary_key_type, :id)
Application.put_env(:ecto, :lock_for_update, "FOR UPDATE")

# Load support files
Code.require_file "./support/repo.exs", __DIR__
Code.require_file "./support/schemas.exs", __DIR__
Code.require_file "./support/migration.exs", __DIR__

pool =
  case System.get_env("ECTO_POOL") || "poolboy" do
    "poolboy" -> DBConnection.Poolboy
    "sbroker" -> DBConnection.Sojourn
  end

# Basic test repo
alias Ecto.Integration.TestRepo

Application.put_env(:ecto, TestRepo,
  adapter: OracleEcto,
  dsn: "OracleODBC-12c",
  service: "db",
  username: "web_ca",
  password: "bitsandbobs",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_pool: pool)

defmodule Ecto.Integration.TestRepo do
  use Ecto.Integration.Repo, otp_app: :ecto
end

# Pool repo for transaction and lock tests
alias Ecto.Integration.PoolRepo

Application.put_env(:ecto, PoolRepo,
  adapter: OracleEcto,
  dsn: "OracleODBC-12c",
  service: "db",
  username: "web_ca",
  password: "bitsandbobs",
  pool_size: 10,
  max_restarts: 20,
  max_seconds: 10)

defmodule Ecto.Integration.PoolRepo do
  use Ecto.Integration.Repo, otp_app: :ecto

  def create_prefix(prefix) do
   "create user #{prefix} identified by #{prefix}"
  end

  def drop_prefix(prefix) do
   "drop user #{prefix} cascade"
  end
end

defmodule Ecto.Integration.Case do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
  end
end

{:ok, _} = OracleEcto.ensure_all_started(TestRepo, :temporary)

# load up the repository, start it
_   = OracleEcto.storage_down(TestRepo.config())
:ok = OracleEcto.storage_up(TestRepo.config())

{:ok, _pid} = TestRepo.start_link
{:ok, _pid} = PoolRepo.start_link

# since oracle doesn't support transactions in DDL, wipe out all tables in the db between runs
TestRepo.query!("
  BEGIN
    FOR c IN (SELECT table_name FROM user_tables)
    LOOP
      EXECUTE IMMEDIATE ('drop table ' || c.table_name || ' cascade constraints');
    END LOOP;
  END;
")

# run migrations
:ok = Ecto.Migrator.up(TestRepo, 0, Ecto.Integration.Migration, log: false)
Ecto.Adapters.SQL.Sandbox.mode(TestRepo, :manual)
Process.flag(:trap_exit, true)
