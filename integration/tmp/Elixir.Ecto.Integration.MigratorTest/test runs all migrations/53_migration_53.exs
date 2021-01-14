defmodule Elixir.Ecto.Integration.MigratorTest.Migration53 do
  use Ecto.Migration


  def up do
    send :"test runs all migrations", {:up, 53}
  end
  def down do
    send :"test runs all migrations", {:down, 53}
  end
end
