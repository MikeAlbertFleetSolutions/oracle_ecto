defmodule OracleEcto.Mixfile do
  use Mix.Project

  def project do
    [
      app: :oracle_ecto,
      version: "0.1.0",
      description: "Ecto Adapter for Oracle. Using Oracleex.",
      elixir: ">= 1.4.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      test_paths: ["integration/oracle"]
#      test_paths: ["integration/oracle", "test"]
   ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
     {:ecto, "~> 2.2.0"},
     {:oracleex, path: "/oracleex"}
   ]
  end
end
