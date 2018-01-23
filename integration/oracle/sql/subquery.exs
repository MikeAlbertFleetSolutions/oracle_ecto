Code.require_file "../support/types.exs", __DIR__

defmodule Ecto.Integration.SubQueryTest do
  use Ecto.Integration.Case, async: true
  @moduletag :integration

  alias Ecto.Integration.TestRepo
  import Ecto.Query
  alias Ecto.Integration.Post
  alias Ecto.Integration.Comment

  test "from: subqueries with select source" do
    TestRepo.insert!(%Post{id: 1, text: "hello", public: 1})

    query = from p in Post, select: p
    assert ["hello"] =
           TestRepo.all(from p in subquery(query), select: p.text)
    assert [%Post{inserted_at: %NaiveDateTime{}}] =
           TestRepo.all(from p in subquery(query), select: p)
  end

  test "from: subqueries with select expression" do
    TestRepo.insert!(%Post{id: 1, text: "hello", public: 1})

    query = from p in Post, select: %{text: p.text, pub: p.public}
    assert ["hello"] =
           TestRepo.all(from p in subquery(query), select: p.text)
    assert [%{text: "hello", pub: 1}] =
           TestRepo.all(from p in subquery(query), select: p)
    assert [{"hello", %{text: "hello", pub: 1}}] =
           TestRepo.all(from p in subquery(query), select: {p.text, p})
    assert [{%{text: "hello", pub: 1}, 1}] =
           TestRepo.all(from p in subquery(query), select: {p, p.pub})
  end

  test "from: subqueries with aggregates" do
    TestRepo.insert!(%Post{id: 1, visits: 10})
    TestRepo.insert!(%Post{id: 2, visits: 11})
    TestRepo.insert!(%Post{id: 3, visits: 13})

    query = from p in Post, select: [:visits]
    assert [13] = TestRepo.all(from p in subquery(query), select: max(p.visits))
    query = from p in Post, select: [:visits], order_by: [asc: :visits], limit: 2
    assert [11] = TestRepo.all(from p in subquery(query), select: max(p.visits))

    query = from p in Post
    assert [13] = TestRepo.all(from p in subquery(query), select: max(p.visits))
    query = from p in Post, order_by: [asc: :visits], limit: 2
    assert [11] = TestRepo.all(from p in subquery(query), select: max(p.visits))
  end

  test "from: subqueries with parameters" do
    TestRepo.insert!(%Post{id: 1, visits: 10, text: "hello"})
    TestRepo.insert!(%Post{id: 2, visits: 11, text: "hello"})
    TestRepo.insert!(%Post{id: 3, visits: 13, text: "world"})

    query = from p in Post, where: p.visits >= ^11 and p.visits <= ^13
    query = from p in subquery(query), where: p.text == ^"hello", select: fragment("? + ?", p.visits, ^1)
    assert [12] = TestRepo.all(query)
  end

  test "join: subqueries with select source" do
    %{id: id} = TestRepo.insert!(%Post{id: 1, text: "hello", public: 1})
    TestRepo.insert!(%Comment{id: 1, post_id: id})

    query = from p in Post, select: p
    assert ["hello"] =
           TestRepo.all(from c in Comment, join: p in subquery(query), on: c.post_id == p.id, select: p.text)
    assert [%Post{inserted_at: %NaiveDateTime{}}] =
           TestRepo.all(from c in Comment, join: p in subquery(query), on: c.post_id == p.id, select: p)
  end

  test "join: subqueries with parameters" do
    TestRepo.insert!(%Post{id: 1, visits: 10, text: "hello"})
    TestRepo.insert!(%Post{id: 2, visits: 11, text: "hello"})
    TestRepo.insert!(%Post{id: 3, visits: 13, text: "world"})
    TestRepo.insert!(%Comment{id: 1})
    TestRepo.insert!(%Comment{id: 2})

    query = from p in Post, where: p.visits >= ^11 and p.visits <= ^13
    query = from c in Comment,
              join: p in subquery(query),
              where: p.text == ^"hello",
              select: fragment("? + ?", p.visits, ^1)
    assert [12, 12] = TestRepo.all(query)
  end
end
