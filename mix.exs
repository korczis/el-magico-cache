defmodule ElMagicoLabs.Cache.MixProject do
  use Mix.Project

  def project do
    [
      app: :el_magico_cache,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ElMagicoLabs.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:open_api_spex, "~> 3.16"},

      {:plug, "~> 1.13"},
      {:plug_cowboy, "~> 2.6"}
    ]
  end
end
