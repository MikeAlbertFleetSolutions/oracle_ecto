defmodule OracleEcto do
  @moduledoc false
  @behaviour Ecto.Adapter.Storage

  use Ecto.Adapters.SQL, driver: :oracleex, migration_lock: "FOR UPDATE"

  alias OracleEcto.Migration
  alias OracleEcto.Storage
  alias OracleEcto.Structure

  import OracleEcto.Type, only: [encode: 2, decode: 2]

  def autogenerate(:binary_id),       do: Ecto.UUID.generate()
  def autogenerate(type),             do: super(type)

  def dumpers({:embed, _} = type, _), do: [&Ecto.Adapters.SQL.dump_embed(type, &1)]
  def dumpers(:binary_id, _type),     do: []
  def dumpers(:uuid, _type),          do: []
  def dumpers(ecto_type, type),       do: [type, &(encode(&1, ecto_type))]

  def loaders({:embed, _} = type, _), do: [&Ecto.Adapters.SQL.load_embed(type, &1)]
  def loaders(ecto_type, type),       do: [&(decode(&1, ecto_type)), type]

  ## Migration
  @impl true
  def supports_ddl_transaction?, do: Migration.supports_ddl_transaction?

  @impl true
  def lock_for_migrations(_meta, _opts, fun) do
    #%{opts: adapter_opts, repo: repo} = meta

    #if Keyword.fetch(adapter_opts, :pool_size) == {:ok, 1} do
    #  Ecto.Adapters.SQL.raise_migration_pool_size_error()
    #end

    #opts = Keyword.merge(opts, [timeout: :infinity, telemetry_options: [schema_migration: true]])

    #{:ok, result} =
      #transaction(fn ->
        #try do
          # I'm not sure we will have need to lock for migrations; if we do we should figure out how to execute this stuff against oracle
          #dbms_lock.allocate_unique('control_lock', v_lockhandle);
          #v_result := dbms_lock.request(v_lockhandle, dbms_lock.ss_mode);
          fun.()
        #after
          #v_result := dbms_lock.release(v_lockhandle);
        #end
      #end)

    #result
  end


  ## Storage
  @impl true
  def storage_up(opts), do: Storage.storage_up(opts)
  @impl true
  def storage_down(opts), do: Storage.storage_down(opts)
  @impl true
  def storage_status(opts), do: Storage.storage_status(opts)

  ## Structure
  def structure_dump(default, config), do: Structure.structure_dump(default, config)
  def structure_load(default, config), do: Structure.structure_load(default, config)
end
