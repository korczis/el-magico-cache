defmodule ElMagicoLabs.Application do
  @moduledoc """
  The ElMagicoLabsCache.Application module.
  """

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {ElMagicoLabs.Cache, %{
        resolvers: %{
          "author" =>
            fn ->
              "Tomas Korcak"
            end
        },
        restart: :permanent
      }},
      {Plug.Cowboy, scheme: :http, plug: ElMagicoLabs.Cache.Api.Router, options: [port: 4000]},
      # {Heart.Worker, :start_link, [ElMagicoLabs.Cache] }
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Application.html
    # for more information on OTP Applications
    opts = [strategy: :one_for_one, name: ElMagicoLabs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end