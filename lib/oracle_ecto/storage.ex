defmodule OracleEcto.Storage do

  @behaviour Ecto.Adapter.Storage

  @impl true
  def storage_up(_opts) do
    # database = Keyword.fetch!(opts, :database) || raise ":database is nil in repository configuration"
    # opts     = Keyword.put(opts, :database, nil)
    #
    # command =
    #   ~s[CREATE USER "#{database}" IDENTIFIED BY "#{database}"]
    #
    # case run_query(command, opts) do
    #   {:ok, _} ->
    #     :ok
    #   {:error, %{odbc_code: :database_already_exists}} ->
    #     {:error, :already_up}
    #   {:error, error} ->
    #     {:error, Exception.message(error)}
    # end
    :ok
  end

  @impl true
  def storage_down(_opts) do
    # database = Keyword.fetch!(opts, :database) || raise ":database is nil in repository configuration"
    # command  = ~s[DROP USER "#{database}" CASCADE]
    # opts     = Keyword.put(opts, :database, nil)
    #
    # case run_query(command, opts) do
    #   {:ok, _} ->
    #     :ok
    #   {:error, %{odbc_code: :base_table_or_view_not_found}} ->
    #     {:error, :already_down}
    #   {:error, error} ->
    #     {:error, Exception.message(error)}
    # end
    :ok
  end

end
