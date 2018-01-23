defmodule OracleEcto.DeleteTest do
  use ExUnit.Case, async: true

  alias OracleEcto.Connection, as: SQL

  test "delete" do
    query = SQL.delete(nil, "schema", [:x, :y], [])
    assert query == ~s{DELETE FROM "schema" WHERE "x" = ?1 AND "y" = ?2}

    query = SQL.delete(nil, "schema", [:x, :y], [:z])
    assert query == ~s{DELETE FROM "schema" OUTPUT DELETED."z" WHERE "x" = ?1 AND "y" = ?2}

    query = SQL.delete("prefix", "schema", [:x, :y], [])
    assert query == ~s{DELETE FROM "prefix"."schema" WHERE "x" = ?1 AND "y" = ?2}
  end
end
