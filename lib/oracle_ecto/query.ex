defmodule OracleEcto.Query do

  alias OracleEcto.QueryString

  import OracleEcto.Helpers

  @doc """
  Receives a query and must return a SELECT query.
  """
  @spec all(query :: Ecto.Query.t) :: String.t
  def all(query) do
    sources = QueryString.create_names(query)
    {select_distinct, order_by_distinct} = QueryString.distinct(query.distinct, sources, query)

    from     = QueryString.from(query, sources)
    select   = QueryString.select(query, select_distinct, sources)
    join     = QueryString.join(query, sources)
    where    = QueryString.where(query, sources)
    group_by = QueryString.group_by(query, sources)
    having   = QueryString.having(query, sources)
    order_by = QueryString.order_by(query, order_by_distinct, sources)
    top      = QueryString.top(query, sources)
    offset   = QueryString.offset(query, sources)
    lock     = QueryString.lock(query.lock)

    IO.iodata_to_binary([select, from, join, where, group_by, having, order_by, top, offset | lock])
  end

  @doc """
  Receives a query and values to update and must return an UPDATE query.
  """
  @spec update_all(query :: Ecto.Query.t) :: String.t
  def update_all(%{from: from} = query, prefix \\ nil) do
    sources = QueryString.create_names(query)
    {from, name} = get_source(query, sources, 0, from)

    prefix = prefix || ["UPDATE ", from, " ", name | " SET "]
    fields = QueryString.update_fields(query, sources)
    join = QueryString.join(query, sources)
    where = QueryString.where(query, sources)

    IO.iodata_to_binary([prefix, fields, join, where])
  end

  @doc """
  Receives a query and must return a DELETE query.
  """
  @spec delete_all(query :: Ecto.Query.t) :: String.t
  def delete_all(%{from: from} = query) do
    sources = QueryString.create_names(query)
    {from, name} = get_source(query, sources, 0, from)

    join = QueryString.join(query, sources)
    where = QueryString.where(query, sources)

    IO.iodata_to_binary(["DELETE ", " FROM ", from, " ", name, join, where])
  end

  @doc """
  Returns an INSERT for the given `rows` in `table`
  """
  @spec insert(prefix ::String.t, table :: String.t,
                   header :: [atom], rows :: [[atom | nil]],
                   on_conflict :: Ecto.Adapter.on_conflict, returning :: [atom]) :: String.t
  def insert(prefix, table, header, rows, on_conflict, returning) do
    included_fields = header
    |> Enum.filter(fn value -> Enum.any?(rows, fn row -> value in row end) end)

    if included_fields === [] do
      error!(nil, "Must include fields for insert")
    else
      included_rows =
        Enum.map(rows, fn row ->
          row
          |> Enum.zip(header)
          |> Enum.filter_map(
          fn {_row, col} -> col in included_fields end,
          fn {row, _col} -> row end)
      end)

      fields = intersperse_map(included_fields, ?,, &quote_name/1)
      IO.iodata_to_binary(["INSERT INTO ", quote_table(prefix, table),
                           " (", fields, ")",
                           " VALUES ",
                           insert_all(included_rows, 1),
                           on_conflict(on_conflict, included_fields)])
    end
  end

  defp on_conflict({:raise, _, []}, _header) do
    []
  end
  defp on_conflict(_, _header) do
    error!(nil, ":on_conflict options other than :raise are not yet supported")
  end

  defp insert_all(rows, counter) do
    intersperse_reduce(rows, ?,, counter, fn row, counter ->
      {row, counter} = insert_each(row, counter)
      {[?(, row, ?)], counter}
    end)
    |> elem(0)
  end

  defp insert_each(values, counter) do
    intersperse_reduce(values, ?,, counter, fn
      nil, counter ->
        {"DEFAULT", counter}
      _, counter ->
        {[?? | Integer.to_string(counter)], counter + 1}
    end)
  end

  @doc """
  Returns an UPDATE for the given `fields` in `table` filtered by
  `filters` returning the given `returning`.
  """
  @spec update(prefix :: String.t, table :: String.t, fields :: [atom],
                   filters :: [atom], returning :: [atom]) :: String.t
  def update(prefix, table, fields, filters, _returning) do
    {fields, count} = intersperse_reduce(fields, ", ", 1, fn field, acc ->
      {[quote_name(field), " = ?" | Integer.to_string(acc)], acc + 1}
    end)

    {filters, _count} = intersperse_reduce(filters, " AND ", count, fn field, acc ->
      {[quote_name(field), " = ?" | Integer.to_string(acc)], acc + 1}
    end)

  IO.iodata_to_binary(["UPDATE ", quote_table(prefix, table), " SET ",
                       fields, " WHERE ", filters ,])
  end

  @doc """
  Returns a DELETE for the `filters` returning the given `returning`.
  """
  @spec delete(prefix :: String.t, table :: String.t,
                   filters :: [atom], returning :: [atom]) :: String.t
  def delete(prefix, table, filters, _returning) do
    {filters, _} = intersperse_reduce(filters, " AND ", 1, fn field, acc ->
      {[quote_name(field), " = ?" , Integer.to_string(acc)], acc + 1}
    end)

    IO.iodata_to_binary(["DELETE FROM ", quote_table(prefix, table), " WHERE ", filters])
  end
end
