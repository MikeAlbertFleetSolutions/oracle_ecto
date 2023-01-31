defmodule Elixir.Ecto.Integration.MigratorTest.Migration47 do
  use Ecto.Migration


  def up do
    send :"test run up to/step migration", {:up, 47}
  end
  def down do
    send :"test run up to/step migration", {:down, 47}
  end
end
