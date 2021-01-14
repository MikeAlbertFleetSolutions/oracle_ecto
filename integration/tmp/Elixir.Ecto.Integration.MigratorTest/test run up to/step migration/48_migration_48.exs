defmodule Elixir.Ecto.Integration.MigratorTest.Migration48 do
  use Ecto.Migration


  def up do
    send :"test run up to/step migration", {:up, 48}
  end
  def down do
    send :"test run up to/step migration", {:down, 48}
  end
end
