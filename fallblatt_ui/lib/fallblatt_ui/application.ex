defmodule FallblattUI.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: FallblattUI.PubSub},
      FallblattUIWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: FallblattUI.Supervisor)
  end

  @impl true
  def config_change(changed, _new, removed) do
    FallblattUIWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
