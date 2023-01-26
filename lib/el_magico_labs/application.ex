defmodule EqLabs.Application do
  @moduledoc """
  The EqLabsCache.Application module.
  """

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {EqLabs.Cache, [%{}, []]}
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Application.html
    # for more information on OTP Applications
    opts = [strategy: :one_for_one, name: EqLabs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end