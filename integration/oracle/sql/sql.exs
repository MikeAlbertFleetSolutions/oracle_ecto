defmodule Ecto.Integration.SQLTest do
  use Ecto.Integration.Case, async: true
  @moduletag :integration

  alias Ecto.Integration.TestRepo
  alias Ecto.Integration.Barebone
  alias Ecto.Integration.Post
  import Ecto.Query, only: [from: 2]

  test "fragmented types" do
    datetime = ~N[2014-01-16 20:26:51]
    TestRepo.insert!(%Post{id: 1, inserted_at: datetime})
    query = from p in Post, where: fragment("? >= ?", p.inserted_at, ^datetime), select: p.inserted_at
    assert [^datetime] = TestRepo.all(query)
  end

  @tag :array_type
  test "fragment array types" do
    datetime1 = ~N[2014-01-16 00:00:00.0]
    datetime2 = ~N[2014-02-16 00:00:00.0]
    result = TestRepo.query!("SELECT $1::timestamp[]", [[datetime1, datetime2]])
    assert [[[{{2014, 1, 16}, _}, {{2014, 2, 16}, _}]]] = result.rows
  end

  test "query!/4" do
    result = TestRepo.query!("SELECT 1 FROM DUAL")
    assert result.rows == [[1]]
  end

  test "to_sql/3" do
    {sql, []} = Ecto.Adapters.SQL.to_sql(:all, TestRepo, Barebone)
    assert sql =~ "SELECT"
    assert sql =~ "BAREBONES"

    {sql, [0]} = Ecto.Adapters.SQL.to_sql(:update_all, TestRepo,
                                          from(b in Barebone, update: [set: [num: ^0]]))
    assert sql =~ "UPDATE"
    assert sql =~ "BAREBONES"
    assert sql =~ "SET"

    {sql, []} = Ecto.Adapters.SQL.to_sql(:delete_all, TestRepo, Barebone)
    assert sql =~ "DELETE"
    assert sql =~ "BAREBONES"
  end

  test "Repo.insert! escape" do
    TestRepo.insert!(%Post{id: 1, title: "'"})

    query = from(p in Post, select: p.title)
    assert ["'"] == TestRepo.all(query)
  end

  test "Repo.insert_all escape" do
    TestRepo.insert_all(Post, [%{id: 1, title: "'"}])

    query = from(p in Post, select: p.title)
    assert ["'"] == TestRepo.all(query)
  end
end
