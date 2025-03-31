defmodule OracleEcto.Type do
  @int_types [:bigint, :integer, :id, :serial]
  @decimal_types [:numeric, :decimal]

  @json_library Application.compile_env(:oracle_ecto, :json_library, Jason)

  require Decimal

  def encode(value, :bigint) do
    {:ok, to_string(value)}
  end

  def encode(value, :binary_id) when is_binary(value) do
    Ecto.UUID.load(value)
  end

  def encode(value, :map) do
    @json_library.encode(value)
  end

  def encode(value, :decimal) do
    try do
      value
      |> Decimal.to_integer
      |> decode(:integer)
    rescue
      _e in FunctionClauseError ->
        {:ok, value}
    end
  end

  def encode(value, _type) do
    {:ok, value}
  end

  def decode(value, type)
  when type in @int_types and is_binary(value) do
    case Integer.parse(value) do
      {int, _}  -> {:ok, int}
      :error    -> {:error, "Not an integer id"}
    end
  end

  def decode(value, type)
  when type in [:float] do
    cond do
      Decimal.is_decimal(value) -> {:ok, Decimal.to_float(value)}
      true                    -> {:ok, value}
    end
  end

  def decode(value, type)
  when type in @decimal_types and is_binary(value) do
    Decimal.parse(value)
  end

  def decode(nil, _type) do
    {:ok, nil}
  end

  def decode(value, :map) do
    @json_library.decode(value)
  end

  def decode(value, :uuid) do
    Ecto.UUID.dump(value)
  end

  def decode(%NaiveDateTime{} = date_time, type) when type in [:utc_datetime, :naive_datetime] do
    {:ok, date_time}
  end

  def decode(%NaiveDateTime{} = date_time, type) when type in [:date] do
    date = date_time |> NaiveDateTime.to_date()
    {:ok, date}
  end

  def decode(value, _type) do
    {:ok, value}
  end

end
