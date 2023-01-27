defmodule ElMagicoLabs.RehydratingCache.MixProject do
  use Mix.Project

  def project do
    [
      app: :el_magico_cache,
      version: "0.1.0",
      elixir: ">= 1.14.2",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "El Magico Cache",
      source_url: "https://github.com/korczis/el-magico-cache",
      homepage_url: "http://el-magico-cache.fly.dev",
      docs: [
        main: "El Magico Cache", # The main page in the docs
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
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
      {:plug_cowboy, "~> 2.6"},

      {:abacus, "~> 2.0"},

      {:ex_doc, "~> 0.29.1", only: :dev, runtime: false},
      {:horde, ">= 0.8.7"},

      # {:telemetry, ">= 0.0.0"},
      # {:telemetry_metrics, ">= 0.0.0"},
      # {:telemetry_poller, ">= 0.0.0"}
    ]
  end
end
