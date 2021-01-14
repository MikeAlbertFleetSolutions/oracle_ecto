defmodule Elixir.Ecto.Integration.MigratorTest.Migration54 do
  use Ecto.Migration


  def up do
    send :"test runs all migrations", {:up, 54}
  end
  def down do
    send :"test runs all migrations", {:down, 54}
  end
end
