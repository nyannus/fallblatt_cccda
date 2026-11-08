defmodule FallblattUI.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FallblattUIWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:fallblatt_ui, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FallblattUI.PubSub},
      # Start a worker by calling: FallblattUI.Worker.start_link(arg)
      # {FallblattUI.Worker, arg},
      # Start to serve requests, typically the last entry
      FallblattUIWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FallblattUI.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FallblattUIWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
